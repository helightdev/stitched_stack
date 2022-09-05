import 'dart:async';

import 'package:flutter/widgets.dart';

class StitchedStackController {
  final StreamController<StitchedStackData> _controller = StreamController<StitchedStackData>.broadcast();

  late StitchedStackData _data;

  Stream<StitchedStackData> get stream => _controller.stream;

  StitchedStackData get data => _data;

  set data(StitchedStackData newData) => _update(newData);

  void recalculateBounds() {
    _controller.sink.add(StitchedStackData(null, _data.constraints));
  }

  void restitch(Size size) {
    _controller.sink.add(StitchedStackData(size, _data.constraints));
  }

  void _update(StitchedStackData state) {
    _data = state;
    _controller.sink.add(state);
  }
}

class StitchedStackData {
  final Size? size;
  final BoxConstraints constraints;

  const StitchedStackData(this.size, this.constraints);
}