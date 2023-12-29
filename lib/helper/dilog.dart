import 'dart:convert';
import 'dart:io';

import 'package:chat_app/modles/chatuser.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../modles/message.dart';
class dilog{
  static void showSnackbar(BuildContext context,
      String msg){
    ScaffoldMessenger.of(context).showSnackBar(
        (SnackBar(content: Text(msg))));
  }
  static void showProgres(BuildContext context){
    showDialog(
      context: context,
    builder: (_)=>
     const Center(child: CircularProgressIndicator()));
    }
}
//apis work
class apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  static Future<void>getFirebaseMessagingToken()async {
    await fmessaging.requestPermission();

    fmessaging.getToken().then((t) {
      if(t!=null) {
        me.pushToken = t;
        print('Push Token :$t');
      }
    });
  }
  static late ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  static Future<bool> userExists() async {
    return (await firestore.collection('user').
    doc(auth.currentUser!.uid).
    get()).exists;
  }

//here userr forshort cut
  static Future<void> createuser() async {
    final time = DateTime
        .now()
        .
    millisecondsSinceEpoch
        .toString();
    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      about: "Hey, I'm using Chat App",
      name: user.displayName.toString(),
      createdAt: time,
      isOnline: false,
      id: user.uid,
      lastActive: time,
      email: user.email.toString(),
      pushToken: '',
    );
    final userdata = chatUser.toJson();
    return await firestore.collection('users').
    doc(user.uid).
    set(userdata);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
   // log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds) //because empty list throws an error
    // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> getselfdata() async {
    await firestore.collection('users').
    doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
       await getFirebaseMessagingToken();
      } else {
        await createuser().then((value) => getselfdata());
      }
    });
  }

  static Future<void> updateuserinfo() async {
    await firestore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,

    });
  }

  static Future<void> updatepicture(File file) async {
    final ext = file.path
        .split('.')
        .last;
    final ref = storage.ref()
        .child('Profile Picture${user.uid}.$ext');
    await ref.putFile(file,
        SettableMetadata(contentType: 'images/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection("users").doc(user.uid).update({
      'image': me.image,


    });
  }

  static String getConversationID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }


//for messages to save firebase
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()});
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getlastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
       .orderBy('sent' , descending: true)
        .limit(1).snapshots();
    }
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats_App"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAQiyyN-Y:APA91bHiCS11ayOEoKVbj0dI0iJGQRLgzrlRe5N02H6-viPsSBl57kXIVK1nS5CjxkPCE18GLjzfue_fK12_-LXeak6iT0pFE4CAiKb8q7dDUoJyZlXvIczVxlCQoVhsul3PMS64xSzu'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    print('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      print('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

}

