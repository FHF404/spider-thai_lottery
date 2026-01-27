import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thai_lottery/services/api_service.dart';
import 'package:thai_lottery/models/lottery_result.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> init() async {
    // 1. 初始化时区数据
    tz.initializeTimeZones();
    
    // 记录应用启动事件
    await _analytics.logAppOpen();

    // 2. Android 设置
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS 设置
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. 初始化本地通知插件
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // 处理点击通知后的逻辑
      },
    );

    // 5. 进行基础 FCM 配置 (静默订阅)
    await _setupFcm();
  }

  Future<void> _setupFcm() async {
    // 处理前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? '新消息',
          message.notification!.body ?? '',
        );
      }
    });

    // 订阅主题
    await _fcm.subscribeToTopic('lottery_updates');
  }

  /// 明确请求权限
  Future<bool> requestPermission() async {
    // 1. 先用 Firebase 请求 (对 iOS 比较有效，Android 也会尝试)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. 针对 Android 13+，使用专用权限包再次确认，确保系统弹窗出现
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    
    // 3. 尝试获取 Token (这往往能强制触发与 Firebase 的连接)
    try {
      String? token = await _fcm.getToken();
      if (token != null) print("FCM Token: $token");
    } catch (e) {
      print("Error getting token: $e");
    }
    
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> isPermissionGranted() async {
    // 综合判断系统权限和 Firebase 设置
    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    
    NotificationSettings settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      '远程推送通知',
      channelDescription: '来自 Firebase 的开奖通知',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      '测试通知',
      channelDescription: '用于验证通知功能是否正常',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _notificationsPlugin.show(
      0,
      '测试通知',
      '恭喜！您的远程推送与数据统计功能已准备就绪 🔔',
      details,
    );
  }
}
