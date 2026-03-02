import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chat_message.dart';

/// 聊天服务 - 处理消息发送、接收和敏感词过滤
class ChatService {
  static const String _baseUrl = '${AppConfig.apiBaseUrl}/api/chat';

  /// 获取对话列表
  static Future<List<Conversation>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Conversation.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  /// 获取历史消息
  static Future<List<ChatMessage>> getMessages(int conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/$conversationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ChatMessage.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  /// 发送消息（自动检测敏感词）
  static Future<ChatMessage?> sendMessage({
    required int receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'receiver_id': receiverId,
          'content': content,
          'type': type.name,
        }),
      );

      if (response.statusCode == 200) {
        return ChatMessage.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// 检查消息是否包含敏感信息（本地预检）
  static SensitiveContentResult checkSensitiveContent(String content) {
    // 手机号正则
    final phoneRegex = RegExp(
      r'1[3-9]\d{9}',
      caseSensitive: false,
    );
    
    // 微信号正则
    final wechatRegex = RegExp(
      r'wx[:：]?\w{5,20}|wechat[:：]?\w{5,20}|微信[:：]?\w{5,20}',
      caseSensitive: false,
    );
    
    // QQ号正则
    final qqRegex = RegExp(
      r'qq[:：]?\d{5,11}|\d{5,11}qq',
      caseSensitive: false,
    );
    
    // 邮箱正则
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    
    // 其他联系方式关键词
    final contactKeywords = [
      '加我', '加微信', '加QQ', '加我微信', '私聊',
      '电话', '手机号', '联系我', '联系方式',
      'v:x', 'vx', 'v信',
    ];

    bool hasPhone = phoneRegex.hasMatch(content);
    bool hasWechat = wechatRegex.hasMatch(content);
    bool hasQQ = qqRegex.hasMatch(content);
    bool hasEmail = emailRegex.hasMatch(content);
    bool hasKeywords = contactKeywords.any((k) => content.toLowerCase().contains(k.toLowerCase()));

    if (hasPhone || hasWechat || hasQQ || hasEmail || hasKeywords) {
      // 替换敏感内容
      String filtered = content;
      filtered = filtered.replaceAll(phoneRegex, '***');
      filtered = filtered.replaceAll(wechatRegex, 'wx: ***');
      filtered = filtered.replaceAll(qqRegex, 'qq: ***');
      filtered = filtered.replaceAll(emailRegex, '***@***.***');

      for (var keyword in contactKeywords) {
        filtered = filtered.replaceAll(RegExp(keyword, caseSensitive: false), '***');
      }

      return SensitiveContentResult(
        hasSensitiveContent: true,
        filteredContent: filtered,
        reasons: [
          if (hasPhone) '包含手机号码',
          if (hasWechat) '包含微信号',
          if (hasQQ) '包含QQ号',
          if (hasEmail) '包含邮箱地址',
          if (hasKeywords) '包含联系方式关键词',
        ],
      );
    }

    return SensitiveContentResult(
      hasSensitiveContent: false,
      filteredContent: content,
      reasons: [],
    );
  }

  /// 标记消息为已读
  static Future<bool> markAsRead(int conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/read/$conversationId'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }
}

/// 敏感内容检测结果
class SensitiveContentResult {
  final bool hasSensitiveContent;
  final String filteredContent;
  final List<String> reasons;

  SensitiveContentResult({
    required this.hasSensitiveContent,
    required this.filteredContent,
    required this.reasons,
  });
}
