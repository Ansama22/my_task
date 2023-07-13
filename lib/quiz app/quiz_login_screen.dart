import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_task/quiz%20app/quiz_admin_screen.dart';
import 'package:my_task/quiz%20app/quiz_main_screen.dart';
import 'package:my_task/quiz%20app/quiz_register_screen.dart';

class QuizLoginScreen extends StatefulWidget {
  QuizLoginScreen({Key? key}) : super(key: key);

  @override
  State<QuizLoginScreen> createState() => _QuizLoginScreenState();
}

class _QuizLoginScreenState extends State<QuizLoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.email,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  labelText: "Password"),
            ),
            const SizedBox(height: 15),
            const Text("Forget your password ?"),
            const SizedBox(height: 15),
            Row(
              // Main  => Horizontal
              // Cross => Vertical
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2 / 3
                Expanded(
                  child: MaterialButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () => login(context),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 1 / 3
                Expanded(
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    onPressed: () => navigateToRegisterScreen(),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void login(BuildContext context) {
    String email = emailController.text;

    String password = passwordController.text;

    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    firebaseAuth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      checkUserType();
    }).catchError((error) {
      print(error);
      showErrorToast(error.toString());
    });
  }

  void showErrorToast(String errorMessage) {
    Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizRegisterScreen(),
      ),
    );
  }

  void checkUserType() {
    final userId = firebaseAuth.currentUser!.uid;

    firestore.collection("quizUsers").doc(userId).get().then((value) {
      if (!value.exists) {
        firebaseAuth.signOut();
        Fluttertoast.showToast(msg: "User not found!");
        return;
      }

      if (value.data()!.containsKey("block") && value.data()!['block']) {
        firebaseAuth.signOut();
        Fluttertoast.showToast(msg: "You are BLOCKED!");
        return;
      }

      if (value.data()!['admin']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizAdminScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizMainScreen(),
            ));
      }
    });
  }
}