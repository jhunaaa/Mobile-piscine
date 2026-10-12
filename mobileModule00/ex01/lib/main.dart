import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool clicked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            if (clicked)
              Text('A simple text',
                  style: TextStyle(backgroundColor: Colors.pinkAccent,
                      fontSize: 20
                  ),
              )
            else
              Text('Hello World',
                style: TextStyle(backgroundColor: Colors.pinkAccent,
                  fontSize: 20
                ),
              ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                    Colors.blue.shade200
                ),
              ),
              onPressed: () {
                setState(() {
                  clicked = !clicked;
                });
              },
              child: Text("Click me"),
            ),
          ],
        ),
      ),
    );
  }
}
