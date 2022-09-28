import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  String text;
  void Function()  onPress;
  double padding = 0;
  ButtonStyle style= ElevatedButton.styleFrom();

  MyButton(this.text,{this.onPress, this.style, this.padding});
  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.padding==null?0: widget.padding, vertical: 16),
      child: ElevatedButton(
        onPressed: widget.onPress,
        style: widget.style,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
