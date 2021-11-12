import 'dart:convert';

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

  // sendMessage({String? msg, String? senderNumber, String? receiverNumber}) {
  //   print('here');
  //   db.create(
  //       senderNumber: senderNumber, msg: msg, receiverNumber: receiverNumber);
  // }

  // initialReadMessage() async {
  //   isLoading(true);
  //   await db
  //       .readMessageData(
  //           senderNumber: '01677696277', receiverNumber: '01838320622')
  //       .then((value) {
  //     if (value.isNotEmpty) {
  //       messages.clear();
  //       messages.addAll(value);
  //       isLoading(false);
  //     }
  //   }, onError: (err) {
  //     print(err);
  //     isLoading(false);
  //   });
  //   print(messages);
  //   update();
  // }

  // callData() {
  //   final Stream<QuerySnapshot> messengers = FirebaseFirestore.instance
  //       .collection('flutter chat')
  //       .doc('01677696277')
  //       .collection('01838320622')
  //       .orderBy('timestamp')
  //       .snapshots();
  // }

  // sendNotification() {
  //   FirebaseMessaging.onMessage.listen((e) {
  //     RemoteNotification notification = e.notification!;
  //     AndroidNotification android = e.notification!.android!;
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel.id,
  //             channel.name,
  //             color: Colors.black,
  //             playSound: true,
  //             icon: '@mipmap/ic_launcher',
  //           ),
  //         ),
  //       );
  //     }
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((event) {
  //     print('new onmessage published');
  //     RemoteNotification notification = event.notification!;
  //     AndroidNotification android = event.notification!.android!;
  //     if (notification != null && android != null) {
  //       print('you are here');
  //     }
  //   });
  // }

  // showNotification2() {
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     'sender number',
  //     "message body",
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         color: Colors.black,
  //         playSound: true,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //     ),
  //   );
  // }

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
        .collection(receiverNumber!)
        .doc()
        .set(
      {
        'message': msg,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'sender_phone': senderNumber,
        'show_time': false,
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
      },
    );
    print('successful');
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

  Future<void> sendPushMessage() async {
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      print('here');
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            'to': token,
            'notification': {
              'body': 'New announcement assigned',
              'OrganizationId': '2',
              'content available': true,
              'priority': 'high'
            },
            'data': {'priority': 'high'}
          },
        ),
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
