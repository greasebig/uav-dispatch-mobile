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

  /// 手机号登录
  Future<Map<String, dynamic>> loginWithPhone(
    String phone,
    String verificationCode,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/auth.loginWithPhone',
        data: {
          'phone': phone,
          'verificationCode': verificationCode,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 发送验证码
  Future<void> sendVerificationCode(String phone) async {
    try {
      await _dio.post(
        '/api/trpc/auth.sendVerificationCode',
        data: {'phone': phone},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 社交登录
  Future<Map<String, dynamic>> loginWithSocialProvider(
    String provider,
    String providerId,
    String? name,
    String? email,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/auth.loginWithSocialProvider',
        data: {
          'provider': provider, // 'wechat', 'alipay', 'google'
          'providerId': providerId,
          'name': name,
          'email': email,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取任务列表
  Future<List<Map<String, dynamic>>> getTasks({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trpc/task.listTasks',
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

  /// 创建任务
  Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/task.createTask',
        data: taskData,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 接受任务
  Future<Map<String, dynamic>> acceptTask(int taskId) async {
    try {
      final response = await _dio.post(
        '/api/trpc/task.acceptTask',
        data: {'taskId': taskId},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

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
  Future<Map<String, dynamic>> rateTask(
    int taskId,
    Map<String, dynamic> ratingData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/trpc/data.rateTask',
        data: {
          'taskId': taskId,
          ...ratingData,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
