import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/controllers/chat_controller.dart';
import 'package:flutter_chat/app/database/database.dart';
import 'package:get/get.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key}) : super(key: key);

  final previousData = Get.arguments;

  final Database db = Database();

  //final String senderPhone = '01677696277';
  final List messages = [];

  ChatController chatController = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(previousData['second']),
        backgroundColor: Colors.amber[800],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(
                      'flutterChat/${previousData['first']}/${previousData['second']}')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                print(previousData['first']);
                print(previousData['second']);

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text("Loading"));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('no data'),
                  );
                }

                final data = snapshot.data!.docs;
                print('...........................');
                print(data);
                return Center(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 10,
                        child: ListView.builder(
                            itemCount: data.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              // bool i = false;
                              var timeStamp = data[index]['timestamp'].toDate();
                              var time = DateTime.now().difference(timeStamp);

                              //print(data[index].id);
                              // var min = time.inMinutes;
                              // if (min < 60) {
                              //   min;
                              // } else if (min >= 60) {
                              //   // min = (min / 60).toInt();
                              // }
                              // bool show = false;
                              if (previousData['first'] ==
                                  data[index]['sender_phone']) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, top: 5, bottom: 5, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            chatController.isSelect();
                                            print(
                                                '.................................');
                                            print(chatController.showTime);
                                            chatController.showTimeForMessage(
                                              index: index,
                                              isShow: chatController.showTime,
                                              docomentId: data[index].id,
                                              senderNumber:
                                                  previousData['first'],
                                              receiverNumber:
                                                  previousData['second'],
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                                bottomLeft: Radius.circular(30),
                                              ),
                                            ),
                                            child: Text(data[index]['message']),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Visibility(
                                          visible: true,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 5),
                                            child: Text(
                                              // "${time.inMinutes}m ago",
                                              data[index]['show_time'] == true
                                                  ? '${time.inMinutes}m ago'
                                                  : '',
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, top: 5, bottom: 5, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            chatController.isSelect();
                                            print(
                                                '.................................');
                                            print(chatController.showTime);
                                            chatController.showTimeForMessage(
                                              index: index,
                                              isShow: chatController.showTime,
                                              docomentId: data[index].id,
                                              senderNumber:
                                                  previousData['first'],
                                              receiverNumber:
                                                  previousData['second'],
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                                bottomRight:
                                                    Radius.circular(30),
                                              ),
                                            ),
                                            child: Text(data[index]['message']),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Visibility(
                                          visible: true,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: Text(
                                              data[index]['show_time'] == true
                                                  ? '${time.inMinutes}m ago'
                                                  : '',
                                              //"${time}m ago",
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                );
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: 'type message..',
                            border: InputBorder.none),
                        controller: chatController.messageController,
                        onTap: () {
                          // if (chatController
                          //     .messageController.text.isNotEmpty) {
                          //   chatController.sendMessage(
                          //     senderNumber: previousData['first'],
                          //     receiverNumber: previousData['second'],
                          //     msg: chatController.messageController.text,
                          //   );
                          //   chatController.showNotification();
                          //   chatController.messageController.text = '';
                          // }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: IconButton(
                      onPressed: () {
                        if (chatController.messageController.text.isNotEmpty) {
                          chatController.sendMessage(
                            senderNumber: previousData['first'],
                            receiverNumber: previousData['second'],
                            msg: chatController.messageController.text,
                          );
                          // chatController.showNotification(
                          //   senderNumber: previousData['second'],
                          //   msg: chatController.messageController.text,
                          // );
                          chatController.sendPushMessage();
                          chatController.messageController.text = '';
                        }
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
