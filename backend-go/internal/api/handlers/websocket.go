package handlers

import (
	"log"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// WebSocket升级器
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // 允许所有来源，生产环境需要限制
	},
}

// WebSocket连接管理
type WebSocketManager struct {
	connections map[string]*websocket.Conn
	mu          sync.RWMutex
}

// 全局WebSocket管理器
var wsManager = &WebSocketManager{
	connections: make(map[string]*websocket.Conn),
}

// HandleWebSocket 处理WebSocket连接
func (h *Handlers) HandleWebSocket(c *gin.Context) {
	// 获取用户ID（从查询参数或JWT token）
	userID := c.Query("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户ID不能为空"})
		return
	}

	// 升级HTTP连接为WebSocket
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket升级失败: %v", err)
		return
	}
	defer conn.Close()

	// 注册连接
	wsManager.mu.Lock()
	wsManager.connections[userID] = conn
	wsManager.mu.Unlock()

	log.Printf("用户 %s 已连接WebSocket", userID)

	// 发送连接成功消息
	conn.WriteJSON(gin.H{
		"type":    "connection",
		"message": "连接成功",
		"user_id": userID,
	})

	// 处理消息
	for {
		var msg map[string]interface{}
		err := conn.ReadJSON(&msg)
		if err != nil {
			log.Printf("WebSocket读取消息失败: %v", err)
			break
		}

		// 处理不同类型的消息
		switch msg["type"] {
		case "ping":
			// 心跳检测
			conn.WriteJSON(gin.H{
				"type": "pong",
				"time": msg["time"],
			})
		case "message":
			// 处理聊天消息
			h.handleWebSocketMessage(userID, msg, conn)
		case "typing":
			// 处理正在输入状态
			h.handleTypingStatus(userID, msg)
		default:
			log.Printf("未知的WebSocket消息类型: %s", msg["type"])
		}
	}

	// 断开连接时清理
	wsManager.mu.Lock()
	delete(wsManager.connections, userID)
	wsManager.mu.Unlock()

	log.Printf("用户 %s 已断开WebSocket连接", userID)
}

// handleWebSocketMessage 处理WebSocket消息
func (h *Handlers) handleWebSocketMessage(userID string, msg map[string]interface{}, conn *websocket.Conn) {
	// 这里可以处理实时消息转发
	// 例如：转发给聊天室的其他用户

	// 示例：广播消息给所有在线用户
	wsManager.mu.RLock()
	for uid, connection := range wsManager.connections {
		if uid != userID {
			connection.WriteJSON(gin.H{
				"type":      "broadcast",
				"from_user": userID,
				"message":   msg["content"],
				"timestamp": msg["timestamp"],
			})
		}
	}
	wsManager.mu.RUnlock()
}

// handleTypingStatus 处理正在输入状态
func (h *Handlers) handleTypingStatus(userID string, msg map[string]interface{}) {
	// 通知其他用户该用户正在输入
	chatID := msg["chat_id"].(string)

	wsManager.mu.RLock()
	for uid, connection := range wsManager.connections {
		if uid != userID {
			connection.WriteJSON(gin.H{
				"type":      "typing",
				"user_id":   userID,
				"chat_id":   chatID,
				"is_typing": msg["is_typing"],
			})
		}
	}
	wsManager.mu.RUnlock()
}

// BroadcastToUser 向指定用户发送消息
func (h *Handlers) BroadcastToUser(userID string, message interface{}) {
	wsManager.mu.RLock()
	conn, exists := wsManager.connections[userID]
	wsManager.mu.RUnlock()

	if exists {
		conn.WriteJSON(message)
	}
}

// BroadcastToChat 向聊天室发送消息
func (h *Handlers) BroadcastToChat(chatID string, message interface{}) {
	// 这里需要根据chatID找到相关的用户
	// 然后向这些用户发送消息

	wsManager.mu.RLock()
	for userID, conn := range wsManager.connections {
		// 检查用户是否在聊天室中
		// 这里需要查询数据库或缓存来确定用户是否在聊天室中
		_ = userID
		_ = conn
		// 实际实现需要根据业务逻辑来确定
	}
	wsManager.mu.RUnlock()
}

// GetOnlineUsers 获取在线用户列表
func (h *Handlers) GetOnlineUsers() []string {
	wsManager.mu.RLock()
	defer wsManager.mu.RUnlock()

	users := make([]string, 0, len(wsManager.connections))
	for userID := range wsManager.connections {
		users = append(users, userID)
	}

	return users
}
