import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Utils {
  static void toastMessage(String message, Color color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  String todayDate() {
    DateFormat dateFormat = DateFormat('dd MMM yyyy');
    String todayDateString = dateFormat.format(DateTime.now());
    return todayDateString;
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago';
    } else {
      return DateFormat('dd MMM yyyy')
          .format(dateTime); // If older than a week, show the full date
    }
  }

  Future<String> uploadFileToCloudinary(
      String filePath, BuildContext context) async {
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('https://api.cloudinary.com/v1_1/dds1bndwj/upload'));
      request.fields['api_key'] = '575478373865487';
      request.fields['api_secret'] = 'pyFXRjFch-a7UCZnPo2glFdm9g8';
      request.fields['upload_preset'] = 'queme.io';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response =
          await streamedResponse.stream.bytesToString().then((responseBody) {
        return http.Response(responseBody, streamedResponse.statusCode,
            headers: streamedResponse.headers);
      });
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String uploadedUrl = jsonResponse['secure_url'];

        log('File uploaded successfully to Cloudinary: $uploadedUrl');
        return uploadedUrl;
      } else {
        print(
            'Failed to upload file to Cloudinary. Status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      log('Error uploading file to Cloudinary: $e');
      return '';
    }
  }
}

Future<Map<String, dynamic>?> getCurrentUserData() async {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  try {
    final User? user = auth.currentUser;
    if (user == null) {
      print("No user is currently logged in.");
      return null;
    }

    final DataSnapshot snapshot =
        await dbRef.child('Users').child(user.uid).get();

    if (snapshot.exists) {
      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      return userData;
    } else {
      print("User data not found.");
      return null;
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return null;
  }
}

DateTime calculateFutureDate({required String frequency}) {
  DateTime date = DateTime.now();

  switch (frequency.toLowerCase()) {
    case 'daily':
      return date.add(Duration(days: 1));
    case 'weekly':
      return date.add(Duration(days: 7));
    case 'monthly':
      return DateTime(date.year, date.month + 1, date.day);
    case 'yearly':
      return DateTime(date.year + 1, date.month, date.day);
    case 'one-time':
      return date; // Returns the current date for one-time
    case 'free':
      return date.add(Duration(days: 7)); // Provides a 7-day trial
    default:
      throw ArgumentError('Invalid frequency: $frequency');
  }
}
