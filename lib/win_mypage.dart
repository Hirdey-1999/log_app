import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:url_launcher/url_launcher.dart';

const String relink = "http://localhost:";
const String googleAuthApi = "https://accounts.google.com/o/oauth2/v2/auth";
const String googleTokenApi = "https://oauth2.googleapis.com/token";

class JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

HttpServer? redirectserver;

class AuthManager {
  Future<oauth2.Credentials> login() async {
    await redirectserver?.close();
    redirectserver = await HttpServer.bind('localhost', 0);
    final relinkURL = relink + redirectserver!.port.toString();
    oauth2.Client authenticatedHttpClient =
        await _getOauthClient(Uri.parse(relinkURL));
    return authenticatedHttpClient.credentials;
  }

  Future<void> redirect(Uri authorizationUri) async {
    if (await canLaunchUrl(authorizationUri)) {
      await launchUrl(authorizationUri);
    } else {
      throw Exception('Can not launch $authorizationUri');
    }
  }

  Future<Map<String, String>> listen() async {
    var request = await redirectserver!.first;
    var params = request.uri.queryParameters;
    await WindowToFront.activate();

    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Please close the tab');

    await request.response.close();
    await redirectserver!.close();
    redirectserver = null;

    return params;
  }

  Future<oauth2.Client> _getOauthClient(Uri redirectUrl) async {
    var grant = oauth2.AuthorizationCodeGrant(
        "308266656267-h42bqpmg4g564qgkjcium9ge6gp8lomt.apps.googleusercontent.com",
        Uri.parse(googleAuthApi),
        Uri.parse(googleTokenApi),
        httpClient: JsonAcceptingHttpClient(),
        secret: "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");

    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: []);
    await redirect(authorizationUrl);
    var responseQueryParameters = await listen();
    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    return client;
  }
}

class AuthService {
  Future<UserCredential> _signInWithFirebase(AuthCredential authCredential) async {

    final FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential;

    try {
      userCredential = await auth.signInWithCredential(authCredential);
    } on FirebaseAuthException catch (error) {
      throw Exception('Could not authenticated $error');
    }
    return userCredential;
  }
  
  Future<User?> signInWithGoogle() async {
   User? user;

   if (Platform.isMacOS||Platform.isWindows||Platform.isLinux) {

      Credentials credentials = await _authManager.login();

      AuthCredential authCredential = GoogleAuthProvider.credential(
           idToken: credentials.idToken,
           accessToken: credentials.accessToken);

      UserCredential userCredential = await _signInWithFirebase(authCredential);
      user= userCredential.user;
    } 
   return user;
  }
}

class winmypage extends StatelessWidget {
  const winmypage({super.key});

  @override
  Widget build(BuildContext context) {
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
            TextButton(child: const Text("G Google"), onPressed: () {}),
            const SizedBox(
              height: 15,
            ),
            TextButton(
              child: Text("Email & Password"),
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context){},
                //   ),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}
