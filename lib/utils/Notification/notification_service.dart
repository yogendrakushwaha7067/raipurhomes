// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:ebroker/data/model/chat/chated_user_model.dart';
import 'package:ebroker/utils/Notification/chat_message_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Ui/screens/chat/chatAudio/widgets/chat_widget.dart';
import '../../Ui/screens/chat/chat_screen.dart';
import '../../data/cubits/chatCubits/get_chat_users.dart';
import 'awsomeNotification.dart';

String currentlyChatingWith = "";

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static LocalAwsomeNotification localNotification = LocalAwsomeNotification();

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;
  static requestPermission() async {}

  void updateFCM() async {
    await FirebaseMessaging.instance.getToken();
    // await Api.post(
    //     // url: Api.updateFCMId,
    //     parameter: {Api.fcmId: token},
    //     useAuthToken: true);
  }

  static handleNotification(RemoteMessage? message, [BuildContext? context]) {
    var notificationType = message?.data['type'] ?? "";

    if (notificationType == "chat") {
      var senderId = message?.data['sender_id'] ?? "";
      var chatMessage = message?.data['message'] ?? "";
      var attachment = message?.data['file'] ?? "";
      var audioMessage = message?.data['audio'] ?? "";
      var time = message?.data['date'] ?? "";

      var username = message!.data['title'];
      var propertyTitleImage = message.data['property_title_image'];
      var propertyTitle = message.data['property_title'];
      var userProfile = message.data['user_profile'];
      var propertyId = message.data['property_id'];

      log("Notification ${message.toMap().toString()}");
      (context as BuildContext).read<GetChatListCubit>().addNewChat(ChatedUser(
          fcmId: "",
          firebaseId: "",
          name: username,
          profile: userProfile,
          propertyId: int.parse(propertyId),
          title: propertyTitle,
          userId: int.parse(senderId),
          titleImage: propertyTitleImage));

      ///Checking if this is user we are chatiing with
      if (senderId == currentlyChatingWith) {
        ChatMessageHandler.add(
          ChatMessage(
            key: ValueKey(DateTime.now().toString().toString()),
            message: chatMessage,
            isSentByMe: false,
            propertyId: "",
            reciverId: "",
            isChatAudio: audioMessage != null && audioMessage != "",
            audioFile: audioMessage,
            attachment: attachment,
            hasAttachment: attachment != "" && attachment != null,
            senderId: senderId,
            time: time,
          ),
        );
        totalMessageCount++;
      } else {
        localNotification.createNotification(
          isLocked: false,
          notificationData: message,
        );
      }
    } else {
      localNotification.createNotification(
          isLocked: false, notificationData: message!);
    }
  }

  static init(context) {
    requestPermission();
    registerListeners(context);
  }

  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    handleNotification(message);
  }

  static forgroundNotificationHandler(BuildContext context) async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleNotification(message, context);
    });
  }

  static terminatedStateNotificationHandler(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }
        handleNotification(message, context);
      },
    );
  }

  static onTapNotificationHandler(context) {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {},
    );
  }

  static registerListeners(context) async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    await forgroundNotificationHandler(context);
    await terminatedStateNotificationHandler(context);
    await onTapNotificationHandler(context);
  }

  static disposeListeners() {
    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
