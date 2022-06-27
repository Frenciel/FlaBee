import 'package:flutter/material.dart';

class MyBee extends StatelessWidget {
  final beeY;
  final double beeWidth; // normal double value for width
  final double beeHeight; // out of 2

  MyBee({this.beeY, required this.beeWidth, required this.beeHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, (2 * beeY + beeHeight) / (2 - beeHeight)),
      child: Image.asset(
        'lib/images/bee.png',
        width: MediaQuery.of(context).size.height * beeWidth / 2,
        height: MediaQuery.of(context).size.height * beeHeight / 2,
        fit: BoxFit.fill,
      ),
    );
  }
}
