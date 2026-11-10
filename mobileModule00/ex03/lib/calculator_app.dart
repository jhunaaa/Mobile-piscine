import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

var result = '0';
var input = '';

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

  Expression? tryParseExpression(String expression) {
    try {
      return GrammarParser().parse(expression);
    } catch (_) {
      return null;
    }
  }

  Widget buildButton(String value) {
    return TextButton(
      onPressed: () {
        setState(() {
          if (value == '=') {
            if (input.isEmpty) {
              return;
            }
            final expression = input.replaceAll('x', '*');

            final parsed = tryParseExpression(expression);

            if (parsed != null) {
              final value = RealEvaluator().evaluate(parsed);
              result = value.toString();
            } else {
              result = "Not a valid expression";
            }

            input = '';
          }
          else if (value == "C") {
            if (input.isNotEmpty) {
              input = input.substring(0, input.length - 1);
            }
          }
          else if (value == "AC") {
            input = '';
          }
          else {
            if (input.length < 28) {
              input += value;
            }
          }
        });
      },
      child: Text(value),
    );
  }

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                input.isEmpty ? '0' : input,
                textAlign: TextAlign.right,
                softWrap: true,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                result,
                textAlign: TextAlign.right,
                softWrap: true,
                style: const TextStyle(fontSize: 20),
              ),
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
