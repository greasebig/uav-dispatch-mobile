/// 用户模型
class User {
  final int id;
  final String openId;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String role; // 'customer', 'pilot', 'admin'
  final String? loginMethod; // 'phone', 'wechat', 'alipay', 'google', 'manus'
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastSignedIn;

  User({
    required this.id,
    required this.openId,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    required this.role,
    this.loginMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSignedIn,
  });

  /// 从JSON创建用户对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      openId: json['openId'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'customer',
      loginMethod: json['loginMethod'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSignedIn: DateTime.parse(json['lastSignedIn'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'openId': openId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'loginMethod': loginMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSignedIn': lastSignedIn.toIso8601String(),
    };
  }

  /// 检查是否是客户
  bool get isCustomer => role == 'customer';

  /// 检查是否是飞手
  bool get isPilot => role == 'pilot';

  /// 检查是否是管理员
  bool get isAdmin => role == 'admin';

  /// 复制对象
  User copyWith({
    int? id,
    String? openId,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    String? loginMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSignedIn,
  }) {
    return User(
      id: id ?? this.id,
      openId: openId ?? this.openId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      loginMethod: loginMethod ?? this.loginMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSignedIn: lastSignedIn ?? this.lastSignedIn,
    );
  }
}
