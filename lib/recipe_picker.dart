import 'dart:math' as math;
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:xml/xml.dart';

part 'recipe_picker_config.dart';

/// The picker used to select [Recipe] for coffee brewing.
///
/// The appearance of the picker is determined by the [config].
///
/// The picker itself does not maintain any state. Instead, when the state of
/// the picker changes, the widget calls the [onChanged] callback. Most widgets
/// that use a picker will listen for the [onChanged] callback and rebuild the
/// picker with a new [recipe].
class RecipePicker extends StatefulWidget {
  /// Creates a [RecipePicker].
  const RecipePicker({
    required this.config,
    required this.recipe,
    required this.onChanged,
    super.key,
  });

  /// The configuration of this picker.
  final RecipePickerConfig config;

  /// The currently selected recipe for this picker.
  ///
  /// The picker's thumb is drawn at a position that corresponds to this value.
  final Recipe recipe;

  /// Called when the user selects the new [Recipe].
  ///
  /// The picker passes the new value to the callback, but does not actually
  /// change state until the parent widget rebuilds the picker with the new
  /// value.
  final ValueChanged<Recipe> onChanged;

  @override
  State<RecipePicker> createState() => _RecipePickerState();
}

class _RecipePickerState extends State<RecipePicker>
    with TickerProviderStateMixin {
  late final _activationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.95,
    end: 1,
  ).chain(CurveTween(curve: Curves.easeOut)).animate(_activationController);
  late final Animation<double> _labelOpacity = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(CurveTween(curve: Curves.easeInOut)).animate(_activationController);

  late final _recipeAreaProgressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _recipeAreaProgress = CurvedAnimation(
    parent: _recipeAreaProgressController,
    curve: Curves.easeOut,
  );

  late final _thumbPositionProgressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final _thumbPositionProgress = CurvedAnimation(
    parent: _thumbPositionProgressController,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _activationController.dispose();
    _recipeAreaProgress.dispose();
    _recipeAreaProgressController.dispose();
    _thumbPositionProgress.dispose();
    _thumbPositionProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisAlignment: .center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Label(
              text: 'Fruity',
              opacity: _labelOpacity,
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  _Label(
                    text: 'Strong',
                    opacity: _labelOpacity,
                    quarterTurns: -1,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(50),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 365,
                          maxHeight: 365,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            heightFactor: 1,
                            widthFactor: 1,
                            child: _RecipePicker(
                              config: widget.config,
                              recipe: widget.recipe,
                              recipeAreaProgressController:
                                  _recipeAreaProgressController,
                              recipeAreaProgress: _recipeAreaProgress,
                              thumbPositionProgressController:
                                  _thumbPositionProgressController,
                              thumbPositionProgress: _thumbPositionProgress,
                              onChanged: widget.onChanged,
                              onDragStarted: () {
                                _activationController.forward();
                              },
                              onDragCompleted: () {
                                _activationController.reverse();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _Label(
                    text: 'Mild',
                    opacity: _labelOpacity,
                    quarterTurns: 1,
                  ),
                ],
              ),
            ),
            _Label(
              text: 'Roasty',
              opacity: _labelOpacity,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    required this.opacity,
    this.quarterTurns = 0,
  });

  final String text;

  final Animation<double> opacity;

  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    final screenSide = MediaQuery.sizeOf(context).shortestSide;
    final fontSize = (screenSide * 22 / 550).clamp(12, 22).toDouble();

    final child = FadeTransition(
      opacity: opacity,
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFFD4D4D4),
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          height: 1,
          letterSpacing: fontSize * 0.11,
        ),
      ),
    );

    if (quarterTurns == 0) {
      return child;
    }

    return RotatedBox(
      quarterTurns: quarterTurns,
      child: child,
    );
  }
}

class _RecipePicker extends SingleChildRenderObjectWidget {
  const _RecipePicker({
    required this.config,
    required this.recipe,
    required this.recipeAreaProgressController,
    required this.recipeAreaProgress,
    required this.thumbPositionProgressController,
    required this.thumbPositionProgress,
    required this.onChanged,
    required this.onDragStarted,
    required this.onDragCompleted,
  }) : super(child: const _Thumb());

  final RecipePickerConfig config;

  final Recipe recipe;

  final AnimationController recipeAreaProgressController;

  final Animation<double> recipeAreaProgress;

  final AnimationController thumbPositionProgressController;

  final Animation<double> thumbPositionProgress;

  /// Callback triggered when the user releases the thumb, selecting a new
  /// [Recipe].
  final ValueChanged<Recipe> onChanged;

  /// Called when thumb starts being dragged.
  final VoidCallback onDragStarted;

  /// Called when the thumb is dropped.
  final VoidCallback onDragCompleted;

  @override
  _RenderRecipePicker createRenderObject(BuildContext context) {
    return _RenderRecipePicker(
      config: config,
      recipe: recipe,
      recipeAreaProgressController: recipeAreaProgressController,
      recipeAreaProgress: recipeAreaProgress,
      thumbPositionProgressController: thumbPositionProgressController,
      thumbPositionProgress: thumbPositionProgress,
      onChanged: onChanged,
      onDragStarted: onDragStarted,
      onDragCompleted: onDragCompleted,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderRecipePicker renderObject,
  ) {
    renderObject
      ..config = config
      ..recipe = recipe
      .._recipeAreaProgressController = recipeAreaProgressController
      ..recipeAreaProgress = recipeAreaProgress
      .._thumbPositionProgressController = thumbPositionProgressController
      ..thumbPositionProgress = thumbPositionProgress
      .._onChanged = onChanged
      .._onDragStarted = onDragStarted
      .._onDragCompleted = onDragCompleted;
  }
}

class _RenderRecipePicker extends RenderShiftedBox {
  _RenderRecipePicker({
    required RecipePickerConfig config,
    required Recipe recipe,
    required AnimationController recipeAreaProgressController,
    required Animation<double> recipeAreaProgress,
    required AnimationController thumbPositionProgressController,
    required Animation<double> thumbPositionProgress,
    required ValueChanged<Recipe> onChanged,
    required VoidCallback onDragStarted,
    required VoidCallback onDragCompleted,
  }) : _config = config,
       _recipe = recipe,
       _recipeAreaProgressController = recipeAreaProgressController,
       _recipeAreaProgress = recipeAreaProgress,
       _thumbPositionProgressController = thumbPositionProgressController,
       _thumbPositionProgress = thumbPositionProgress,
       _onChanged = onChanged,
       _onDragStarted = onDragStarted,
       _onDragCompleted = onDragCompleted,
       super(null);

  RecipePickerConfig get config => _config;
  RecipePickerConfig _config;
  set config(RecipePickerConfig newConfig) {
    if (newConfig == _config) {
      return;
    }

    _config = newConfig;

    _recipeAreaProgressController.value = 0;
    _thumbPositionProgressController.value = 0;

    _recipeAreaTween
      ..begin = config.areaForRecipe(recipe)
      ..end = config.areaForRecipe(recipe);

    _thumbPositionTween
      ..begin = config.areaBaseForRecipe(recipe).center
      ..end = config.areaBaseForRecipe(recipe).center;

    markNeedsLayout();
  }

  Recipe get recipe => _recipe;
  Recipe _recipe;
  set recipe(Recipe newRecipe) {
    if (newRecipe == _recipe) {
      return;
    }

    _recipe = newRecipe;

    _recipeAreaTween
      ..begin = _recipeArea
      ..end = config.areaForRecipe(recipe);
    _recipeAreaProgressController.forward(from: 0);

    _thumbPositionTween
      ..begin = _thumbPosition
      ..end = config.areaBaseForRecipe(recipe).center;
    _thumbPositionProgressController.forward(from: 0);

    markNeedsPaint();
  }

  AnimationController _recipeAreaProgressController;

  Animation<double> get recipeAreaProgress => _recipeAreaProgress;
  Animation<double> _recipeAreaProgress;
  set recipeAreaProgress(Animation<double> newRecipeAreaProgress) {
    if (newRecipeAreaProgress == _recipeAreaProgress) {
      return;
    }

    _recipeAreaProgress.removeListener(markNeedsPaint);
    newRecipeAreaProgress.addListener(markNeedsPaint);

    _recipeAreaProgress = newRecipeAreaProgress;
    markNeedsPaint();
  }

  late final _recipeAreaTween = _RecipeAreaTween(
    begin: config.areaForRecipe(recipe),
    end: config.areaForRecipe(recipe),
  );

  RecipeArea get _recipeArea => _recipeAreaTween.evaluate(recipeAreaProgress);

  AnimationController _thumbPositionProgressController;

  Animation<double> get thumbPositionProgress => _thumbPositionProgress;
  Animation<double> _thumbPositionProgress;
  set thumbPositionProgress(Animation<double> newThumbPositionProgress) {
    if (newThumbPositionProgress == _thumbPositionProgress) {
      return;
    }

    _thumbPositionProgress.removeListener(markNeedsPaint);
    newThumbPositionProgress.addListener(markNeedsPaint);

    _thumbPositionProgress = newThumbPositionProgress;
    markNeedsPaint();
  }

  late final _thumbPositionTween = Tween<Offset>(
    begin: config.areaBaseForRecipe(recipe).center,
    end: config.areaBaseForRecipe(recipe).center,
  );

  Offset get _thumbPosition =>
      _thumbPositionTween.evaluate(thumbPositionProgress);

  ValueChanged<Recipe> _onChanged;

  VoidCallback _onDragStarted;

  VoidCallback _onDragCompleted;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _recipeAreaProgress.addListener(markNeedsPaint);
    _thumbPositionProgress.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _recipeAreaProgress.removeListener(markNeedsPaint);
    _thumbPositionProgress.removeListener(markNeedsPaint);
    super.detach();
  }

  RenderBox get _thumb => child!;
  BoxParentData get _thumbParentData => _thumb.parentData! as BoxParentData;

  double get _scale => size.width / config.originalDimension;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry), '');

    switch (event) {
      case PointerDownEvent():
        _thumbPositionTween
          ..begin = _thumbPosition
          ..end = _thumbPosition;
        _thumbPositionProgressController.value = 0;

        _onDragStarted();

      case PointerMoveEvent():
        final dragPosition =
            _thumbPositionTween.begin! + (event.delta / _scale);
        _thumbPositionTween
          ..begin = dragPosition
          ..end = dragPosition;

        markNeedsPaint();

      case PointerUpEvent():
      case PointerCancelEvent():
        final currentPosition = _thumbPosition;

        _thumbPositionTween
          ..begin = currentPosition
          ..end = config.areaBaseForRecipe(recipe).center;
        _thumbPositionProgressController.forward(from: 0);

        final selectedRecipe = config.recipeForAreaPosition(currentPosition);
        if (selectedRecipe != recipe) {
          _onChanged(selectedRecipe);
        }

        _onDragCompleted();
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    // size has to be set first, so scale calculation won't throw.
    size = constraints.biggest;

    final thumbDimension = config.thumb.radius * 2 * _scale;
    _thumb.layout(
      BoxConstraints.tight(Size.square(thumbDimension)).enforce(constraints),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final scale = _scale;

    final pickerAreaPaint = Paint()
      ..color = config.pickerArea.strokeColor
      ..strokeWidth = config.pickerArea.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..translate(offset.dx, offset.dy);

    if (scale != 1) {
      canvas
        ..save()
        ..scale(scale);
    }
    canvas.drawPath(config.pickerArea.path, pickerAreaPaint);

    for (final base in [
      config.espressoAreaBase,
      config.ristrettoAreaBase,
      config.lungoAreaBase,
    ]) {
      canvas.drawCircle(
        base.center,
        base.radius,
        Paint()..color = base.color,
      );
    }

    final recipeArea = _recipeArea;

    final areaStrokePaint = Paint()
      ..color = recipeArea.strokeColor
      ..strokeWidth = recipeArea.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final areaFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        radius: 1,
        colors: [
          Color(0x00FFFFFF),
          Color(0x44FFFFFF),
          Color(0xAAFFFFFF),
        ],
        stops: [0, 0.8, 1],
      ).createShader(recipeArea.path.getBounds());

    canvas
      ..drawPath(recipeArea.path, areaFillPaint)
      ..drawPath(recipeArea.path, areaStrokePaint);

    if (scale != 1) {
      canvas.restore();
    }

    canvas.restore();

    final thumbSize = _thumb.size;
    _thumbParentData.offset = (_thumbPosition * scale).translate(
      -thumbSize.width / 2,
      -thumbSize.height / 2,
    );
    context.paintChild(_thumb, offset + _thumbParentData.offset);
  }
}

/// An interpolation between two [RecipeArea]s.
class _RecipeAreaTween extends Tween<RecipeArea> {
  /// Creates a [RecipeArea] tween.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  _RecipeAreaTween({super.begin, super.end});

  /// Returns the value this variable has at the given animation clock value.
  @override
  RecipeArea lerp(double t) => RecipeArea.lerp(begin!, end!, t);
}

class _Thumb extends StatefulWidget {
  const _Thumb();

  @override
  State<_Thumb> createState() => __ThumbState();
}

class __ThumbState extends State<_Thumb> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  late final Animation<double> _progress = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);

  final _cursor = ValueNotifier<MouseCursor>(SystemMouseCursors.grab);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) {
        _controller.forward();
        _cursor.value = SystemMouseCursors.grabbing;
      },
      onPanEnd: (_) {
        _controller.reverse();
        _cursor.value = SystemMouseCursors.grab;
      },
      onPanCancel: () {
        _controller.reverse();
        _cursor.value = SystemMouseCursors.grab;
      },
      child: ClipOval(
        clipBehavior: Clip.none,
        child: ValueListenableBuilder(
          valueListenable: _cursor,
          builder: (context, cursor, child) {
            return MouseRegion(
              cursor: cursor,
              child: child,
            );
          },
          child: CustomPaint(
            painter: _ThumbPainter(progress: _progress),
          ),
        ),
      ),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  const _ThumbPainter({
    required this.progress,
  }) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final progress = this.progress.value;

    if (progress > 0) {
      canvas.drawCircle(
        rect.center,
        rect.width * progress,
        Paint()
          ..color = const Color(0xFFFDFDFD).withValues(alpha: 0.12 * progress),
      );
    }

    canvas
      ..drawCircle(
        rect.center,
        rect.width / 2,
        Paint()..color = const Color(0xFFFDFDFD),
      )
      ..drawCircle(
        rect.center,
        rect.width / 10,
        Paint()..color = const Color(0xFFC0C0C0),
      );
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
