import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ar/dashboard/admin_dashboard.dart';
import 'package:ar/dashboard/child_journeys_view.dart';
import 'package:ar/dashboard/pages/admin_create.dart';
import 'package:ar/dashboard/pages/admin_manage.dart';
import 'package:ar/dashboard/pages/child_management_admin.dart';
import 'package:ar/dashboard/pages/parent_create.dart';
import 'package:ar/dashboard/pages/parent_manage.dart';
import 'package:ar/dashboard/parent_dashboard.dart';
import 'package:ar/dashboard/profile/child_profile.dart';
import 'package:ar/dashboard/profile/edit/child_profile_edit.dart';
import 'package:ar/dashboard/profile/parent_profile.dart';
import 'package:ar/dashboard/profile/edit/parent_profile_edit.dart';
import 'package:ar/index.dart';
import 'package:ar/pages/child_dashboard/child_dashboard_widget.dart';
import 'package:ar/pre_dashboard.dart';
import 'package:ar/splash_screen.dart';
import 'package:ar/widget_builder.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth.dart';
import 'auth/login_admin.dart';
import 'auth/signup_parent.dart';
import 'dashboard/maps/notification.dart';
import 'dashboard/pages/child_create_form.dart';
import 'dashboard/pages/child_management.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'instructions/instructions_widget.dart';
import 'login_child/login_child_widget.dart';
import 'login_parent/login_parent_widget.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(await AndroidAlarmManager.initialize());
  cameras = await availableCameras();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  if(await service.isRunning()){
    service.invoke("stopService");
  }

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Child Notification service',
      initialNotificationContent: 'running',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  await NotificationAPI.init();

  await Firebase.initializeApp();

  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the FCM message received in the background
  print('Received message in background: ${message.notification?.title}');

  if(Auth().currentUser == null){
    return;
  }

  var email = Auth().currentUser!.email;
  email ??= "";

  if(!await Auth().checkIfParent(email)){
    return;
  }

  var notifierUsername = message.data['username'];

  var childNotificationIsMine = message.data['parentId'] == Auth().currentUser!.uid;

  if(childNotificationIsMine) {
    NotificationAPI.showNotifications(
        title: message.notification?.title,
        body: message.notification?.body);
  }


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color.fromRGBO(62, 154, 171, 1),
        ),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "/home": (context) => const SessionChecker(),
        "/login_admin": (context) => const AdminLoginPage(),
        "/login_parent": (context) => const LoginParentWidget(),
        "/login_child": (context) => const LoginChildWidget(),
        "/signup_parent": (context) => const ParentSignUpPage(),
        "/dashboard_admin": (context) => const AdminDashboard(),
        "/dashboard_parent": (context) => const ParentDashboardPage(),
        "/dashboard_child": (context) => const ChildDashboardPage(),
        "/dashboard/admin_management": (context) => const AdminManagement(),
        "/dashboard/admin_management/create": (context) =>
            const AdminCreateForm(),
        "/dashboard/parent_management": (context) => const ParentManagement(),
        "/dashboard/parent_management/create": (context) =>
            const ParentCreation(),
        "/dashboard/child_list": (context) => const ChildListAdmin(),
        "/dashboard/child_management": (context) => const ChildManagementPage(),
        "/dashboard/child_management/create": (context) =>
            const CreateChildPage(),
        "/dashboard/profile_parent": (context) => const ParentProfile(),
        "/dashboard/profile_parent/edit": (context) =>
            const ParentProfileEdit(),
        "/dashboard/profile_child": (context) => const ChildProfile(),
        "/dashboard/profile_child/edit": (context) => const ChildProfileEdit(),
        "/child_journey_view": (context) => const ChildJourneysView(),
        "/instructions_view": (context) => const InstructionsWidget()
      },
    );
  }
}

class SessionChecker extends StatefulWidget {
  const SessionChecker({Key? key}) : super(key: key);

  @override
  State<SessionChecker> createState() => _SessionCheckerState();
}

class _SessionCheckerState extends State<SessionChecker> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const PreDashboard();
        } else {
          return const LoginChooserWidget();
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "AR Mobile",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  userButton(context, "Login as Admin", () {
                    Navigator.pushNamed(context, "/login_admin");
                  }),
                  userButton(context, "Login as Parent", () {
                    Navigator.pushNamed(context, "/login_parent");
                  }),
                  userButton(context, "Login as Child", () {
                    Navigator.pushNamed(context, "/login_child");
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
