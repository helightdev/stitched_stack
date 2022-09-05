import 'package:flutter/material.dart';
import 'package:stitched_stack/src/widget.dart';

void main() {
  TextEditingController fieldController = TextEditingController();

  runApp(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ListView(
          children: [
            StitchedStack(
              stitch: TextField(controller: fieldController, maxLines: 999, minLines: 1),
              children: [
                Positioned(bottom: 0, right: 0,child: Container(color: Colors.red, width: 50, height: 50))
              ],
            )
          ],
        ),
      ),
    ),
  ));
}