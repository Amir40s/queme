import 'dart:convert';
import 'dart:developer';

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
