/// 应用配置管理
class AppConfig {
  // API配置
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  // 地图配置
  static const String mapProvider = String.fromEnvironment(
    'MAP_PROVIDER',
    defaultValue: 'google', // 可选: google, amap, tencent, baidu
  );
  
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  
  static const String amapApiKey = String.fromEnvironment(
    'AMAP_API_KEY',
    defaultValue: '',
  );
  
  static const String tencentMapApiKey = String.fromEnvironment(
    'TENCENT_MAP_API_KEY',
    defaultValue: '',
  );
  
  static const String baiduMapApiKey = String.fromEnvironment(
    'BAIDU_MAP_API_KEY',
    defaultValue: '',
  );
  
  // 支付配置
  static const String paymentProvider = String.fromEnvironment(
    'PAYMENT_PROVIDER',
    defaultValue: 'stripe', // 可选: stripe, wechat, alipay
  );
  
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  
  static const String wechatAppId = String.fromEnvironment(
    'WECHAT_APP_ID',
    defaultValue: '',
  );
  
  static const String alipayAppId = String.fromEnvironment(
    'ALIPAY_APP_ID',
    defaultValue: '',
  );
  
  // 登录配置
  static const bool enablePhoneLogin = true;
  static const bool enableWechatLogin = true;
  static const bool enableAlipayLogin = true;
  static const bool enableGoogleLogin = true;
  
  // 应用信息
  static const String appName = 'UAV Dispatch';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // 功能开关
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableAnomalousLoginDetection = true;
}
