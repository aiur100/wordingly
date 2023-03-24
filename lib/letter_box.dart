import 'package:flutter/material.dart';

String emptyIndicator = "-";

class Letter {
  late String char;
  bool selected = false;
  Letter({required this.char, required this.selected});
}

List<LetterBox> startingLetterBoxes(callback) {
  return List.filled(
      16,
      LetterBox(
        character: emptyIndicator,
        callback: (val) => callback(val),
      ),
      growable: true);
}

typedef LetterCallBack = void Function(Letter val);

// ignore: must_be_immutable
class LetterBox extends StatefulWidget {
  String character;
  String emptyCharacter = "";

  final LetterCallBack callback;
  bool selected = false;
  LetterBox(
      {super.key, required this.character, required this.callback, selected});

  bool isOccupied() {
    return character == emptyIndicator;
  }

  @override
  State<LetterBox> createState() => _LetterBoxState();
}

class _LetterBoxState extends State<LetterBox> {
  int colorsValue = 100;

  void selectedToggle() {
    setState(() {
      widget.selected = widget.selected == false ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          widget.isOccupied() ? widget.emptyCharacter : widget.character,
          style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
