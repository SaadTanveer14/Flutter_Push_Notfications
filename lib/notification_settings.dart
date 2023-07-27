import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationServices{
   FirebaseMessaging messaging = FirebaseMessaging.instance;
   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationsPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
        alert: true ,
        announcement: true,
        badge:true ,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
      );

      if(settings.authorizationStatus == AuthorizationStatus.authorized){
        print("user granted authorization");
      }
      else if(settings.authorizationStatus == AuthorizationStatus.authorized){
        print("user granted provisional authorization");
      }
      else{
        AppSettings.openAppSettings();
        print("User denied authorization");
      }
   }

  void firebaseInit() async{
    
    await initLocalNotifications(/* BuildContext context, RemoteMessage message */);
    
    FirebaseMessaging.onMessage.listen((message) {

      if(kDebugMode){
        print(message.notification!.title.toString());
        print(message.notification!.body.toString()); 
      }
        showNotifications(message);
     });
  }

  Future<void> showNotifications(RemoteMessage message) async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(

        Random.secure().nextInt(100000).toString(),
        'High importance channel',
        importance:Importance.max,
        
      );

    AndroidNotificationDetails androidNotificationDetails =   AndroidNotificationDetails(
       channel.id.toString(),
       channel.name.toString(),
       channelDescription: 'Your channel description',
       importance: Importance.high,
       priority: Priority.high,
       ticker: 'ticker'
      );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentBanner: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero, (){
      _flutterLocalNotificationsPlugin.show(
          0, 
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
        );
    });

  }

  Future<void> initLocalNotifications(/* BuildContext context, RemoteMessage message */) async{
      var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();

      var initializationSettings = InitializationSettings(
        android: androidInitializationSettings ,
        iOS: iosInitializationSettings
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload){

        }
      );
  }

   Future<String>  getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
   }

   void isTokenRefresh() async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
   }
}