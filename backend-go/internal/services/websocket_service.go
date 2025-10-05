package services

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"gymates/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// WebSocketService WebSocket服务
type WebSocketService struct {
	upgrader websocket.Upgrader
	clients  map[string]*websocket.Conn
	rooms    map[string][]string // chatID -> []userID
	mutex    sync.RWMutex
}

// NewWebSocketService 创建WebSocket服务
func NewWebSocketService() *WebSocketService {
	return &WebSocketService{
		upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool {
				return true // 在生产环境中应该检查来源
			},
		},
		clients: make(map[string]*websocket.Conn),
		rooms:   make(map[string][]string),
	}
}

// WebSocketMessage WebSocket消息结构
type WebSocketMessage struct {
	Type      string                 `json:"type"` // message, notification, typing, online_status, video_call_invite, video_call_accept, video_call_reject, video_call_end, ice_candidate, sdp_offer, sdp_answer
	ChatID    string                 `json:"chat_id,omitempty"`
	UserID    string                 `json:"user_id"`
	Content   string                 `json:"content,omitempty"`
	Data      map[string]interface{} `json:"data,omitempty"`
	Timestamp int64                  `json:"timestamp"`
}

// HandleWebSocket 处理WebSocket连接
func (ws *WebSocketService) HandleWebSocket(c *gin.Context) {
	conn, err := ws.upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket升级失败: %v", err)
		return
	}
	defer conn.Close()

	// 获取用户ID（这里应该从JWT token中获取）
	userID := c.Query("user_id")
	if userID == "" {
		log.Println("用户ID不能为空")
		return
	}

	// 注册客户端
	ws.mutex.Lock()
	ws.clients[userID] = conn
	ws.mutex.Unlock()

	log.Printf("用户 %s 已连接WebSocket", userID)

	// 发送在线状态
	ws.broadcastOnlineStatus(userID, true)

	// 处理消息
	for {
		var msg WebSocketMessage
		err := conn.ReadJSON(&msg)
		if err != nil {
			log.Printf("读取WebSocket消息失败: %v", err)
			break
		}

		msg.UserID = userID
		ws.handleMessage(&msg)
	}

	// 清理连接
	ws.mutex.Lock()
	delete(ws.clients, userID)
	ws.mutex.Unlock()

	// 发送离线状态
	ws.broadcastOnlineStatus(userID, false)

	log.Printf("用户 %s 已断开WebSocket连接", userID)
}

// handleMessage 处理WebSocket消息
func (ws *WebSocketService) handleMessage(msg *WebSocketMessage) {
	switch msg.Type {
	case "join_chat":
		ws.joinChat(msg.UserID, msg.ChatID)
	case "leave_chat":
		ws.leaveChat(msg.UserID, msg.ChatID)
	case "typing":
		ws.broadcastTyping(msg.ChatID, msg.UserID, true)
	case "stop_typing":
		ws.broadcastTyping(msg.ChatID, msg.UserID, false)
	case "message":
		ws.BroadcastToChat(msg.ChatID, msg)
	// 视频通话信令
	case "video_call_invite":
		ws.handleVideoCallInvite(msg)
	case "video_call_accept":
		ws.handleVideoCallAccept(msg)
	case "video_call_reject":
		ws.handleVideoCallReject(msg)
	case "video_call_end":
		ws.handleVideoCallEnd(msg)
	case "ice_candidate":
		ws.handleIceCandidate(msg)
	case "sdp_offer":
		ws.handleSdpOffer(msg)
	case "sdp_answer":
		ws.handleSdpAnswer(msg)
	default:
		log.Printf("未知的消息类型: %s", msg.Type)
	}
}

// joinChat 加入聊天室
func (ws *WebSocketService) joinChat(userID, chatID string) {
	ws.mutex.Lock()
	defer ws.mutex.Unlock()

	if ws.rooms[chatID] == nil {
		ws.rooms[chatID] = make([]string, 0)
	}

	// 检查用户是否已在房间中
	for _, id := range ws.rooms[chatID] {
		if id == userID {
			return
		}
	}

	ws.rooms[chatID] = append(ws.rooms[chatID], userID)
	log.Printf("用户 %s 加入聊天室 %s", userID, chatID)
}

// leaveChat 离开聊天室
func (ws *WebSocketService) leaveChat(userID, chatID string) {
	ws.mutex.Lock()
	defer ws.mutex.Unlock()

	if ws.rooms[chatID] == nil {
		return
	}

	// 从房间中移除用户
	for i, id := range ws.rooms[chatID] {
		if id == userID {
			ws.rooms[chatID] = append(ws.rooms[chatID][:i], ws.rooms[chatID][i+1:]...)
			break
		}
	}

	log.Printf("用户 %s 离开聊天室 %s", userID, chatID)
}

// BroadcastToChat 向聊天室广播消息
func (ws *WebSocketService) BroadcastToChat(chatID string, message interface{}) {
	ws.mutex.RLock()
	defer ws.mutex.RUnlock()

	if ws.rooms[chatID] == nil {
		return
	}

	data, err := json.Marshal(message)
	if err != nil {
		log.Printf("序列化消息失败: %v", err)
		return
	}

	for _, userID := range ws.rooms[chatID] {
		if conn, exists := ws.clients[userID]; exists {
			err := conn.WriteMessage(websocket.TextMessage, data)
			if err != nil {
				log.Printf("发送消息到用户 %s 失败: %v", userID, err)
				// 清理无效连接
				delete(ws.clients, userID)
			}
		}
	}
}

// broadcastTyping 广播打字状态
func (ws *WebSocketService) broadcastTyping(chatID, userID string, isTyping bool) {
	msg := WebSocketMessage{
		Type:      "typing_status",
		ChatID:    chatID,
		UserID:    userID,
		Timestamp: getCurrentTimestamp(),
		Data: map[string]interface{}{
			"is_typing": isTyping,
		},
	}

	ws.BroadcastToChat(chatID, msg)
}

// broadcastOnlineStatus 广播在线状态
func (ws *WebSocketService) broadcastOnlineStatus(userID string, isOnline bool) {
	msg := WebSocketMessage{
		Type:      "online_status",
		UserID:    userID,
		Timestamp: getCurrentTimestamp(),
		Data: map[string]interface{}{
			"is_online": isOnline,
		},
	}

	// 向所有用户广播在线状态
	ws.mutex.RLock()
	defer ws.mutex.RUnlock()

	data, err := json.Marshal(msg)
	if err != nil {
		log.Printf("序列化在线状态消息失败: %v", err)
		return
	}

	for id, conn := range ws.clients {
		if id != userID { // 不向自己发送
			err := conn.WriteMessage(websocket.TextMessage, data)
			if err != nil {
				log.Printf("发送在线状态到用户 %s 失败: %v", id, err)
			}
		}
	}
}

// SendNotification 发送通知
func (ws *WebSocketService) SendNotification(userID string, notification *models.Notification) {
	ws.mutex.RLock()
	defer ws.mutex.RUnlock()

	if conn, exists := ws.clients[userID]; exists {
		msg := WebSocketMessage{
			Type:      "notification",
			UserID:    userID,
			Timestamp: getCurrentTimestamp(),
			Data: map[string]interface{}{
				"notification": notification,
			},
		}

		data, err := json.Marshal(msg)
		if err != nil {
			log.Printf("序列化通知消息失败: %v", err)
			return
		}

		err = conn.WriteMessage(websocket.TextMessage, data)
		if err != nil {
			log.Printf("发送通知到用户 %s 失败: %v", userID, err)
		}
	}
}

// GetOnlineUsers 获取在线用户列表
func (ws *WebSocketService) GetOnlineUsers() []string {
	ws.mutex.RLock()
	defer ws.mutex.RUnlock()

	users := make([]string, 0, len(ws.clients))
	for userID := range ws.clients {
		users = append(users, userID)
	}

	return users
}

// IsUserOnline 检查用户是否在线
func (ws *WebSocketService) IsUserOnline(userID string) bool {
	ws.mutex.RLock()
	defer ws.mutex.RUnlock()

	_, exists := ws.clients[userID]
	return exists
}

// ==================== 视频通话信令处理 ====================

// handleVideoCallInvite 处理视频通话邀请
func (ws *WebSocketService) handleVideoCallInvite(msg *WebSocketMessage) {
	// 获取被邀请用户ID
	calleeID, ok := msg.Data["callee_id"].(string)
	if !ok {
		log.Printf("视频通话邀请缺少被邀请用户ID")
		return
	}

	// 转发邀请给被邀请用户
	ws.SendToUser(calleeID, msg)
	log.Printf("用户 %s 向用户 %s 发起视频通话邀请", msg.UserID, calleeID)
}

// handleVideoCallAccept 处理视频通话接受
func (ws *WebSocketService) handleVideoCallAccept(msg *WebSocketMessage) {
	// 获取发起者用户ID
	callerID, ok := msg.Data["caller_id"].(string)
	if !ok {
		log.Printf("视频通话接受缺少发起者用户ID")
		return
	}

	// 转发接受消息给发起者
	ws.SendToUser(callerID, msg)
	log.Printf("用户 %s 接受了用户 %s 的视频通话邀请", msg.UserID, callerID)
}

// handleVideoCallReject 处理视频通话拒绝
func (ws *WebSocketService) handleVideoCallReject(msg *WebSocketMessage) {
	// 获取发起者用户ID
	callerID, ok := msg.Data["caller_id"].(string)
	if !ok {
		log.Printf("视频通话拒绝缺少发起者用户ID")
		return
	}

	// 转发拒绝消息给发起者
	ws.SendToUser(callerID, msg)
	log.Printf("用户 %s 拒绝了用户 %s 的视频通话邀请", msg.UserID, callerID)
}

// handleVideoCallEnd 处理视频通话结束
func (ws *WebSocketService) handleVideoCallEnd(msg *WebSocketMessage) {
	// 获取对方用户ID
	otherUserID, ok := msg.Data["other_user_id"].(string)
	if !ok {
		log.Printf("视频通话结束缺少对方用户ID")
		return
	}

	// 转发结束消息给对方
	ws.SendToUser(otherUserID, msg)
	log.Printf("用户 %s 结束了与用户 %s 的视频通话", msg.UserID, otherUserID)
}

// handleIceCandidate 处理ICE候选
func (ws *WebSocketService) handleIceCandidate(msg *WebSocketMessage) {
	// 获取对方用户ID
	otherUserID, ok := msg.Data["other_user_id"].(string)
	if !ok {
		log.Printf("ICE候选缺少对方用户ID")
		return
	}

	// 转发ICE候选给对方
	ws.SendToUser(otherUserID, msg)
}

// handleSdpOffer 处理SDP Offer
func (ws *WebSocketService) handleSdpOffer(msg *WebSocketMessage) {
	// 获取对方用户ID
	otherUserID, ok := msg.Data["other_user_id"].(string)
	if !ok {
		log.Printf("SDP Offer缺少对方用户ID")
		return
	}

	// 转发SDP Offer给对方
	ws.SendToUser(otherUserID, msg)
}

// handleSdpAnswer 处理SDP Answer
func (ws *WebSocketService) handleSdpAnswer(msg *WebSocketMessage) {
	// 获取对方用户ID
	otherUserID, ok := msg.Data["other_user_id"].(string)
	if !ok {
		log.Printf("SDP Answer缺少对方用户ID")
		return
	}

	// 转发SDP Answer给对方
	ws.SendToUser(otherUserID, msg)
}

// SendToUser 发送消息给指定用户
func (ws *WebSocketService) SendToUser(userID string, message interface{}) {
	ws.mutex.RLock()
	defer ws.mutex.RUnlock()

	if conn, exists := ws.clients[userID]; exists {
		data, err := json.Marshal(message)
		if err != nil {
			log.Printf("序列化消息失败: %v", err)
			return
		}

		err = conn.WriteMessage(websocket.TextMessage, data)
		if err != nil {
			log.Printf("发送消息到用户 %s 失败: %v", userID, err)
			// 清理无效连接
			delete(ws.clients, userID)
		}
	}
}

// getCurrentTimestamp 获取当前时间戳
func getCurrentTimestamp() int64 {
	return time.Now().Unix()
}
