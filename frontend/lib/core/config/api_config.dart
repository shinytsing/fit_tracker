class ApiConfig {
  // 后端 API 配置
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String wsUrl = 'ws://localhost:8080/ws';
  static const int timeoutSeconds = 30;
  
  // API 端点常量
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String bmiEndpoint = '/bmi';
  static const String workoutEndpoint = '/workout';
  static const String communityEndpoint = '/community';
  static const String messagesEndpoint = '/messages';
  
  // 认证相关
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String meEndpoint = '$authEndpoint/me';
  
  // BMI 相关
  static const String bmiCalculateEndpoint = '$bmiEndpoint/calculate';
  static const String bmiRecordsEndpoint = '$bmiEndpoint/records';
  static const String bmiStatsEndpoint = '$bmiEndpoint/stats';
  
  // 训练相关
  static const String workoutPlansEndpoint = '$workoutEndpoint/plans';
  static const String workoutRecordsEndpoint = '$workoutEndpoint/records';
  static const String exercisesEndpoint = '$workoutEndpoint/exercises';
  static const String aiGeneratePlanEndpoint = '$workoutEndpoint/ai/generate-plan';
  
  // 社区相关
  static const String postsEndpoint = '$communityEndpoint/posts';
  static const String followEndpoint = '$communityEndpoint/users';
  
  // 消息相关
  static const String chatsEndpoint = '$messagesEndpoint/chats';
  static const String notificationsEndpoint = '$messagesEndpoint/notifications';
}
