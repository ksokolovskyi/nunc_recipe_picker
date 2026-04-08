part of 'recipe_picker.dart';

void debugMessage(String message) {
  assert(() {
    // Print will be executed only in debug mode.
    // ignore: avoid_print
    print(message);
    return true;
  }(), '');
}

/// The type of recipe to cook.
enum Recipe {
  espresso,
  ristretto,
  lungo,
}

/// The configuration of the [RecipePicker].
class RecipePickerConfig extends Equatable {
  /// Creates a [RecipePickerConfig].
  const RecipePickerConfig({
    required this.originalDimension,
    required this.pickerArea,
    required this.espressoArea,
    required this.espressoAreaBase,
    required this.ristrettoArea,
    required this.ristrettoAreaBase,
    required this.lungoArea,
    required this.lungoAreaBase,
    required this.thumb,
  });

  /// Parses [svg] as a configuration of [RecipePicker].
  ///
  /// Returns [RecipePickerConfig] on success, `null` otherwise.
  static RecipePickerConfig? tryParse(String svg) {
    try {
      final document = XmlDocument.parse(svg);

      final svgElement = document.getElement('svg');
      if (svgElement == null) {
        debugMessage('svg element not found.');
        return null;
      }

      final width = double.tryParse(svgElement.getAttribute('width') ?? '');
      final height = double.tryParse(svgElement.getAttribute('height') ?? '');
      if (width == null || height == null || width != height) {
        debugMessage(
          'Recipe picker width and height must be specified and equal.',
        );
        return null;
      }

      final elements = <String, XmlElement>{};
      for (final e in svgElement.descendants.whereType<XmlElement>()) {
        final id = e.getAttribute('id');
        if (id != null) {
          elements[id] = e;
        }
      }

      final pickerAreaElement = elements['picker_area'];
      if (pickerAreaElement == null) {
        debugMessage('picker_area element not found.');
        return null;
      }
      final pickerArea = PickerArea.tryParse(pickerAreaElement);
      if (pickerArea == null) {
        debugMessage('Failed to parse picker_area.');
        return null;
      }

      final espressoAreaElement = elements['espresso_area'];
      if (espressoAreaElement == null) {
        debugMessage('espresso_area element not found.');
        return null;
      }
      final espressoArea = RecipeArea.tryParse(espressoAreaElement);
      if (espressoArea == null) {
        debugMessage('Failed to parse espresso_area.');
        return null;
      }
      final espressoAreaBaseElement = elements['espresso_area_base'];
      if (espressoAreaBaseElement == null) {
        debugMessage('espresso_area_base element not found.');
        return null;
      }
      final espressoAreaBase = RecipeAreaBase.tryParse(espressoAreaBaseElement);
      if (espressoAreaBase == null) {
        debugMessage('Failed to parse espresso_area_base.');
        return null;
      }

      final ristrettoAreaElement = elements['ristretto_area'];
      if (ristrettoAreaElement == null) {
        debugMessage('ristretto_area element not found.');
        return null;
      }
      final ristrettoArea = RecipeArea.tryParse(ristrettoAreaElement);
      if (ristrettoArea == null) {
        debugMessage('Failed to parse ristretto_area.');
        return null;
      }
      final ristrettoAreaBaseElement = elements['ristretto_area_base'];
      if (ristrettoAreaBaseElement == null) {
        debugMessage('ristretto_area_base element not found.');
        return null;
      }
      final ristrettoAreaBase = RecipeAreaBase.tryParse(
        ristrettoAreaBaseElement,
      );
      if (ristrettoAreaBase == null) {
        debugMessage('Failed to parse ristretto_area_base.');
        return null;
      }

      final lungoAreaElement = elements['lungo_area'];
      if (lungoAreaElement == null) {
        debugMessage('lungo_area element not found.');
        return null;
      }
      final lungoArea = RecipeArea.tryParse(lungoAreaElement);
      if (lungoArea == null) {
        debugMessage('Failed to parse lungo_area.');
        return null;
      }
      final lungoAreaBaseElement = elements['lungo_area_base'];
      if (lungoAreaBaseElement == null) {
        debugMessage('lungo_area_base element not found.');
        return null;
      }
      final lungoAreaBase = RecipeAreaBase.tryParse(lungoAreaBaseElement);
      if (lungoAreaBase == null) {
        debugMessage('Failed to parse lungo_area_base.');
        return null;
      }

      final thumbElement = elements['thumb'];
      if (thumbElement == null) {
        debugMessage('thumb element not found.');
        return null;
      }
      final thumb = Thumb.tryParse(thumbElement);
      if (thumb == null) {
        debugMessage('Failed to parse thumb.');
        return null;
      }

      return RecipePickerConfig(
        originalDimension: width,
        pickerArea: pickerArea,
        espressoArea: espressoArea,
        espressoAreaBase: espressoAreaBase,
        ristrettoArea: ristrettoArea,
        ristrettoAreaBase: ristrettoAreaBase,
        lungoArea: lungoArea,
        lungoAreaBase: lungoAreaBase,
        thumb: thumb,
      );
    } on XmlParserException catch (e) {
      debugMessage('SVG parsing error: $e.');
      return null;
    }
  }

  /// The length of the picker side described by this config.
  final double originalDimension;

  /// The overall taste area of the picker.
  final PickerArea pickerArea;

  /// The taste area for [Recipe.espresso].
  final RecipeArea espressoArea;

  /// The base of the taste area for [Recipe.espresso].
  final RecipeAreaBase espressoAreaBase;

  /// The taste area for [Recipe.ristretto].
  final RecipeArea ristrettoArea;

  /// The base of the taste area for [Recipe.ristretto].
  final RecipeAreaBase ristrettoAreaBase;

  /// The taste area for [Recipe.lungo].
  final RecipeArea lungoArea;

  /// The base of the taste area for [Recipe.lungo].
  final RecipeAreaBase lungoAreaBase;

  /// The thumb configuration.
  final Thumb thumb;

  /// Returns [RecipeArea] for specified [recipe].
  RecipeArea areaForRecipe(Recipe recipe) {
    return switch (recipe) {
      Recipe.espresso => espressoArea,
      Recipe.ristretto => ristrettoArea,
      Recipe.lungo => lungoArea,
    };
  }

  /// Returns [RecipeAreaBase] for specified [recipe].
  RecipeAreaBase areaBaseForRecipe(Recipe recipe) {
    return switch (recipe) {
      Recipe.espresso => espressoAreaBase,
      Recipe.ristretto => ristrettoAreaBase,
      Recipe.lungo => lungoAreaBase,
    };
  }

  /// Returns the [Recipe] whose area is closest to the specified [position].
  ///
  /// **Important:** The [position] should be scaled based on the
  /// [originalDimension] before being passed to this function.
  Recipe recipeForAreaPosition(Offset position) {
    var minDistanceSquare = double.maxFinite;
    var nearestRecipe = Recipe.values.first;

    for (final recipe in Recipe.values) {
      final base = areaBaseForRecipe(recipe);
      final distanceSquare =
          math.pow(position.dx - base.center.dx, 2) +
          math.pow(position.dy - base.center.dy, 2);
      if (distanceSquare < minDistanceSquare) {
        minDistanceSquare = distanceSquare.toDouble();
        nearestRecipe = recipe;
      }
    }

    return nearestRecipe;
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
    originalDimension,
    pickerArea,
    espressoArea,
    espressoAreaBase,
    ristrettoArea,
    ristrettoAreaBase,
    lungoArea,
    lungoAreaBase,
    thumb,
  ];
}

/// The configuration of the overall taste area of the [RecipePicker].
class PickerArea extends Equatable {
  /// Creates a [PickerArea].
  const PickerArea({
    required this.path,
    required this.strokeColor,
    required this.strokeWidth,
  });

  /// Parses [element] as a configuration of [PickerArea].
  ///
  /// Returns [PickerArea] on success, `null` otherwise.
  static PickerArea? tryParse(XmlElement element) {
    final pathData = element.getAttribute('d');
    if (pathData == null) {
      debugMessage("Missing 'd' attribute.");
      return null;
    }

    final strokeColor = int.tryParse(
      element.getAttribute('stroke')?.replaceFirst('#', '0xFF') ?? '',
    );
    if (strokeColor == null) {
      debugMessage("Failed to parse 'stroke' attribute.");
      return null;
    }

    final strokeWidth = double.tryParse(
      element.getAttribute('stroke-width') ?? '',
    );
    if (strokeWidth == null) {
      debugMessage("Failed to parse 'stroke-width' attribute.");
      return null;
    }

    return PickerArea(
      path: parseSvgPathData(pathData),
      strokeColor: Color(strokeColor),
      strokeWidth: strokeWidth,
    );
  }

  /// The path which describes this area.
  final Path path;

  /// The color of the [path] stroke.
  final Color strokeColor;

  /// The width of the [path] stroke.
  final double strokeWidth;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [path, strokeColor, strokeWidth];
}

/// The configuration of the taste area of the specific [Recipe].
class RecipeArea extends Equatable {
  /// Creates a [RecipeArea].
  factory RecipeArea({
    required Offset pathStartPoint,
    required List<RecipeAreaCubicSegment> pathSegments,
    required Color strokeColor,
    required double strokeWidth,
  }) {
    final path = Path()..moveTo(pathStartPoint.dx, pathStartPoint.dy);

    for (var i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      path.cubicTo(
        segment.c1.dx,
        segment.c1.dy,
        segment.c2.dx,
        segment.c2.dy,
        segment.target.dx,
        segment.target.dy,
      );
    }

    return RecipeArea._(
      path: path,
      pathStartPoint: pathStartPoint,
      pathSegments: pathSegments,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
  }

  const RecipeArea._({
    required this.path,
    required this.pathStartPoint,
    required this.pathSegments,
    required this.strokeColor,
    required this.strokeWidth,
  });

  /// Linearly interpolate between two [RecipeArea]s.
  factory RecipeArea.lerp(RecipeArea a, RecipeArea b, double t) {
    assert(
      a.pathSegments.length == b.pathSegments.length,
      'Areas must have the same number of segments.',
    );

    return RecipeArea(
      pathStartPoint: Offset.lerp(a.pathStartPoint, b.pathStartPoint, t)!,
      pathSegments: [
        for (var i = 0; i < a.pathSegments.length; i++)
          RecipeAreaCubicSegment.lerp(a.pathSegments[i], b.pathSegments[i], t),
      ],
      strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t)!,
      strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t)!,
    );
  }

  /// Parses [element] as a configuration of [RecipeArea].
  ///
  /// Returns [RecipeArea] on success, `null` otherwise.
  static RecipeArea? tryParse(XmlElement element) {
    final pathData = element.getAttribute('d');
    if (pathData == null) {
      debugMessage("Missing 'd' attribute.");
      return null;
    }

    final pathParser = SvgPathStringSource(pathData);
    final pathProxy = _RecipeAreaPathProxy();
    final normalizer = SvgPathNormalizer();
    for (final seg in pathParser.parseSegments()) {
      normalizer.emitSegment(seg, pathProxy);
    }

    final strokeColor = int.tryParse(
      element.getAttribute('stroke')?.replaceFirst('#', '0xFF') ?? '',
    );
    if (strokeColor == null) {
      debugMessage("Failed to parse 'stroke' attribute.");
      return null;
    }

    final strokeWidth = double.tryParse(
      element.getAttribute('stroke-width') ?? '',
    );
    if (strokeWidth == null) {
      debugMessage("Failed to parse 'stroke-width' attribute.");
      return null;
    }

    return RecipeArea(
      pathStartPoint: pathProxy.startPoint,
      pathSegments: pathProxy.segments,
      strokeColor: Color(strokeColor),
      strokeWidth: strokeWidth,
    );
  }

  /// The path which describes this area.
  final Path path;

  /// The point from which the [path] starts.
  final Offset pathStartPoint;

  /// The segments that form the [path].
  final List<RecipeAreaCubicSegment> pathSegments;

  /// The color of the [path] stroke.
  final Color strokeColor;

  /// The width of the [path] stroke.
  final double strokeWidth;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
    // path is skipped, comparing pathStartPoint and pathSegments is enough.
    pathStartPoint,
    pathSegments,
    strokeColor,
    strokeWidth,
  ];
}

/// The cubic segment used to describe the [RecipeArea].
class RecipeAreaCubicSegment extends Equatable {
  /// Creates a [RecipeAreaCubicSegment].
  const RecipeAreaCubicSegment({
    required this.c1,
    required this.c2,
    required this.target,
  });

  /// Linearly interpolate between two [RecipeAreaCubicSegment]s.
  factory RecipeAreaCubicSegment.lerp(
    RecipeAreaCubicSegment a,
    RecipeAreaCubicSegment b,
    double t,
  ) {
    return RecipeAreaCubicSegment(
      c1: Offset.lerp(a.c1, b.c1, t)!,
      c2: Offset.lerp(a.c2, b.c2, t)!,
      target: Offset.lerp(a.target, b.target, t)!,
    );
  }

  /// The first control point of the cubic bezier segment.
  final Offset c1;

  /// The second control point of the cubic bezier segment.
  final Offset c2;

  /// The target point of the cubic bezier segment.
  final Offset target;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [c1, c2, target];
}

class _RecipeAreaPathProxy extends PathProxy {
  _RecipeAreaPathProxy() : startPoint = Offset.zero, segments = [];

  Offset startPoint;

  List<RecipeAreaCubicSegment> segments;

  @override
  void moveTo(double x, double y) {
    startPoint = Offset(x, y);
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    segments.add(
      RecipeAreaCubicSegment(
        c1: Offset(x1, y1),
        c2: Offset(x2, y2),
        target: Offset(x3, y3),
      ),
    );
  }

  @override
  void lineTo(double x, double y) {}

  @override
  void close() {}
}

/// The configuration of the base circle of the [RecipeArea].
class RecipeAreaBase extends Equatable {
  /// Creates a [RecipeAreaBase].
  const RecipeAreaBase({
    required this.center,
    required this.radius,
    required this.color,
  });

  /// Parses [element] as a configuration of [RecipeAreaBase].
  ///
  /// Returns [RecipeAreaBase] on success, `null` otherwise.
  static RecipeAreaBase? tryParse(XmlElement element) {
    final cx = double.tryParse(element.getAttribute('cx') ?? '');
    final cy = double.tryParse(element.getAttribute('cy') ?? '');
    if (cx == null || cy == null) {
      debugMessage("'cx' and 'cy' attributes must be specified.");
      return null;
    }

    final r = double.tryParse(element.getAttribute('r') ?? '');
    if (r == null) {
      debugMessage("Missing 'r' attribute.");
      return null;
    }

    final fill = int.tryParse(
      element.getAttribute('fill')?.replaceFirst('#', '0xFF') ?? '',
    );
    if (fill == null) {
      debugMessage("Failed to parse 'fill' attribute.");
      return null;
    }

    return RecipeAreaBase(
      center: Offset(cx, cy),
      radius: r,
      color: Color(fill),
    );
  }

  /// The center point of the base.
  final Offset center;

  /// The radius of the base.
  final double radius;

  /// The color of the base.
  final Color color;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [center, radius, color];
}

/// The configuration of the [RecipePicker]'s thumb.
class Thumb extends Equatable {
  /// Creates a [Thumb].
  const Thumb({required this.radius});

  /// Parses [element] as a configuration of [Thumb].
  ///
  /// Returns [Thumb] on success, `null` otherwise.
  static Thumb? tryParse(XmlElement element) {
    final r = double.tryParse(element.getAttribute('r') ?? '');
    if (r == null) {
      debugMessage("Missing 'r' attribute.");
      return null;
    }

    return Thumb(radius: r);
  }

  /// The radius of the thumb.
  final double radius;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [radius];
}
