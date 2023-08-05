import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roll_dice/Main_screen.dart';

class logemail extends StatelessWidget {
  const logemail({super.key});

  @override
  Widget build(context) {
    TextEditingController emailcontroller = TextEditingController();
    TextEditingController passwordcontroller = TextEditingController();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Email Field
            
            TextField(
              controller: emailcontroller,
              decoration:const InputDecoration(
                border: InputBorder.none,
                hintText: "email",
              ),
            ),
            // Password Field
            
            TextField(
              controller: passwordcontroller,
              decoration:const InputDecoration(
                border: InputBorder.none,
                hintText: "password",
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: emailcontroller.text,
                          password: passwordcontroller.text);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainScreen(),));
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Weak Password Used"),
                    ));
                  }
                  else if (e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Email Already Exists"),
                    ));
                  }
                }
                catch(e){
                  print(e);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
