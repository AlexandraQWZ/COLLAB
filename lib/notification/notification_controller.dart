import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collab_mitra/pages/tips.dart';
import 'package:flutter/material.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {
    if (receivedAction.channelKey == "anggaran") {
      if (receivedAction.buttonKeyPressed == "open_notify") {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TipsPage(),
        ));
      }
    }
  }
}