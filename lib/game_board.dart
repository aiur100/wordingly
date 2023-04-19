import 'package:flutter/material.dart';
import 'package:wordly/letter_box.dart';
import 'package:wordly/letters.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';

final wordLengthPointValues = <int, int>{3: 1, 4: 1, 5: 2, 6: 3, 7: 5, 8: 11};

class GameBoard extends StatefulWidget {
  const GameBoard(
      {super.key, required this.title, required this.wordDictionary});

  final String title;
  final List<dynamic> wordDictionary;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int? _highestScoreValue = 0;
  int? _lastHighestScoreValue = 0;

  int userPoints = 0;

  // availableLetters - Available letters in the alphabet
  // in a list where letters are repeated according to
  // optimal distribution to enable the user to
  // generate words effectively.
  List<String> availableLetters = letters();

  // letterBoxes is the actual 4x4 game board.
  // the letters in this list represent either empty boxes,
  // or boxes filled with a letter. This is defined by the
  // LetterBox object.
  late List<LetterBox> letterBoxes;

  // board fill timer

  // time between letter appearances in milliseconds
  int msPerLetter = 2500;
  int timeToGameOver = 20;
  int maxGameOverTimer = 20;
  int minGameOverTimer = 5;
  bool gameOverImminent = false;
  bool gameOver = false;

  Timer? timer;
  Timer? gameOverTimer;

  String highScoreSharedPrefKey = "high_score";

  _storeHighestScore(int scoreNow) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(highScoreSharedPrefKey, scoreNow);
  }

  /// Starting the game by setting a
  /// timer, and putting a letter on the board
  /// periodically according to that timer.
  @override
  void initState() {
    super.initState();

    // Add empty letter boxes to the grid.
    letterBoxes = startingLetterBoxes(addLetterToWord);
    startGameTimer();

    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _highestScoreValue = prefs.getInt(highScoreSharedPrefKey) ?? 0;
        _lastHighestScoreValue = _highestScoreValue;
      });
    });
  }

  void disableLetterBoxes() {
    for (var element in letterBoxes) {
      setState(() {
        element.disabled = true;
      });
    }
  }

  void enableLetterBoxes() {
    for (var element in letterBoxes) {
      setState(() {
        element.disabled = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void startGameOverTimer() {
    var period = const Duration(seconds: 1);
    gameOverTimer = Timer.periodic(period, (arg) {
      setState(() {
        timeToGameOver--;
        if (timeToGameOver <= 0) {
          gameOver = true;
          disableLetterBoxes();
          stopGameOverTimer();
          stopGameTimer();
          gameOverImminent = false;
          return;
        }
        if (gameOverImminent == false) {
          gameOverImminent = true;
        }
      });
    });
  }

  void stopGameOverTimer() {
    if (gameOverTimer == null) {
      return;
    }
    gameOverTimer?.cancel();
    int interval = maxGameOverTimer - minGameOverTimer;
    maxGameOverTimer =
        interval < minGameOverTimer ? minGameOverTimer : interval;
  }

  void stopGameTimer() {
    timer?.cancel();
  }

  void startGameTimer() {
    var period = Duration(milliseconds: msPerLetter);
    timer = Timer.periodic(period, (arg) {
      putLetterOnBoard();
    });
  }

  Random randomNumberGenerator = Random();

  // these are the letters that the user
  // has typed in as an answer.
  List<String> lettersInCurrentWord = [];

  // This function finds an open spot in the letterBoxes List
  // and fills it with a letter from the availableLetters list.
  // It will try to fill in spot a total of sixteen times before it
  // stops trying.
  void putLetterOnBoard() {
    int letterIndex = randomNumberGenerator.nextInt(availableLetters.length);
    String letter = availableLetters[letterIndex];
    bool assigned = false;
    int attempts = 0;
    int maxAttempts = 50;
    int filledBoxCount = letterBoxes
        .where(
          (element) => element.character != "-",
        )
        .toList()
        .length;

    if (filledBoxCount >= 16) {
      startGameOverTimer();
      stopGameTimer();
      return;
    }

    do {
      int boxToFillIndex = randomNumberGenerator.nextInt(16);
      if (letterBoxes[boxToFillIndex].character == "-") {
        setState(() {
          letterBoxes.replaceRange(boxToFillIndex, boxToFillIndex + 1, [
            LetterBox(
              character: letter,
              selected: false,
              callback: (val) => addLetterToWord(val),
            )
          ]);
        });
        assigned = true;
      }
      attempts++;
    } while (assigned == false && attempts < maxAttempts);
  }

  // This is used a callback to the LetterBox object
  // Which will call back to a function when it has been
  // detected as been pressed.
  //
  // When pressed it calls this function back with a Letter object.
  // The Letter object has a character (A-Z), and whether or not it is selected.
  //
  // If selected, we add the letter (character) into the lettersInCurrentWord
  // list, representing the users current word before submission.
  //
  // If it is not selected, we find in the lettersInCurrentWord
  // and remove it from that list.
  // The user most-likely had it selected, and then de-selected.
  void addLetterToWord(Letter letter) {
    setState(() {
      if (letter.selected) {
        lettersInCurrentWord.add(letter.char);
      } else {
        lettersInCurrentWord.remove(letter.char);
      }
    });
  }

  Text highScoreText() {
    if (userPoints > _lastHighestScoreValue!) {
      return Text("New High Score: $userPoints",
          style: const TextStyle(
              color: Colors.blue, fontWeight: FontWeight.w800, fontSize: 20.0));
    } else {
      return Text("Score to beat: $_lastHighestScoreValue");
    }
  }

  Color wordColor = Colors.black;

  // Here we handle a users word submission.
  // We join the letters/characters in the
  // lettersInCurrentWord list to form a word string.
  //
  // We then check if that word is in our wordDictionary.
  // If it is, we clear the selected letters and a lot appropriate
  // points to the user.
  //
  // If it is not, we turn the text displaying the current word RED
  // so that the user knows that the word submitted is not valid.
  void handleSubmit() {
    String wordToCheck = lettersInCurrentWord.join("").toLowerCase();
    int wordPointValueIndex = wordToCheck.length;
    if (wordToCheck.length <= 2 ||
        widget.wordDictionary.contains(wordToCheck) == false) {
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
      userPoints += wordLengthPointValues[wordPointValueIndex] ?? 8;
      msPerLetter = msPerLetter - 50;
      wordColor = Colors.black;
      lettersInCurrentWord.clear();
      stopGameOverTimer();
      stopGameTimer();
      startGameTimer();
    });
    if (userPoints > _highestScoreValue!) {
      _storeHighestScore(userPoints);
    }
  }

  void playAgain() {
    setState(() {
      _prefs.then((SharedPreferences prefs) {
        setState(() {
          _highestScoreValue = prefs.getInt(highScoreSharedPrefKey) ?? 0;
          _lastHighestScoreValue = _highestScoreValue;
        });
      });
      userPoints = 0;
      for (int i = 0; i < letterBoxes.length; i++) {
        setState(() {
          letterBoxes.replaceRange(i, i + 1, [
            LetterBox(
                character: "-",
                selected: false,
                callback: (val) => addLetterToWord(val))
          ]);
        });
      }
      gameOver = false;
      gameOverImminent = false;
      maxGameOverTimer = 20;
      minGameOverTimer = 5;
      timeToGameOver = 20;
      msPerLetter = 2500;
      lettersInCurrentWord.clear();
      startGameTimer();
      stopGameOverTimer();
    });
  }

  String playAgainText = "Play Again!";
  String submitText = "Submit";

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
        Padding(
          padding: const EdgeInsets.all(30),
          child: OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(gameOver
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary),
              fixedSize: MaterialStateProperty.all(const Size(140.0, 50.0)),
              // ignore: prefer_const_constructors
              textStyle: MaterialStatePropertyAll<TextStyle>(
                  const TextStyle(color: Colors.white)),
            ),
            onPressed: () {
              if (gameOver) {
                playAgain();
              } else {
                handleSubmit();
              }
            },
            child: Text(gameOver ? playAgainText : submitText,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            lettersInCurrentWord.join(""),
            style: TextStyle(
                fontSize: 40.0, fontWeight: FontWeight.bold, color: wordColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: gameOver
              ? const Text(
                  "GAME OVER!",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.0),
                )
              : const Text(""),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: highScoreText(),
        ),
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: gameOverImminent
              ? Text(
                  "$timeToGameOver",
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.0),
                )
              : const Text(""),
        ),
        Text(
          "Points: $userPoints",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Text(
            "Letters appear every ${(msPerLetter / 1000).toStringAsFixed(2)} seconds"),
      ])), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
