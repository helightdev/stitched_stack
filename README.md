<h1 align="center">
  <br>
  <img src="https://i.imgur.com/IcJForo.png" alt="Stitched_Stack Logo" width="256">
  <br>
  stitched_stack
</h1>
<h4 align="center">
A flutter library providing a way to stich a size-bound stack onto a widget.
</h4>

## Features
This library exposes the `StitchedStack` widget, than can be used to
stitch a stack onto a widget. The stacks size will be coupled to the
size of the stitched widget, which (mostly) behaves exactly like it would
without the stack overlaying/underlaying it.

The stitched stack will by default automatically update its size if the
child grows or shrinks. This behaviour can be disabled by setting the
`manual` property. The stitched stack will also respond to layout changes
and rebuild completely. This behaviour can be disabled by providing fixed
`constraints`.

## Example

This simple example shows how to create a `TextField` with a stitched widget
in the bottom-right corner. The `Container` will stay stitched at the corner,
even if the `TextField` grows.

```dart
import 'package:flutter/material.dart';
import 'package:stitched_stack/stitched_stack.dart';

class MyWidget extends StatelessWidget {

  TextEditingController fieldController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return StitchedStack(
      stitch: TextField(controller: fieldController, maxLines: 99, minLines: 1),
      children: [
        Positioned(bottom: 0, right: 0, child: Container(color: Colors.red, width: 50, height: 50))
      ],
    );
  }
}
```

![Screenshot](https://i.imgur.com/hcoCR50.png)