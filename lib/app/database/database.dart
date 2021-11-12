import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void create(
      {String? senderNumber, String? receiverNumber, String? msg}) async {
    try {
      print('me is here');
      print(senderNumber);
      print(receiverNumber);

      // await FirebaseFirestore.instance.collection('flutter').add(
      //   {
      //     'sender_phone': senderNumber,
      //     'receiver_phone': receiverNumber,
      //     'message': msg,
      //     'timestamp': FieldValue.serverTimestamp()
      //   },
      // );
      await firestore
          .collection('flutter chat')
          .doc(senderNumber.toString())
          .collection(receiverNumber.toString())
          .doc()
          .set(
        {
          'message': msg,
          'timestamp': FieldValue.serverTimestamp(),
          'sender_phone': senderNumber,
        },
      );
      await firestore
          .collection('flutter chat')
          .doc(receiverNumber)
          .collection(senderNumber.toString())
          .doc()
          .set(
        {
          'message': msg,
          'timestamp': FieldValue.serverTimestamp(),
          'sender_phone': senderNumber,
        },
      );
      print('successful');
    } catch (e) {
      print(e);
    }
  }

  Future<List> readMessageData(
      {String? senderNumber, String? receiverNumber}) async {
    QuerySnapshot querySnapshot;
    List dataList = [];

    try {
      querySnapshot = await firestore
          .collection('flutter chat')
          .doc(senderNumber!)
          .collection(receiverNumber!)
          .orderBy('timestamp')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            'message': doc['message'],
            'sender_phone': doc['sender_phone'],
          };
          dataList.add(a);
        }
        return dataList;
      }
    } catch (e) {
      print(e);
    }
    return dataList;
  }
}
