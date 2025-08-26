import 'package:flutter/material.dart';
import 'package:scoreboard_app/CreateCard.dart';

class CreateLeague extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 221, 188),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fieldWidth = constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.8;
          return Center(
            child: SizedBox(
              width: fieldWidth,
              child: CreateCard(),
            ),
          );
        },
      ),
    );
  }
}
