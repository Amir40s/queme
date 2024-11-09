import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static const DarwinNotificationDetails _iOSNotificationDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await setupFlutterNotifications();
    await requestNotificationPermissions();
    configureFirebaseListeners();
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> setupFlutterNotifications() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  Future<void> requestNotificationPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a foreground message: ${message.notification?.title}");
      showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      showForegroundNotification(message);
    });
  }

  void handleMessage(RemoteMessage message) {
    print("Handling message: ${message.notification?.title}");

    final additionalData = message.data;

    if (additionalData.isNotEmpty) {}
  }

  void showForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: _iOSNotificationDetails,
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<String> _getAccessToken() async {
    final String jsonString =
        await rootBundle.loadString('android/app/messaging_services.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final serviceAccount = ServiceAccountCredentials.fromJson(jsonData);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  Future<void> sendNotification(String token, String title, String body,
      {Map<String, dynamic>? additionalData}) async {
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();
    http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': additionalData,
          },
        },
      ),
    );
  }

  Future<String> _getProjectId() async {
    final String jsonString =
        await rootBundle.loadString('android/app/messaging_services.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData['project_id'];
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = jsonDecode(response.payload!);

      // Use handleMessage for consistent navigation
      handleMessage(RemoteMessage(data: data));
    }
  }
}
