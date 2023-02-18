import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// ignore: must_be_immutable
class LetterBox extends StatefulWidget {
  String character;
  LetterBox({super.key, required this.character});

  @override
  State<LetterBox> createState() => _LetterBoxState();
}

class _LetterBoxState extends State<LetterBox> {
  String emptyCharacter = "";
  String emptyIndicator = "-";
  bool useable = false;
  int colorsValue = 100;
  @override
  Widget build(BuildContext context) {
    useable = widget.character != emptyIndicator;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.character = emptyIndicator;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: useable ? Colors.teal[colorsValue] : Colors.white,
        child: Center(
            child: Text(
          widget.character == emptyIndicator
              ? emptyCharacter
              : widget.character,
          style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> availableLetters = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
  ];

  List<LetterBox> letterBoxes = [
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-"),
    LetterBox(character: "-")
  ];
  late Timer timer;
  Random randomLetterBoxIndex = Random();

  void setLetterInList() {
    int index = randomLetterBoxIndex.nextInt(25);
    int box = randomLetterBoxIndex.nextInt(16);
    String letter = availableLetters[index];
    bool assigned = false;
    int attempts = 0;
    int maxAttempts = 16;
    setState(() {
      //letterBoxes[box].character = letter;
      do {
        if (letterBoxes[box].character == "-") {
          letterBoxes
              .replaceRange(box, box + 1, [LetterBox(character: letter)]);
          assigned = true;
        } else {
          print("$box is taken");
          box = randomLetterBoxIndex.nextInt(16);
        }
        attempts++;
      } while (assigned == false && attempts < maxAttempts);
      print(letter);
    });
  }

  @override
  void initState() {
    super.initState();
    var period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (arg) {
      setLetterInList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: SafeArea(
        child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 4,
          children: [...letterBoxes],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
