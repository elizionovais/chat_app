import 'package:chat_app/ui/chat_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Chat",
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 53, 120, 56),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 53, 120, 56),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 53, 120, 56)),
      ),
      home: const ChatHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
