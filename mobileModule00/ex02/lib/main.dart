import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

Widget buildButton(String value) {
  return TextButton(
    onPressed: () {
      developer.log("button pressed :$value");
    },
    child: Text(value),
  );
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Calculator"),
          centerTitle: true
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: const [
                Spacer(),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Row(
              children: const [
                Spacer(),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: buildButton('7')),
                Expanded(child: buildButton('8')),
                Expanded(child: buildButton('9')),
                Expanded(child: buildButton('C')),
                Expanded(child: buildButton('AC')),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: buildButton('4')),
                Expanded(child: buildButton('5')),
                Expanded(child: buildButton('6')),
                Expanded(child: buildButton('+')),
                Expanded(child: buildButton('-')),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: buildButton('1')),
                Expanded(child: buildButton('2')),
                Expanded(child: buildButton('3')),
                Expanded(child: buildButton('x')),
                Expanded(child: buildButton('/')),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: buildButton('0')),
                Expanded(child: buildButton('.')),
                Expanded(child: buildButton('00')),
                Expanded(child: buildButton('=')),
                Expanded(child: buildButton('')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
