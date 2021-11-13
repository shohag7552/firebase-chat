import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/database/database.dart';
import 'package:flutter_chat/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  TextEditingController messageController = TextEditingController();

  Database db = Database();
  //List messages = [].obs;
  var showTime = false;
  String? token;
  String? receiverToken = '';

  getReceiverToken({String? receiverNumber}) async {
    print('here for take tolen');
    var query = await FirebaseFirestore.instance
        .collection('flutterChat')
        .doc(receiverNumber)
        .get();

    var a = query.data();
    if (a != null) {
      receiverToken = a['token'];
      update();
    }

    print(query.data());
    print(a!['token']);
    print('token got');
  }

  isSelect() {
    showTime = !showTime;
    update();
  }

  void showTimeForMessage(
      {int? index,
      bool? isShow,
      String? senderNumber,
      String? docomentId,
      String? receiverNumber}) async {
    await FirebaseFirestore.instance
        .collection('flutterChat')
        .doc(senderNumber!)
        .collection(receiverNumber!)
        .doc(docomentId!)
        .update({'show_time': isShow});
  }

  void sendMessage(
      {String? senderNumber, String? receiverNumber, String? msg}) async {
    print('me is here');
    print(senderNumber);
    print(receiverNumber);

    await FirebaseFirestore.instance
        .collection('flutterChat')
        .doc(senderNumber!)
        .set(
      {
        'token': token,
        'sender': senderNumber,
      },
    );

    await FirebaseFirestore.instance
        .collection('flutterChat')
        .doc(senderNumber)
        .collection(receiverNumber!)
        .doc()
        .set(
      {
        'message': msg,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'sender_phone': senderNumber,
        'show_time': false,
        'token': token,
      },
    );
    await FirebaseFirestore.instance
        .collection('flutterChat')
        .doc(receiverNumber)
        .collection(senderNumber)
        .doc()
        .set(
      {
        'message': msg,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'sender_phone': senderNumber,
        'show_time': false,
        'token': ''
      },
    );
    print('successful');

    sendPushMessage(
        receiverToken: receiverToken, senderNumber: senderNumber, message: msg);
  }

  @override
  void onInit() {
    super.onInit();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });
    getToken();
  }

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    print('token is : $token');
  }

  Future<void> sendPushMessage(
      {String? receiverToken, String? senderNumber, String? message}) async {
    if (receiverToken == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      log('.........................here is for json pass');
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAO4ffSsg:APA91bESoSG8rCBlF8sm2ObDvSmWZjSdxGoGDq3euhN-RaVROON5LTPrRjBFw_tUUqfsQyXuh8N4RVlV8OJOYlZmHfEEgUfTOOTm1qiZJ9CTUoh5DKrTn82p8m_KSkuhNiKvptEKnMnz',
        },
        body: jsonEncode({
          "to": receiverToken,
          "notification": {
            "title": "From: $senderNumber",
            "body": "$message",
            "OrganizationId": "2",
            "content available": true,
            "priority": "high",
            "subtitle": "Elementary School",
            "Title": "hello"
          },
          "data": {
            "priority": "high",
            "sound": "app_sound.wav",
            "content_available": true,
            "bodyText": "New announcement assigned",
            "organization": "xyz School"
          }
        }),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  void showNotification({String? senderNumber, String? msg}) {
    flutterLocalNotificationsPlugin.show(
      0,
      "From:$senderNumber",
      "message:$msg",
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            importance: Importance.high,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher'),
      ),
    );
  }
}
