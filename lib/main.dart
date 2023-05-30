import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ar/dashboard/admin_dashboard.dart';
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
import 'package:ar/pre_dashboard.dart';
import 'package:ar/splash_screen.dart';
import 'package:ar/widget_builder.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/auth.dart';
import 'auth/login_admin.dart';
import 'auth/login_child.dart';
import 'auth/login_parent.dart';
import 'auth/signup_parent.dart';
import 'dashboard/child_dashboard.dart';
import 'dashboard/pages/child_create_form.dart';
import 'dashboard/pages/child_management.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(await AndroidAlarmManager.initialize());
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        "/login_parent": (context) => const ParentLoginPage(),
        "/login_child": (context) => const ChildLoginPage(),
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
          return const AdminLoginPage();
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
