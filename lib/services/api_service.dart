import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// API服务 - 处理所有后端通信
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  late SharedPreferences _prefs;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加token到请求头
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // 处理错误
          if (error.response?.statusCode == 401) {
            // Token过期，清除本地存储
            clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// 初始化SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存token
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  /// 获取token
  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  /// 清除token
  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  /// 保存用户信息
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _prefs.setString('user_info', userInfo.toString());
  }

  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    final userInfoStr = _prefs.getString('user_info');
    if (userInfoStr != null) {
      // 实际应用中应该使用JSON解析
      return {};
    }
    return null;
  }

  // ========== 认证相关 ==========

  /// 获取当前用户
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/trpc/auth.me');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _dio.post('/api/trpc/auth.logout');
      await clearToken();
    } catch (e) {
      rethrow;
    }
  }

  /// 发送手机验证码
  Future<void> sendVerificationCode(String phone) async {
    try {
      await _dio.post(
        '/api/trpc/auth.sendSmsCode',
        data: {'phone': phone},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 手机号登录
  Future<Map<String, dynamic>> loginWithPhone(
    String phone,
    String verificationCode, {
    String role = 'customer',
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/auth.phoneLogin',
        data: {
          'phone': phone,
          'code': verificationCode,
          'role': role,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 微信登录
  Future<Map<String, dynamic>> loginWithWechat(
    String code, {
    String role = 'customer',
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/auth.wechatLogin',
        data: {
          'code': code,
          'role': role,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 支付宝登录
  Future<Map<String, dynamic>> loginWithAlipay(
    String code, {
    String role = 'customer',
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/auth.alipayLogin',
        data: {
          'code': code,
          'role': role,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Google登录
  Future<Map<String, dynamic>> loginWithGoogle(
    String idToken, {
    String role = 'customer',
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/auth.googleLogin',
        data: {
          'idToken': idToken,
          'role': role,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 游客登录
  Future<Map<String, dynamic>> guestLogin() async {
    try {
      final response = await _dio.post('/api/trpc/auth.guestLogin');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== 用户相关 ==========

  /// 获取用户资料
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/api/trpc/user.profile');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新用户资料
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '/api/trpc/user.updateProfile',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ========== 任务相关 ==========

  /// 获取任务列表
  Future<List<Map<String, dynamic>>> getTasks({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trpc/task.getTask',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (status != null) 'status': status,
        },
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取任务详情
  Future<Map<String, dynamic>> getTaskDetail(int taskId) async {
    try {
      final response = await _dio.get(
        '/api/trpc/task.getTask',
        queryParameters: {'taskId': taskId},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 创建任务
  Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/task.create',
        data: taskData,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 接受任务
  Future<void> acceptTask(int taskId) async {
    try {
      await _dio.post(
        '/api/trpc/pilot.acceptTask',
        data: {'taskId': taskId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 拒绝任务
  Future<void> rejectTask(int taskId) async {
    try {
      await _dio.post(
        '/api/trpc/pilot.rejectTask',
        data: {'taskId': taskId},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ========== 支付相关 ==========

  /// 创建支付会话
  Future<Map<String, dynamic>> createCheckoutSession(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/payment.createTaskCheckout',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取订单列表
  Future<List<Map<String, dynamic>>> getOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trpc/payment.getCustomerOrders',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      rethrow;
    }
  }

  // ========== 数据相关 ==========

  /// 上传飞行数据
  Future<Map<String, dynamic>> uploadFlightData(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/data.uploadFlightData',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 评价任务
  Future<void> rateTask(
    int taskId,
    Map<String, dynamic> ratingData,
  ) async {
    try {
      await _dio.post(
        '/api/trpc/data.rateTask',
        data: {
          'taskId': taskId,
          ...ratingData,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // ========== 聊天相关 ==========

  /// 获取会话列表
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _dio.get('/api/trpc/chat.getConversations');
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取消息列表
  Future<List<Map<String, dynamic>>> getMessages(
    int conversationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trpc/chat.getMessages',
        queryParameters: {
          'conversationId': conversationId,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      rethrow;
    }
  }

  /// 发送消息
  Future<Map<String, dynamic>> sendMessage(
    int conversationId,
    String content,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/chat.sendMessage',
        data: {
          'conversationId': conversationId,
          'content': content,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== 通知相关 ==========

  /// 获取通知列表
  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trpc/notification.getNotifications',
        queryParameters: {'limit': limit},
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      rethrow;
    }
  }

  /// 标记通知为已读
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _dio.post(
        '/api/trpc/notification.markAsRead',
        data: {'notificationId': notificationId},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ========== 联系方式解锁 ==========

  /// 解锁飞手联系方式
  Future<Map<String, dynamic>> unlockContact(
    int pilotId,
    int taskId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/contact.unlock',
        data: {
          'pilotId': pilotId,
          'taskId': taskId,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取已解锁的联系方式
  Future<Map<String, dynamic>> getUnlockedContact(int taskId) async {
    try {
      final response = await _dio.get(
        '/api/trpc/contact.getUnlockedContact',
        queryParameters: {'taskId': taskId},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== 配置相关 ==========

  /// 获取排序配置
  Future<Map<String, dynamic>> getSortConfig() async {
    try {
      final response = await _dio.get('/api/trpc/config.getSortConfig');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取定价配置
  Future<Map<String, dynamic>> getPricingConfig() async {
    try {
      final response = await _dio.get('/api/trpc/config.getPricingConfig');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== 管理员相关 ==========

  /// 获取用户列表（管理员）
  Future<Map<String, dynamic>> getAdminUsers({
    String? search,
    String? role,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trpc/admin.getUsers',
        queryParameters: {
          if (search != null) 'search': search,
          if (role != null) 'role': role,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取统计数据（管理员）
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _dio.get('/api/trpc/admin.getStats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 审核资质
  Future<void> reviewQualification(
    int qualificationId,
    bool approved, {
    String? rejectionReason,
  }) async {
    try {
      await _dio.post(
        '/api/trpc/admin.reviewQualification',
        data: {
          'qualificationId': qualificationId,
          'approved': approved,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 更新用户状态
  Future<void> updateUserStatus(
    int userId,
    bool banned, {
    String? reason,
  }) async {
    try {
      await _dio.post(
        '/api/trpc/admin.updateUserStatus',
        data: {
          'userId': userId,
          'banned': banned,
          if (reason != null) 'banReason': reason,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
