import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:stitched_stack/src/measure_size.dart';

import 'controller.dart';

/// "Stitches" a stack onto a widget. The stacks size will be coupled to the size of the stitched widget,
/// which (mostly) behaves exactly like it would without the stack overlaying/underlaying it.
///
/// Stitching in this case means laying out the stitched widget in the parents constraints,
/// before displaying the other stack elements, to obtain the size of the stitched widget.
/// After the size has been obtained, the stack will be constrained to match the size of stitched widget.
class StitchedStack extends StatefulWidget {
  const StitchedStack(
      {Key? key,
      this.controller,
      this.alignment,
      this.constraints,
      this.manual = false,
      required this.stitch,
      required this.children,
      this.backgroundChildren})
      : super(key: key);

  /// The controller to use for this stitched stack.
  final StitchedStackController? controller;

  /// The children which are laid out above the stitched widget.
  final List<Widget> children;

  /// The children which are laid out below the stitched widget.
  final List<Widget>? backgroundChildren;

  /// The stitched widget, which controls the size of the stack.
  final Widget stitch;

  /// The stack alignment for non-positioned widgets.
  final Alignment? alignment;

  /// The optional fixed [BoxConstraints] of the stack. Setting fixed constraints
  /// disables [LayoutBuilder] based default rebuilds.
  final BoxConstraints? constraints;

  /// Controls whether or not the [StitchedStack] listens for size changes
  /// of the [stitch] Widget and performs [restitch] automatically.
  /// Setting this option to true is advised in case the child doesn't
  /// resize itself or you want to control the state manually.
  final bool manual;

  @override
  StitchedStackState createState() => StitchedStackState();

  /// Forces the nearest [StitchedStack] to completely rebuild.
  /// Calling this regularly will cause flickering overlay widgets.
  static void recalculateBounds(BuildContext context) => context
      .findAncestorStateOfType<StitchedStackState>()
      ?.controller
      .recalculateBounds();

  /// Forces the nearest [StitchedStack] to manually update its size,
  /// in order to fit the possibly clipping stitched widget.
  /// By default, there is no need to call this manually, since the
  /// widgets performs restitches automatically on size changes if
  /// [StitchedStack.manual] is false.
  static void restitch(BuildContext context) =>
      context.findAncestorStateOfType<StitchedStackState>()?.restitch();
}

class StitchedStackState extends State<StitchedStack> {
  final GlobalKey stitchKey = GlobalKey();
  late StitchedStackController controller;

  @override
  void initState() {
    controller = widget.controller ?? StitchedStackController();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller != null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.constraints == null) {
      return _buildUnsetConstraints();
    } else {
      return _buildFixedConstraints();
    }
  }

  Widget _buildFixedConstraints() {
    var fallbackData = StitchedStackData(null, widget.constraints!);
    controller.data = fallbackData;
    return _buildInner(fallbackData);
  }

  Widget _buildUnsetConstraints() =>
      LayoutBuilder(builder: (context, constraints) {
        var fallbackData = StitchedStackData(null, constraints);
        controller.data = fallbackData;
        return _buildInner(fallbackData);
      });

  StreamBuilder<StitchedStackData> _buildInner(StitchedStackData fallbackData) {
    return StreamBuilder(
      builder: (context, snapshot) {
        var currentData = snapshot.data ?? fallbackData;
        if (currentData.size == null) {
          return _buildInitial(context, currentData.constraints);
        } else {
          return _buildResolved(currentData, context);
        }
      },
      stream: controller.stream,
    );
  }

  Widget _buildInitial(BuildContext context, BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.data = StitchedStackData(getSize(), constraints);
      PlatformDispatcher.instance.scheduleFrame();
    });
    return _buildWrappedChild(constraints);
  }

  Widget _buildResolved(StitchedStackData data, BuildContext context) {
    var bottomStack = widget.backgroundChildren;
    var topStack = widget.children;
    var size = data.size!;

    Widget leaf;
    if (widget.manual) {
      leaf = _buildWrappedChild(data.constraints);
    } else {
      leaf = MeasureSize(
          onChange: (updatedSize) {
            controller.restitch(updatedSize);
          },
          child: _buildWrappedChild(data.constraints));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: size.height,
          minWidth: size.width,
          maxWidth: size.width,
          maxHeight: size.height),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        alignment: widget.alignment ?? Alignment.topLeft,
        children: [
          if (bottomStack != null) ...bottomStack,
          Positioned.fill(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              // Removes jittering
              minWidth: data.constraints.minWidth,
              minHeight: data.constraints.minHeight,
              maxWidth: data.constraints.maxWidth,
              maxHeight: data.constraints.maxHeight,
              child: leaf,
            ),
          ),
          ...topStack
        ],
      ),
    );
  }

  ConstrainedBox _buildWrappedChild(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: constraints,
      key: stitchKey,
      child: widget.stitch,
    );
  }

  void restitch() {
    var currentSize = getSize();
    if (currentSize != null) {
      controller.restitch(currentSize);
    } else {
      controller.recalculateBounds();
    }
  }

  Size? getSize() {
    var currentContext = stitchKey.currentContext;
    if (currentContext == null) return null;
    return currentContext.size;
  }
}
