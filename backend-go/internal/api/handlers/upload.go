package handlers

import (
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// UploadMedia 上传媒体文件
func (h *Handlers) UploadMedia(c *gin.Context) {
	_, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	// 获取上传的文件
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "文件上传失败",
			"code":    "FILE_UPLOAD_ERROR",
			"details": err.Error(),
		})
		return
	}
	defer file.Close()

	// 获取文件类型
	fileType := c.PostForm("type") // image, video, audio, file
	if fileType == "" {
		fileType = "file"
	}

	// 验证文件类型
	if !isValidFileType(fileType, header.Header.Get("Content-Type")) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "不支持的文件类型",
			"code":  "INVALID_FILE_TYPE",
		})
		return
	}

	// 验证文件大小
	if header.Size > getMaxFileSize(fileType) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "文件大小超出限制",
			"code":  "FILE_TOO_LARGE",
		})
		return
	}

	// 生成唯一文件名
	fileID := uuid.New().String()
	ext := filepath.Ext(header.Filename)
	filename := fmt.Sprintf("%s_%d%s", fileID, time.Now().Unix(), ext)

	// 创建上传目录
	uploadDir := fmt.Sprintf("./uploads/%s", fileType)
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建上传目录失败",
			"code":  "DIRECTORY_CREATE_ERROR",
		})
		return
	}

	// 保存文件
	filePath := filepath.Join(uploadDir, filename)
	if err := saveUploadedFile(file, filePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "文件保存失败",
			"code":  "FILE_SAVE_ERROR",
		})
		return
	}

	// 生成文件URL
	fileURL := fmt.Sprintf("/uploads/%s/%s", fileType, filename)

	// 获取文件信息
	fileInfo, err := getFileInfo(filePath, fileType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取文件信息失败",
			"code":  "FILE_INFO_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "文件上传成功",
		"data": gin.H{
			"id":                fileID,
			"filename":          filename,
			"original_filename": header.Filename,
			"file_url":          fileURL,
			"file_type":         fileType,
			"mime_type":         header.Header.Get("Content-Type"),
			"file_size":         header.Size,
			"width":             fileInfo.Width,
			"height":            fileInfo.Height,
			"duration":          fileInfo.Duration,
			"thumbnail_url":     fileInfo.ThumbnailURL,
			"uploaded_at":       time.Now(),
		},
	})
}

// UploadImage 上传图片文件
func (h *Handlers) UploadImage(c *gin.Context) {
	// 获取用户ID（如果需要的话）
	_, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	// 获取上传的文件
	file, header, err := c.Request.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "图片上传失败",
			"code":    "IMAGE_UPLOAD_ERROR",
			"details": err.Error(),
		})
		return
	}
	defer file.Close()

	// 验证图片类型
	if !isValidImageType(header.Header.Get("Content-Type")) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "不支持的图片格式",
			"code":  "INVALID_IMAGE_TYPE",
		})
		return
	}

	// 验证图片大小
	if header.Size > 10*1024*1024 { // 10MB
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "图片大小超出限制（最大10MB）",
			"code":  "IMAGE_TOO_LARGE",
		})
		return
	}

	// 生成唯一文件名
	fileID := uuid.New().String()
	ext := filepath.Ext(header.Filename)
	filename := fmt.Sprintf("%s_%d%s", fileID, time.Now().Unix(), ext)

	// 创建上传目录
	uploadDir := "./uploads/images"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建上传目录失败",
			"code":  "DIRECTORY_CREATE_ERROR",
		})
		return
	}

	// 保存文件
	filePath := filepath.Join(uploadDir, filename)
	if err := saveUploadedFile(file, filePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "图片保存失败",
			"code":  "IMAGE_SAVE_ERROR",
		})
		return
	}

	// 生成图片URL
	imageURL := fmt.Sprintf("/uploads/images/%s", filename)

	// 获取图片尺寸
	width, height, err := getImageDimensions(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取图片尺寸失败",
			"code":  "IMAGE_DIMENSIONS_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "图片上传成功",
		"data": gin.H{
			"id":                fileID,
			"filename":          filename,
			"original_filename": header.Filename,
			"image_url":         imageURL,
			"file_type":         "image",
			"mime_type":         header.Header.Get("Content-Type"),
			"file_size":         header.Size,
			"width":             width,
			"height":            height,
			"uploaded_at":       time.Now(),
		},
	})
}

// FileInfo 文件信息结构
type FileInfo struct {
	Width        int    `json:"width"`
	Height       int    `json:"height"`
	Duration     int    `json:"duration"`
	ThumbnailURL string `json:"thumbnail_url"`
}

// isValidFileType 验证文件类型
func isValidFileType(fileType, mimeType string) bool {
	validTypes := map[string][]string{
		"image": {"image/jpeg", "image/png", "image/gif", "image/webp"},
		"video": {"video/mp4", "video/avi", "video/mov", "video/wmv"},
		"audio": {"audio/mp3", "audio/wav", "audio/m4a", "audio/ogg"},
		"file":  {"application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"},
	}

	if types, exists := validTypes[fileType]; exists {
		for _, validType := range types {
			if strings.Contains(mimeType, validType) {
				return true
			}
		}
	}
	return false
}

// isValidImageType 验证图片类型
func isValidImageType(mimeType string) bool {
	validImageTypes := []string{"image/jpeg", "image/png", "image/gif", "image/webp"}
	for _, validType := range validImageTypes {
		if strings.Contains(mimeType, validType) {
			return true
		}
	}
	return false
}

// getMaxFileSize 获取最大文件大小
func getMaxFileSize(fileType string) int64 {
	sizes := map[string]int64{
		"image": 10 * 1024 * 1024,  // 10MB
		"video": 100 * 1024 * 1024, // 100MB
		"audio": 50 * 1024 * 1024,  // 50MB
		"file":  20 * 1024 * 1024,  // 20MB
	}
	if size, exists := sizes[fileType]; exists {
		return size
	}
	return 20 * 1024 * 1024 // 默认20MB
}

// saveUploadedFile 保存上传的文件
func saveUploadedFile(file multipart.File, filePath string) error {
	out, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, file)
	return err
}

// getFileInfo 获取文件信息
func getFileInfo(filePath, fileType string) (*FileInfo, error) {
	info := &FileInfo{}

	switch fileType {
	case "image":
		width, height, err := getImageDimensions(filePath)
		if err != nil {
			return nil, err
		}
		info.Width = width
		info.Height = height
	case "video":
		// 这里需要视频处理库来获取视频信息
		// 暂时返回默认值
		info.Width = 1920
		info.Height = 1080
		info.Duration = 0
	case "audio":
		// 这里需要音频处理库来获取音频信息
		// 暂时返回默认值
		info.Duration = 0
	}

	return info, nil
}

// getImageDimensions 获取图片尺寸
func getImageDimensions(filePath string) (int, int, error) {
	// 这里需要图片处理库来获取图片尺寸
	// 暂时返回默认值
	return 1920, 1080, nil
}
