import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Use a trusted backend or Supabase Edge Function to send server-side FCM messages.
const String FCM_SERVER_KEY = 'YOUR_FCM_SERVER_KEY';

// Interface for notifications
abstract class NotificationService {
  Future<void> requestPermission();
  Future<void> subscribeAll();
  Future<void> sendNewPostNotification(PostModel post);
  Future<void> initialize();
  Future<void> sendTestNotification();
}

class PlaceholderNotificationService implements NotificationService {
  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> subscribeAll() async {}

  @override
  Future<void> sendNewPostNotification(PostModel post) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> sendTestNotification() async {}
}

class FCMNotificationService implements NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _awesomeNotificationsInitialized = false;

  @override
  Future<void> requestPermission() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> subscribeAll() async {
    await _messaging.subscribeToTopic('all');
  }

  @override
  Future<void> sendNewPostNotification(PostModel post) async {
    try {
      if (!_awesomeNotificationsInitialized) {
        await initialize();
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );
      final title = 'New Post by ${post.createdByName}';
      final body = post.description.isNotEmpty
          ? (post.description.length > 100
                ? '${post.description.substring(0, 100)}...'
                : post.description)
          : 'New post shared!';

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'new_post_channel',
          title: title,
          body: body,
          notificationLayout: (post.mediaUrl?.isNotEmpty ?? false)
              ? NotificationLayout.BigPicture
              : NotificationLayout.BigText,
          bigPicture: (post.mediaUrl?.isNotEmpty ?? false)
              ? post.mediaUrl
              : null,
          payload: {'post_id': post.id, 'user_id': post.createdBy},
        ),
      );

      await _sendFCMNotification(post);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _sendFCMNotification(PostModel post) async {
    try {
      if (FCM_SERVER_KEY.isEmpty || FCM_SERVER_KEY.startsWith('<')) {
        return;
      }

      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final title = 'New Post by ${post.createdByName}';
      final body = post.description.isNotEmpty
          ? (post.description.length > 100
                ? '${post.description.substring(0, 100)}...'
                : post.description)
          : 'New post shared!';

      final payload = {
        'to': '/topics/all',
        'notification': {
          'title': title,
          'body': body,
          if (post.mediaUrl?.isNotEmpty ?? false) 'image': post.mediaUrl,
        },
        'data': {'post_id': post.id, 'user_id': post.createdBy},
      };

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$FCM_SERVER_KEY',
        },
        body: jsonEncode(payload),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> initialize() async {
    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'new_post_channel',
          channelName: 'New Posts',
          channelDescription: 'Notifications for new posts',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledOnMs: 1000,
          ledOffMs: 500,
        ),
      ], debug: kDebugMode);

      _awesomeNotificationsInitialized = true;
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> sendTestNotification() async {
    try {
      if (!_awesomeNotificationsInitialized) {
        await initialize();
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'new_post_channel',
          title: 'Test Notification',
          body: 'This is a test notification to verify the system is working!',
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    } catch (e) {
      // Handle error silently
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message silently
}
