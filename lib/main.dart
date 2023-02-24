import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordly/game_board.dart';
import 'dart:convert';
import 'dart:async';

late List<dynamic> wordDictionary;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var data = await rootBundle.loadString('assets/words.json');
  wordDictionary = jsonDecode(data);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameBoard(title: 'Worldy', wordDictionary: wordDictionary),
    );
  }
}
