import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:nyoba/models/UserModel.dart';
import 'package:nyoba/pages/notification/NotificationScreen.dart';
import 'package:nyoba/utils/GlobalVariable.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Session {
  static SharedPreferences data;
  static FirebaseMessaging messaging;

  static Future init() async {
    data = await SharedPreferences.getInstance();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      printLog(value, name: 'Device Token');
      data.setString('device_token', value);
    });

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        description: 'This channel is used for important notifications.',
        showBadge: true,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: Colors.deepPurple);
    // var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("message recieved");
      print(event.notification.body);
      print(event.notification.android.imageUrl);
      printLog(event.data.toString(), name: 'Message Click');
      RemoteNotification notification = event.notification;
      AndroidNotification android = event.notification?.android;
      if (notification != null && android != null) {
        if (event.notification.android.imageUrl != null) {
          await showBigPictureNotificationURL(event.notification.android.imageUrl).then((value) {
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    icon: 'transparent',
                    channelDescription: channel.description,
                    styleInformation: value,
                    fullScreenIntent: true,
                  ),
                ));
          });
        } else {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'transparent',
                channelDescription: channel.description,
              ),
            ),
          );
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('Message clicked!');
      printLog(message.notification.toString());
      printLog(message.data.toString(), name: 'Message Click');

      if (message.data['type'] == 'order') {
        Navigator.of(GlobalVariable.navState.currentContext).push(MaterialPageRoute(builder: (context) => NotificationScreen()));
      } else {
        if (await canLaunch(message.data['click_action'])) {
          await launch(message.data['click_action']);
        } else {
          throw 'Could not launch ${message.data['click_action']}';
        }
      }
    });
  }

  static Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  static Future<BigPictureStyleInformation> showBigPictureNotificationURL(String url) async {
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));
    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(bigPicture, largeIcon: largeIcon);
    return bigPictureStyleInformation;
  }

  Future saveUser(UserModel user, String cookie) async {
    data.setBool('isLogin', true);
    data.setInt("id", user.id);
    data.setString("username", user.username);
    data.setString("avatar", user.avatar ?? '');
    data.setString("firstname", user.firstname);
    data.setString("lastname", user.lastname);
    data.setString("displayname", user.displayName);
    data.setString("nickname", user.nickname);
    data.setString("nicename", user.niceName);
    data.setString("description", user.description);
    data.setString("email", user.email);
    data.setString("cookie", cookie);
    data.setString("role", user.role.isNotEmpty ? user.role.first : "");
  }

  void removeUser() async {
    data.setBool('isLogin', false);
    data.remove("id");
    data.remove("username");
    data.remove("avatar");
    data.remove("firstname");
    data.remove("lastname");
    data.remove("displayname");
    data.remove("nickname");
    data.remove("nicename");
    data.remove("description");
    data.remove("email");
    data.remove("cookie");
    data.remove("role");
  }

  Future<String> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    return token;
  }
}
