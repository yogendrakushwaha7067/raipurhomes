// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:ebroker/Ui/screens/chat/chat_screen.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/Repositories/property_repository.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/cubits/chatCubits/load_chat_messages.dart';
import '../constant.dart';
import '../helper_utils.dart';

class LocalAwsomeNotification {
  AwesomeNotifications notification = AwesomeNotifications();
  init(BuildContext context) {
    requestPermission();

    notification.initialize(
      null,
      [
        NotificationChannel(
            channelKey: Constant.notificationChannel,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            importance: NotificationImportance.High,
            ledColor: Colors.grey)
      ],
      channelGroups: [],
    );
    listenTap(context);
  }

  listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onActionReceivedMethod: NotificationController.onActionReceivedMethod);
  }

  createNotification(
      {required RemoteMessage notificationData, required bool isLocked}) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
            id: Random().nextInt(5000),
            title: notificationData.data["title"],
            // icon: AppIcons.aboutUs,
            hideLargeIconOnExpand: true,
            summary:
                notificationData.data["type"] == "chat" ? "New Message" : null,
            locked: isLocked,
            payload: Map.from(notificationData.data),
            autoDismissible: true,
            body: notificationData.data["body"],
            wakeUpScreen: true,
            notificationLayout: notificationData.data["type"] == "chat"
                ? NotificationLayout.Messaging
                : NotificationLayout.Default,
            groupKey: notificationData.data["id"],
            channelKey: Constant.notificationChannel),
      );
    } catch (e) {
      rethrow;
    }
  }

  requestPermission() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await notification.requestPermissionToSendNotifications(
        channelKey: Constant.notificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );

      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Map<String, String?>? payload = receivedAction.payload;

    if (payload?['type'] == "chat") {
      var username = payload?['title'];
      var propertyTitleImage = payload?['property_title_image'];
      var propertyTitle = payload?['property_title'];
      var userProfile = payload?['user_profile'];
      var senderId = payload?['sender_id'];
      var propertyId = payload?['property_id'];
      Future.delayed(
        Duration.zero,
        () {
          Navigator.push(Constant.navigatorKey.currentContext!,
              MaterialPageRoute(
            builder: (context) {
              return BlocProvider(
                create: (context) => LoadChatMessagesCubit(),
                child: Builder(builder: (context) {
                  return ChatScreen(
                      profilePicture: userProfile!,
                      userName: username ?? "",
                      propertyImage: propertyTitleImage ?? "",
                      proeprtyTitle: propertyTitle ?? "",
                      userId: senderId ?? "",
                      propertyId: propertyId ?? "");
                }),
              );
            },
          ));
        },
      );
    } else {
      String id = receivedAction.payload?["id"] ?? "";

      DataOutput<PropertyModel> property =
          await PropertyRepository().fetchPropertyFromPropertyId(id);

      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.goToNextPage(Routes.propertyDetails,
              Constant.navigatorKey.currentContext!, false,
              args: {
                'propertyData': property.modelList[0],
                'propertiesList': property.modelList,
                'fromMyProperty': false,
              });
        },
      );
    }
  }
}
