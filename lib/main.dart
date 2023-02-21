import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

late List<dynamic> wordDictionary;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var data = await rootBundle.loadString('assets/words.json');
  wordDictionary = jsonDecode(data);
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

class Letter {
  late String char;
  bool selected = false;
  Letter({required this.char, required this.selected});
}

typedef LetterCallBack = void Function(Letter val);

// ignore: must_be_immutable
class LetterBox extends StatefulWidget {
  String character;
  final LetterCallBack callback;
  bool selected = false;
  LetterBox(
      {super.key, required this.character, required this.callback, selected});

  @override
  State<LetterBox> createState() => _LetterBoxState();
}

class _LetterBoxState extends State<LetterBox> {
  String emptyCharacter = "";
  String emptyIndicator = "-";
  bool useable = false;
  int colorsValue = 100;

  void selectedToggle() {
    setState(() {
      widget.selected = widget.selected == false ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    useable = widget.character != emptyIndicator;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.selected = widget.selected == false ? true : false;
          colorsValue = widget.selected ? 400 : 100;
        });
        widget.callback(
            Letter(char: widget.character, selected: widget.selected));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: widget.selected ? Colors.teal[colorsValue] : Colors.white,
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
    "A",
    "A",
    "A",
    "A",
    "A",
    "B",
    "C",
    "D",
    "D",
    "D",
    "D",
    "D",
    "D",
    "D",
    "D",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "E",
    "F",
    "G",
    "G",
    "G",
    "H",
    "H",
    "H",
    "H",
    "H",
    "H",
    "H",
    "H",
    "H",
    "H",
    "H",
    "I",
    "I",
    "I",
    "I",
    "I",
    "I",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "N",
    "N",
    "N",
    "O",
    "O",
    "O",
    "O",
    "O",
    "O",
    "O",
    "O",
    "O",
    "O",
    "O",
    "P",
    "Q",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "R",
    "S",
    "S",
    "S",
    "S",
    "S",
    "S",
    "S",
    "S",
    "S",
    "T",
    "U",
    "V",
    "V",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "Z",
    "Z",
    "Z",
  ];

  late List<LetterBox> letterBoxes;
  late Timer timer;
  Random randomLetterBoxIndex = Random();

  List<String> lettersInWord = [];

  void setLetterInList() {
    int index = randomLetterBoxIndex.nextInt(availableLetters.length);
    int box = randomLetterBoxIndex.nextInt(16);
    String letter = availableLetters[index];
    bool assigned = false;
    int attempts = 0;
    int maxAttempts = 16;
    setState(() {
      do {
        if (letterBoxes[box].character == "-") {
          letterBoxes.replaceRange(box, box + 1, [
            LetterBox(
              character: letter,
              selected: false,
              callback: (val) => addLetterToWord(val),
            )
          ]);
          assigned = true;
        } else {
          box = randomLetterBoxIndex.nextInt(16);
        }
        attempts++;
      } while (assigned == false && attempts < maxAttempts);
    });
  }

  void addLetterToWord(Letter letter) {
    setState(() {
      if (letter.selected) {
        lettersInWord.add(letter.char);
      } else {
        lettersInWord.remove(letter.char);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    letterBoxes = [
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      ),
      LetterBox(
        character: "-",
        callback: (val) => addLetterToWord(val),
      )
    ];
    var period = const Duration(seconds: 3);
    timer = Timer.periodic(period, (arg) {
      setLetterInList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Color wordColor = Colors.black;

  void handleSubmit() {
    String wordToCheck = lettersInWord.join("").toLowerCase();
    if (wordDictionary.contains(wordToCheck) == false) {
      setState(() {
        wordColor = Colors.red;
      });
      return;
    }
    for (int i = 0; i < letterBoxes.length; i++) {
      var letterBox = letterBoxes[i];

      if (letterBox.selected) {
        setState(() {
          letterBoxes.replaceRange(i, i + 1, [
            LetterBox(
                character: "-",
                selected: false,
                callback: (val) => addLetterToWord(val))
          ]);
        });
      }
    }
    setState(() {
      lettersInWord.clear();
      wordColor = Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
              child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 4,
            children: [...letterBoxes],
          )),
          Text(
            lettersInWord.join(""),
            style: TextStyle(
                fontSize: 40.0, fontWeight: FontWeight.bold, color: wordColor),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Theme.of(context).colorScheme.secondary),
                fixedSize: MaterialStateProperty.all(Size(140.0, 50.0)),
                // ignore: prefer_const_constructors
                textStyle: MaterialStatePropertyAll<TextStyle>(
                    const TextStyle(color: Colors.white)),
              ),
              onPressed: () {
                handleSubmit();
              },
              child: const Text("Submit",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
