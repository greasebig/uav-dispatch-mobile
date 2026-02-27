import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

/// 认证提供者 - 管理登录状态和用户信息
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// 初始化 - 检查是否有已保存的token
  Future<void> init() async {
    await _apiService.init();
    await _checkAuthStatus();
  }

  /// 检查认证状态
  Future<void> _checkAuthStatus() async {
    try {
      _isLoading = true;
      _error = null;
      
      final token = await _apiService.getToken();
      if (token != null) {
        // 验证token是否有效
        final userInfo = await _apiService.getCurrentUser();
        _currentUser = User.fromJson(userInfo);
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 手机号登录
  Future<bool> loginWithPhone(String phone, String verificationCode) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.loginWithPhone(phone, verificationCode);
      
      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
        _currentUser = User.fromJson(response['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      
      _error = 'Login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String phone) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.sendVerificationCode(phone);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 微信登录
  Future<bool> loginWithWechat(
    String openId,
    String nickname,
    String? email,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.loginWithSocialProvider(
        'wechat',
        openId,
        nickname,
        email,
      );

      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
        _currentUser = User.fromJson(response['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      _error = 'Wechat login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 支付宝登录
  Future<bool> loginWithAlipay(
    String userId,
    String nickname,
    String? email,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.loginWithSocialProvider(
        'alipay',
        userId,
        nickname,
        email,
      );

      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
        _currentUser = User.fromJson(response['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      _error = 'Alipay login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google登录
  Future<bool> loginWithGoogle(
    String googleId,
    String email,
    String displayName,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.loginWithSocialProvider(
        'google',
        googleId,
        displayName,
        email,
      );

      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
        _currentUser = User.fromJson(response['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      _error = 'Google login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
