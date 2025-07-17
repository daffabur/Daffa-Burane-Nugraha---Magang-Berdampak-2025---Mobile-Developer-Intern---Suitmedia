import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suitmediatest/provider/user_provider.dart';
import 'FirstScreen.dart';
import 'SecondScreen.dart';
import 'ThirdScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const FirstScreen(),
          '/second': (context) => const SecondScreen(),
          '/third': (context) => const ThirdScreen(),
        },
      ),
    );
  }
}
