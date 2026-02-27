# 无人机飞手在线调度平台 - Flutter移动应用

[English](#english) | [中文](#中文)

## 中文

### 📱 项目概述

这是**无人机飞手在线调度平台**的官方Flutter移动应用，支持**Android**和**iOS**平台。该应用为客户、飞手和管理员提供完整的任务调度、支付和数据管理功能。

### ✨ 核心特性

- **多种登录方式**
  - 手机号 + 短信验证码
  - 微信登录
  - 支付宝登录
  - Google登录

- **灵活的地图集成**
  - Google Maps（国际）
  - 高德地图（国内）
  - 腾讯地图（国内）
  - 百度地图（国内）

- **多支付方案**
  - Stripe（国际）
  - 微信支付（国内）
  - 支付宝（国内）

- **完整的功能模块**
  - 客户端：任务发布、支付、评价
  - 飞手端：接单、位置追踪、数据上报
  - 管理后台：用户审核、任务调度、数据分析

### 🚀 快速开始

#### 前置条件
- Flutter 3.10+
- Dart 3.0+
- Android SDK 21+ (Android)
- Xcode 14+ (iOS)

#### 安装

```bash
# 克隆仓库
git clone https://github.com/greasebig/uav-dispatch-mobile.git
cd uav-dispatch-mobile

# 安装依赖
flutter pub get

# 生成代码（如果使用JSON序列化）
flutter pub run build_runner build
```

#### 配置

创建 `lib/config/.env` 文件：

```env
# API配置
API_BASE_URL=http://localhost:3000

# 地图配置
MAP_PROVIDER=google
GOOGLE_MAPS_API_KEY=your_key_here
AMAP_API_KEY=your_key_here
TENCENT_MAP_API_KEY=your_key_here
BAIDU_MAP_API_KEY=your_key_here

# 支付配置
PAYMENT_PROVIDER=stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
WECHAT_APP_ID=your_id
ALIPAY_APP_ID=your_id

# 社交登录
GOOGLE_CLIENT_ID=your_id
```

#### 运行

```bash
# 开发模式
flutter run

# 指定设备
flutter run -d android
flutter run -d ios

# 发布模式
flutter run --release
```

### 📁 项目结构

```
lib/
├── config/              # 配置管理
│   └── app_config.dart  # 应用配置（地图、支付、登录）
├── models/              # 数据模型
│   └── user_model.dart  # 用户模型
├── services/            # 服务层
│   └── api_service.dart # API通信
├── screens/             # 页面
│   ├── login/           # 登录页面
│   ├── customer/        # 客户端页面
│   ├── pilot/           # 飞手端页面
│   └── admin/           # 管理后台页面
├── widgets/             # 可复用组件
├── providers/           # 状态管理
│   └── auth_provider.dart # 认证状态
└── main.dart            # 应用入口
```

### 🔐 安全特性

- **多层认证**
  - OAuth 2.0社交登录
  - JWT Token管理
  - 登录日志记录
  - 异常登录检测

- **数据保护**
  - 敏感数据加密存储
  - HTTPS通信
  - Token黑名单管理

- **支付安全**
  - PCI DSS合规
  - Webhook验证
  - 交易日志记录

### 🗺️ 地图集成

#### Google Maps
```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(39.9, 116.4),
    zoom: 15,
  ),
)
```

#### 高德地图
```dart
import 'package:amap_flutter_map/amap_flutter_map.dart';

AMapView(
  initialCameraPosition: CameraPosition(
    target: LatLng(39.9, 116.4),
    zoom: 15,
  ),
)
```

#### 腾讯地图
```dart
// 使用腾讯地图SDK
```

#### 百度地图
```dart
// 使用百度地图SDK
```

### 💳 支付集成

#### Stripe
```dart
import 'package:flutter_stripe/flutter_stripe.dart';

// 初始化
await Stripe.instance.publishableKey = AppConfig.stripePublishableKey;

// 创建支付
final result = await Stripe.instance.presentPaymentSheet();
```

#### 微信支付
```dart
// 调用微信支付
```

#### 支付宝
```dart
// 调用支付宝支付
```

### 🔑 登录集成

#### 手机号登录
```dart
// 发送验证码
await authProvider.sendVerificationCode(phone);

// 验证码登录
await authProvider.loginWithPhone(phone, verificationCode);
```

#### 微信登录
```dart
// 使用微信SDK
await authProvider.loginWithWechat(openId, nickname, email);
```

#### 支付宝登录
```dart
// 使用支付宝SDK
await authProvider.loginWithAlipay(userId, nickname, email);
```

#### Google登录
```dart
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = GoogleSignIn();
final account = await googleSignIn.signIn();
await authProvider.loginWithGoogle(account!.id, account.email, account.displayName);
```

### 📊 状态管理

使用Provider进行状态管理：

```dart
import 'package:provider/provider.dart';

// 在Widget中使用
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authProvider.isAuthenticated) {
      return HomePage();
    }
    
    return LoginPage();
  },
)
```

### 🧪 测试

```bash
# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test

# 生成覆盖率报告
flutter test --coverage
```

### 📦 构建发布

#### Android

```bash
# 生成APK
flutter build apk --release

# 生成App Bundle
flutter build appbundle --release
```

#### iOS

```bash
# 生成IPA
flutter build ios --release

# 生成Archive
flutter build ios --release --no-codesign
```

### 🐛 故障排除

#### 地图不显示
- 检查API密钥配置
- 验证API已启用
- 检查AndroidManifest.xml和Info.plist

#### 支付失败
- 检查支付配置
- 验证网络连接
- 查看后端日志

#### 登录失败
- 检查OAuth配置
- 验证回调URL
- 查看登录日志

### 📝 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| API_BASE_URL | 后端API地址 | http://localhost:3000 |
| MAP_PROVIDER | 地图提供商 | google, amap, tencent, baidu |
| GOOGLE_MAPS_API_KEY | Google Maps密钥 | AIzaSy... |
| AMAP_API_KEY | 高德地图密钥 | amap_key... |
| PAYMENT_PROVIDER | 支付提供商 | stripe, wechat, alipay |
| STRIPE_PUBLISHABLE_KEY | Stripe公钥 | pk_test_... |

### 🔗 相关项目

- [后端仓库](https://github.com/greasebig/uav-dispatch-platform)
- [Web前端](https://github.com/greasebig/uav-dispatch-platform)

### 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

### 👥 贡献

欢迎提交Issue和Pull Request！

### 📧 联系方式

- 邮件：support@uav-dispatch.com
- 问题报告：[GitHub Issues](https://github.com/greasebig/uav-dispatch-mobile/issues)

---

## English

### 📱 Project Overview

This is the official Flutter mobile application for the **UAV Dispatch Platform**, supporting **Android** and **iOS** platforms. The application provides comprehensive task scheduling, payment, and data management features for customers, pilots, and administrators.

### ✨ Key Features

- **Multiple Login Methods**
  - Phone + SMS verification
  - WeChat login
  - Alipay login
  - Google login

- **Flexible Map Integration**
  - Google Maps (International)
  - Amap (China)
  - Tencent Map (China)
  - Baidu Map (China)

- **Multiple Payment Options**
  - Stripe (International)
  - WeChat Pay (China)
  - Alipay (China)

- **Complete Feature Modules**
  - Customer: Task publishing, payment, rating
  - Pilot: Task acceptance, location tracking, data reporting
  - Admin: User review, task dispatch, data analysis

### 🚀 Quick Start

#### Prerequisites
- Flutter 3.10+
- Dart 3.0+
- Android SDK 21+ (Android)
- Xcode 14+ (iOS)

#### Installation

```bash
git clone https://github.com/greasebig/uav-dispatch-mobile.git
cd uav-dispatch-mobile
flutter pub get
```

#### Configuration

Create `lib/config/.env`:

```env
API_BASE_URL=http://localhost:3000
MAP_PROVIDER=google
GOOGLE_MAPS_API_KEY=your_key_here
PAYMENT_PROVIDER=stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

#### Run

```bash
flutter run
```

### 📁 Project Structure

```
lib/
├── config/              # Configuration
├── models/              # Data models
├── services/            # API services
├── screens/             # UI screens
├── widgets/             # Reusable components
├── providers/           # State management
└── main.dart            # App entry point
```

### 🔐 Security Features

- OAuth 2.0 authentication
- JWT token management
- Login logging
- Anomaly detection
- Data encryption
- HTTPS communication

### 🗺️ Map Integration

Supports Google Maps, Amap, Tencent Map, and Baidu Map with pluggable architecture.

### 💳 Payment Integration

Supports Stripe, WeChat Pay, and Alipay with pluggable architecture.

### 📊 State Management

Uses Provider for state management with AuthProvider for authentication state.

### 🧪 Testing

```bash
flutter test
flutter test integration_test
flutter test --coverage
```

### 📦 Build Release

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 📝 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| API_BASE_URL | Backend API URL | http://localhost:3000 |
| MAP_PROVIDER | Map provider | google, amap, tencent, baidu |
| GOOGLE_MAPS_API_KEY | Google Maps key | AIzaSy... |
| PAYMENT_PROVIDER | Payment provider | stripe, wechat, alipay |
| STRIPE_PUBLISHABLE_KEY | Stripe public key | pk_test_... |

### 🔗 Related Projects

- [Backend Repository](https://github.com/greasebig/uav-dispatch-platform)

### 📄 License

MIT License

### 👥 Contributing

Pull requests are welcome!

### 📧 Contact

- Email: support@uav-dispatch.com
- Issues: [GitHub Issues](https://github.com/greasebig/uav-dispatch-mobile/issues)
