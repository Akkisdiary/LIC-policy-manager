import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import './screens/auth_screen.dart';
import './screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  Widget inplace(Widget temp) {
    return Scaffold(
      body: Center(child: temp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIC Database',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext ctx, AsyncSnapshot userSnapshot) {
          if (userSnapshot.hasData && userSnapshot.data.emailVerified) {
            return Home();
          } else if (userSnapshot.connectionState == ConnectionState.waiting) {
            return inplace(const CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return inplace(const Text(
                "Something went wrong...\nPlease contect service provider\nMob no.: 9595342495"));
          } else {
            return AuthScreen();
          }
        },
      ),
    );
  }
}
