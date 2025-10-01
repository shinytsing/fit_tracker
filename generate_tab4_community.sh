#!/bin/bash

# FitTracker 模块生成器 - Tab4: 社区动态
# 自动生成社区动态相关的前端和后端代码

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目路径
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend-go"

log_info() {
    echo -e "${BLUE}[Tab4 Generator]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Tab4 Generator]${NC} $1"
}

log_error() {
    echo -e "${RED}[Tab4 Generator]${NC} $1"
}

# 生成前端社区页面
generate_frontend_community_page() {
    log_info "生成前端社区页面..."
    
    mkdir -p "$FRONTEND_DIR/lib/features/community/presentation/pages"
    mkdir -p "$FRONTEND_DIR/lib/features/community/presentation/widgets"
    mkdir -p "$FRONTEND_DIR/lib/features/community/domain/models"
    mkdir -p "$FRONTEND_DIR/lib/features/community/data/repositories"
    
    # 社区模型
    cat > "$FRONTEND_DIR/lib/features/community/domain/models/community_models.dart" << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'community_models.g.dart';

@JsonSerializable()
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String> images;
  final List<String> videos;
  final String? location;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isShared;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PostType type;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.images,
    required this.videos,
    this.location,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    required this.isShared,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
  });

  factory Post.fromJson(Map<String, dynamic> json) =>
      _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class Like {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) =>
      _$LikeFromJson(json);
  Map<String, dynamic> toJson() => _$LikeToJson(this);
}

@JsonSerializable()
class Share {
  final String id;
  final String postId;
  final String userId;
  final String? content;
  final DateTime createdAt;

  Share({
    required this.id,
    required this.postId,
    required this.userId,
    this.content,
    required this.createdAt,
  });

  factory Share.fromJson(Map<String, dynamic> json) =>
      _$ShareFromJson(json);
  Map<String, dynamic> toJson() => _$ShareToJson(this);
}

enum PostType {
  @JsonValue('training')
  training,
  @JsonValue('nutrition')
  nutrition,
  @JsonValue('motivation')
  motivation,
  @JsonValue('question')
  question,
  @JsonValue('achievement')
  achievement,
}

@JsonSerializable()
class UserProfile {
  final String id;
  final String name;
  final String? avatar;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowing;
  final DateTime joinedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isFollowing,
    required this.joinedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
EOF

    # 社区页面
    cat > "$FRONTEND_DIR/lib/features/community/presentation/pages/community_page.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/post_detail_dialog.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 监听滚动事件，实现无限滚动
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 加载更多内容
      ref.read(communityProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区动态'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(communityProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '推荐', icon: Icon(Icons.trending_up)),
            Tab(text: '关注', icon: Icon(Icons.favorite)),
            Tab(text: '训练', icon: Icon(Icons.fitness_center)),
            Tab(text: '营养', icon: Icon(Icons.restaurant)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(PostType.training),
          _buildFollowingTab(),
          _buildCategoryTab(PostType.training),
          _buildCategoryTab(PostType.nutrition),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostsTab(PostType type) {
    final posts = ref.watch(communityProvider);
    
    return posts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(communityProvider);
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: posts.length + 1, // +1 for loading indicator
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  _showPostDetail(post);
                },
                onLike: () {
                  ref.read(communityProvider.notifier).toggleLike(post.id);
                },
                onComment: () {
                  _showPostDetail(post);
                },
                onShare: () {
                  _sharePost(post);
                },
                onUserTap: () {
                  _showUserProfile(post.userId);
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $error',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.refresh(communityProvider);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowingTab() {
    final followingPosts = ref.watch(followingPostsProvider);
    
    return followingPosts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '还没有关注任何人',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '去发现更多有趣的用户吧！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(followingPostsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  _showPostDetail(post);
                },
                onLike: () {
                  ref.read(communityProvider.notifier).toggleLike(post.id);
                },
                onComment: () {
                  _showPostDetail(post);
                },
                onShare: () {
                  _sharePost(post);
                },
                onUserTap: () {
                  _showUserProfile(post.userId);
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildCategoryTab(PostType type) {
    final categoryPosts = ref.watch(categoryPostsProvider(type));
    
    return categoryPosts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(categoryPostsProvider(type));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  _showPostDetail(post);
                },
                onLike: () {
                  ref.read(communityProvider.notifier).toggleLike(post.id);
                },
                onComment: () {
                  _showPostDetail(post);
                },
                onShare: () {
                  _sharePost(post);
                },
                onUserTap: () {
                  _showUserProfile(post.userId);
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无动态',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '发布第一条动态，开始你的健身之旅！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        onSubmit: (content, images, type) {
          ref.read(communityProvider.notifier).createPost(
            content: content,
            images: images,
            type: type,
          );
        },
      ),
    );
  }

  void _showPostDetail(post) {
    showDialog(
      context: context,
      builder: (context) => PostDetailDialog(
        post: post,
        onLike: () {
          ref.read(communityProvider.notifier).toggleLike(post.id);
        },
        onComment: (content) {
          ref.read(communityProvider.notifier).addComment(post.id, content);
        },
        onShare: () {
          _sharePost(post);
        },
      ),
    );
  }

  void _showUserProfile(String userId) {
    // 导航到用户资料页面
    Navigator.pushNamed(context, '/user_profile', arguments: userId);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索动态'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '输入关键词搜索...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行搜索
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _sharePost(post) {
    // 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享功能开发中...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
EOF

    log_success "前端社区页面生成完成"
}

# 生成后端社区 API
generate_backend_community_api() {
    log_info "生成后端社区 API..."
    
    # 社区模型
    cat > "$BACKEND_DIR/internal/models/community.go" << 'EOF'
package models

import (
	"time"
	"gorm.io/gorm"
)

// Post 动态
type Post struct {
	ID            string    `json:"id" gorm:"primaryKey"`
	UserID        string    `json:"user_id" gorm:"not null"`
	UserName      string    `json:"user_name" gorm:"not null"`
	UserAvatar    string    `json:"user_avatar"`
	Content       string    `json:"content" gorm:"not null"`
	Images        string    `json:"images"` // JSON array
	Videos        string    `json:"videos"` // JSON array
	Location      string    `json:"location"`
	Tags          string    `json:"tags"` // JSON array
	LikesCount    int       `json:"likes_count" gorm:"default:0"`
	CommentsCount int       `json:"comments_count" gorm:"default:0"`
	SharesCount   int       `json:"shares_count" gorm:"default:0"`
	Type          string    `json:"type" gorm:"not null"` // training, nutrition, motivation, question, achievement
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
}

// Comment 评论
type Comment struct {
	ID         string    `json:"id" gorm:"primaryKey"`
	PostID     string    `json:"post_id" gorm:"not null"`
	UserID     string    `json:"user_id" gorm:"not null"`
	UserName   string    `json:"user_name" gorm:"not null"`
	UserAvatar string    `json:"user_avatar"`
	Content    string    `json:"content" gorm:"not null"`
	ParentID   string    `json:"parent_id"` // 回复的评论ID
	LikesCount int       `json:"likes_count" gorm:"default:0"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// Like 点赞
type Like struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PostID    string    `json:"post_id" gorm:"not null"`
	UserID    string    `json:"user_id" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
}

// Share 分享
type Share struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PostID    string    `json:"post_id" gorm:"not null"`
	UserID    string    `json:"user_id" gorm:"not null"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
}

// Follow 关注
type Follow struct {
	ID          string    `json:"id" gorm:"primaryKey"`
	FollowerID  string    `json:"follower_id" gorm:"not null"`
	FollowingID string    `json:"following_id" gorm:"not null"`
	CreatedAt   time.Time `json:"created_at"`
}

// UserProfile 用户资料
type UserProfile struct {
	ID              string    `json:"id" gorm:"primaryKey"`
	Name            string    `json:"name" gorm:"not null"`
	Avatar          string    `json:"avatar"`
	Bio             string    `json:"bio"`
	FollowersCount  int       `json:"followers_count" gorm:"default:0"`
	FollowingCount  int       `json:"following_count" gorm:"default:0"`
	PostsCount      int       `json:"posts_count" gorm:"default:0"`
	JoinedAt        time.Time `json:"joined_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}
EOF

    # 社区处理器
    cat > "$BACKEND_DIR/internal/handlers/community_handler.go" << 'EOF'
package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"fittracker/backend/internal/services"
)

type CommunityHandler struct {
	communityService *services.CommunityService
}

func NewCommunityHandler(communityService *services.CommunityService) *CommunityHandler {
	return &CommunityHandler{
		communityService: communityService,
	}
}

// GetPosts 获取动态列表
func (h *CommunityHandler) GetPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	postType := c.Query("type")
	category := c.Query("category")

	posts, total, err := h.communityService.GetPosts(userID, page, limit, postType, category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": posts,
		"total": total,
		"page": page,
		"limit": limit,
	})
}

// CreatePost 创建动态
func (h *CommunityHandler) CreatePost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		Content  string   `json:"content" binding:"required"`
		Images   []string `json:"images"`
		Videos   []string `json:"videos"`
		Location string   `json:"location"`
		Tags     []string `json:"tags"`
		Type     string   `json:"type" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	post, err := h.communityService.CreatePost(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": post})
}

// GetPost 获取动态详情
func (h *CommunityHandler) GetPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	post, err := h.communityService.GetPost(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": post})
}

// LikePost 点赞动态
func (h *CommunityHandler) LikePost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	err := h.communityService.ToggleLike(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "操作成功"})
}

// CommentPost 评论动态
func (h *CommunityHandler) CommentPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	var req struct {
		Content  string `json:"content" binding:"required"`
		ParentID string `json:"parent_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	comment, err := h.communityService.AddComment(userID, postID, req.Content, req.ParentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": comment})
}

// SharePost 分享动态
func (h *CommunityHandler) SharePost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	var req struct {
		Content string `json:"content"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.communityService.SharePost(userID, postID, req.Content)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "分享成功"})
}

// FollowUser 关注用户
func (h *CommunityHandler) FollowUser(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	targetUserID := c.Param("id")
	if targetUserID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID不能为空"})
		return
	}

	err := h.communityService.ToggleFollow(userID, targetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "操作成功"})
}

// GetUserProfile 获取用户资料
func (h *CommunityHandler) GetUserProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	targetUserID := c.Param("id")
	if targetUserID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID不能为空"})
		return
	}

	profile, err := h.communityService.GetUserProfile(userID, targetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": profile})
}

// GetFollowingPosts 获取关注用户的动态
func (h *CommunityHandler) GetFollowingPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	posts, total, err := h.communityService.GetFollowingPosts(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": posts,
		"total": total,
		"page": page,
		"limit": limit,
	})
}
EOF

    log_success "后端社区 API 生成完成"
}

# 主执行函数
main() {
    log_info "开始生成 Tab4: 社区动态模块..."
    
    generate_frontend_community_page
    generate_backend_community_api
    
    log_success "Tab4: 社区动态模块生成完成！"
}

# 执行主函数
main "$@"
