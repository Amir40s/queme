import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SendNotification {
  Future<void> sendNotification(String message) async {
    var status = await OneSignal.User.getOnesignalId();
    String? playerId = status;
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'ZmQzNzZiNTEtYzI4NS00YzkzLWE5MGItYWRlYWQ0NWIyNDg3'
    };
    print(playerId);

    final body = jsonEncode({
      'app_id': '9e0e893c-a777-4670-b0e6-8bfd077f7b46',
      'include_player_ids': [playerId],
      'contents': {'en': message},
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Notification sent successfully.");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  }

  Future<void> generateDeviceId() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    if (token != null) {
      print('Device ID: $token');
    } else {
      print('Failed to get device ID');
    }
  }
}
