import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roll_dice/Main_screen.dart';
import 'package:roll_dice/firebase_options.dart';
import 'package:roll_dice/login/log_email.dart';
import 'package:roll_dice/win_mypage.dart';

Future<void> main() async {
  if (Platform.isWindows) {
    runApp(winmypage());
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(MyPage());
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: homeScreen(),
    );
  }
}

class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<UserCredential> signgoogle() async {
      final GoogleSignInAccount? guser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? gauth = await guser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gauth?.accessToken,
        idToken: gauth?.idToken,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
      return FirebaseAuth.instance.signInWithCredential(credential);
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Sign In Using "),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              child: const Text("G Google"),
              onPressed: () => signgoogle(),
            ),
            const SizedBox(
              height: 15,
            ),
            TextButton(
              child: Text("Email & Password"),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => logemail(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
