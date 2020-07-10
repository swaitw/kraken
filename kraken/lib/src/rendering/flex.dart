import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    this.childCount,
    this.totalFlexGrow,
    this.hasFlexShrink,
  );

  final double mainAxisExtent;
  final double crossAxisExtent;
  final int childCount;
  final int totalFlexGrow;
  final bool hasFlexShrink;
}

class RenderFlexParentData extends RenderLayoutParentData {
  /// Flex grow
  int flexGrow;

  /// Flex shrink
  int flexShrink;

  /// Flex basis
  String flexBasis;

  /// Align self
  AlignSelf alignSelf = AlignSelf.auto;

  @override
  String toString() => '${super.toString()}; flexGrow=$flexGrow; flexShrink=$flexShrink; flexBasis=$flexBasis; alignSelf=$alignSelf';
}

bool isHorizontalFlexDirection(FlexDirection flexDirection) {
  return flexDirection == FlexDirection.row || flexDirection == FlexDirection.rowReverse;
}

bool isVerticalFlexDirection(FlexDirection flexDirection) {
  return flexDirection == FlexDirection.columnReverse || flexDirection == FlexDirection.column;
}

FlexDirection flipDirection(FlexDirection direction) {
  assert(direction != null);
  switch (direction) {
    case FlexDirection.row:
      return FlexDirection.column;
    case FlexDirection.column:
      return FlexDirection.row;
    case FlexDirection.rowReverse:
      return FlexDirection.columnReverse;
    case FlexDirection.columnReverse:
      return FlexDirection.rowReverse;
  }
  return null;
}

/// sets whether flex items are forced onto one line or can wrap onto multiple lines.
/// If wrapping is allowed, it sets the direction that lines are stacked.
enum FlexWrap {
  /// The flex items are laid out in a single line which may cause the flex container to overflow.
  /// The cross-start is either equivalent to start or before depending flex-direction value.
  /// This is the default value.
  nowrap,

  /// The flex items break into multiple lines.
  /// The cross-start is either equivalent to start or before depending flex-direction value and the cross-end is the opposite of the specified cross-start.
  wrap,

  /// Behaves the same as wrap but cross-start and cross-end are permuted.
  wrapReverse
}

/// sets how flex items are placed in the flex container defining the main axis and the direction (normal or reversed).
enum FlexDirection {
  /// The flex container's main-axis is defined to be the same as the text direction.
  /// The main-start and main-end points are the same as the content direction.
  row,

  /// Behaves the same as row but the main-start and main-end points are permuted.
  rowReverse,

  /// The flex container's main-axis is the same as the block-axis.
  /// The main-start and main-end points are the same as the before and after points of the writing-mode.
  column,

  /// Behaves the same as column but the main-start and main-end are permuted.
  columnReverse
}

/// Defines how the browser distributes space between and around content items along the main-axis of a flex container,
/// and the inline axis of a grid container.
enum JustifyContent {
  /// The items are packed flush to each other toward the edge of the alignment container depending on the flex container's main-start side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like start.
  flexStart,

  /// The items are packed flush to each other toward the start edge of the alignment container in the main axis.
  start,

  /// The items are packed flush to each other toward the edge of the alignment container depending on the flex container's main-end side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like end.
  flexEnd,

  /// The items are packed flush to each other toward the end edge of the alignment container in the main axis.
  end,

  /// The items are packed flush to each other toward the center of the alignment container along the main axis.
  center,

  /// The items are evenly distributed within the alignment container along the main axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The first item is flush with the main-start edge, and the last item is flush with the main-end edge.
  spaceBetween,

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair of adjacent items is the same.
  /// The empty space before the first and after the last item equals half of the space between each pair of adjacent items.
  spaceAround,
}

/// Sets the distribution of space between and around content items along a flexbox's cross-axis.
enum AlignContent {
  /// The items are packed flush to each other against the edge of the alignment container depending on the flex container's cross-start side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like start.
  flexStart,

  /// The items are packed flush to each other against the start edge of the alignment container in the cross axis.
  start,

  /// The items are packed flush to each other against the edge of the alignment container depending on the flex container's cross-end side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like end.
  flexEnd,

  /// The items are packed flush to each other against the end edge of the alignment container in the cross axis.
  end,

  /// The items are packed flush to each other in the center of the alignment container along the cross axis.
  center,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The first item is flush with the start edge of the alignment container in the cross axis, and the last item is flush with the end edge of the alignment container in the cross axis.
  spaceBetween,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The empty space before the first and after the last item equals half of the space between each pair of adjacent items.
  spaceAround,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items, the start edge and the first item,
  /// and the end edge and the last item, are all exactly the same.
  spaceEvenly,

  /// If the combined size of the items along the cross axis is less than the size of the alignment container,
  /// any auto-sized items have their size increased equally (not proportionally),
  /// while still respecting the constraints imposed by max-height/max-width (or equivalent functionality),
  /// so that the combined size exactly fills the alignment container along the cross axis.
  stretch
}

/// Set the space distributed between and around content items along the cross-axis of their container.
enum AlignItems {
  /// The cross-start margin edges of the flex items are flushed with the cross-start edge of the line.
  flexStart,

  /// The items are packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start,

  /// The cross-end margin edges of the flex items are flushed with the cross-end edge of the line.
  flexEnd,

  /// The items are packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end,

  /// The flex items' margin boxes are centered within the line on the cross-axis.
  /// If the cross-size of an item is larger than the flex container, it will overflow equally in both directions.
  center,

  /// Flex items are stretched such that the cross-size of the item's margin box is the same as the line while respecting width and height constraints.
  stretch,

  /// All flex items are aligned such that their flex container baselines align.
  /// The item with the largest distance between its cross-start margin edge and its baseline is flushed with the cross-start edge of the line.
  baseline
}

/// Overrides a flex item's align-items value
enum AlignSelf {
  /// Computes to the parent's align-items value.
  auto,

  /// The cross-start margin edges of the flex items are flushed with the cross-start edge of the line.
  flexStart,

  /// The items are packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start,

  /// The cross-end margin edges of the flex items are flushed with the cross-end edge of the line.
  flexEnd,

  /// The items are packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end,

  /// The flex items' margin boxes are centered within the line on the cross-axis.
  /// If the cross-size of an item is larger than the flex container, it will overflow equally in both directions.
  center,

  /// Flex items are stretched such that the cross-size of the item's margin box is the same as the line while respecting width and height constraints.
  stretch,

  /// All flex items are aligned such that their flex container baselines align.
  /// The item with the largest distance between its cross-start margin edge and its baseline is flushed with the cross-start edge of the line.
  baseline
}

bool _startIsTopLeft(FlexDirection direction) {
  assert(direction != null);

  switch (direction) {
    case FlexDirection.column:
    case FlexDirection.row:
      return true;
    case FlexDirection.rowReverse:
    case FlexDirection.columnReverse:
      return false;
  }

  return null;
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlexLayout] to position
/// its children._
///
/// Layout for a [RenderFlexLayout] proceeds in 5 steps:
///
/// 1. Layout placeholder child of positioned element(absolute/fixed) in new layer
/// 2. Layout no positioned children with no constraints, compare children width with flex container main axis extent
///    to caculate total flex lines
/// 3. Caculate horizontal constraints of each child according to availabe horizontal space in each flex line
///    and flex-grow and flex-shrink properties
/// 4. Caculate vertical constraints of each child accordint to availabe vertical space in flex container vertial
///    and align-content properties and set
/// 5. Layout children again with above cacluated constraints
/// 6. Caculate flex line leading space and between space and position children in each flex line
///
class RenderFlexLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RenderFlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RenderFlexParentData>,
        DebugOverflowIndicatorMixin,
        CSSComputedMixin {
  /// Creates a flex render object.
  ///
  /// By default, the flex layout is horizontal and children are aligned to the
  /// start of the main axis and the center of the cross axis.
  RenderFlexLayout({
    List<RenderBox> children,
    FlexDirection flexDirection = FlexDirection.row,
    FlexWrap flexWrap = FlexWrap.nowrap,
    JustifyContent justifyContent = JustifyContent.flexStart,
    AlignItems alignItems = AlignItems.stretch,
    AlignContent alignContent = AlignContent.stretch,
    this.targetId,
    this.style,
  })  : assert(flexDirection != null),
        assert(flexWrap != null),
        assert(justifyContent != null),
        assert(alignItems != null),
        assert(alignContent != null),
        _flexDirection = flexDirection,
        _flexWrap = flexWrap,
        _justifyContent = justifyContent,
        _alignContent = alignContent,
        _alignItems = alignItems {
    addAll(children);
  }

  // Element style;
  CSSStyleDeclaration style;

  // id of current element
  int targetId;

  /// The direction to use as the main axis.
  FlexDirection get flexDirection => _flexDirection;
  FlexDirection _flexDirection;

  set flexDirection(FlexDirection value) {
    assert(value != null);
    if (_flexDirection != value) {
      _flexDirection = value;
      markNeedsLayout();
    }
  }

  /// whether flex items are forced onto one line or can wrap onto multiple lines.
  FlexWrap get flexWrap => _flexWrap;
  FlexWrap _flexWrap;

  set flexWrap(FlexWrap value) {
    assert(value != null);
    if (_flexWrap != value) {
      _flexWrap = value;
      markNeedsLayout();
    }
  }

  JustifyContent get justifyContent => _justifyContent;
  JustifyContent _justifyContent;

  set justifyContent(JustifyContent value) {
    assert(value != null);
    if (_justifyContent != value) {
      _justifyContent = value;
      markNeedsLayout();
    }
  }

  AlignItems get alignItems => _alignItems;
  AlignItems _alignItems;

  set alignItems(AlignItems value) {
    assert(value != null);
    if (_alignItems != value) {
      _alignItems = value;
      markNeedsLayout();
    }
  }

  AlignContent get alignContent => _alignContent;
  AlignContent _alignContent;
  set alignContent(AlignContent value) {
    assert(value != null);
    if (_alignContent == value) return;
    _alignContent = value;
    markNeedsLayout();
  }

  // Set during layout if overflow occurred on the main axis.
  double _overflow;

  // Check whether any meaningful overflow is present. Values below an epsilon
  // are treated as not overflowing.
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderFlexParentData) {
      if (child is RenderElementBoundary) {
        child.parentData = getPositionParentDataFromStyle(child.style);
      } else {
        child.parentData = RenderFlexParentData();
      }
    }
  }

  double _getIntrinsicSize({
    FlexDirection sizingDirection,
    double extent, // the extent in the direction that isn't the sizing direction
    _ChildSizingFunction childSize, // a method to find the size in the sizing direction
  }) {
    if (_flexDirection == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlexGrow = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        final int flex = _getFlexGrow(child);
        totalFlexGrow += flex;
        if (flex > 0) {
          final double flexFraction = childSize(child, extent) / _getFlexGrow(child);
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize(child, extent);
        }
        final RenderFlexParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }
      return maxFlexFractionSoFar * totalFlexGrow + inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.

      // Get inflexible space using the max intrinsic dimensions of fixed children in the main direction.
      final double availableMainSpace = extent;
      int totalFlexGrow = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        final int flex = _getFlexGrow(child);
        totalFlexGrow += flex;
        double mainSize;
        double crossSize;
        if (flex == 0) {
          switch (_flexDirection) {
            case FlexDirection.rowReverse:
            case FlexDirection.row:
              mainSize = child.getMaxIntrinsicWidth(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
            case FlexDirection.column:
            case FlexDirection.columnReverse:
              mainSize = child.getMaxIntrinsicHeight(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
          }
          inflexibleSpace += mainSize;
          maxCrossSize = math.max(maxCrossSize, crossSize);
        }
        final RenderFlexParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're overconstrained spacePerFlex can be negative.
      final double spacePerFlex = math.max(0.0, (availableMainSpace - inflexibleSpace) / totalFlexGrow);

      // Size remaining (flexible) items, find the maximum cross size.
      child = firstChild;
      while (child != null) {
        final int flex = _getFlexGrow(child);
        if (flex > 0) maxCrossSize = math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
        final RenderFlexParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.row,
      extent: height,
      childSize: (RenderBox child, double extent) => child.getMinIntrinsicWidth(extent),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.row,
      extent: height,
      childSize: (RenderBox child, double extent) => child.getMaxIntrinsicWidth(extent),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.column,
      extent: width,
      childSize: (RenderBox child, double extent) => child.getMinIntrinsicHeight(extent),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.column,
      extent: width,
      childSize: (RenderBox child, double extent) => child.getMaxIntrinsicHeight(extent),
    );
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    if (_flexDirection == FlexDirection.row) return defaultComputeDistanceToHighestActualBaseline(baseline);
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  int _getFlexGrow(RenderBox child) {
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexGrow ?? 0;
  }

  int _getFlexShrink(RenderBox child) {
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexShrink ?? 1;
  }

  String _getFlexBasis(RenderBox child) {
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexBasis ?? 'auto';
  }

  double _getShrinkConstraints(RenderBox child, Map<int, dynamic> childSizeMap, double freeSpace) {
    double totalExtent = 0;
    childSizeMap.forEach((targetId, item) {
      totalExtent += item['flexShrink'] * item['size'];
    });

    int childNodeId;
    if (child is RenderTextBox) {
      childNodeId = child.targetId;
    } else if (child is RenderElementBoundary) {
      childNodeId = child.targetId;
    }
    dynamic current = childSizeMap[childNodeId];
    double currentExtent = current['flexShrink'] * current['size'];

    double minusConstraints = (currentExtent / totalExtent) * freeSpace;
    return minusConstraints;
  }

  BoxSizeType _getChildWidthSizeType(RenderBox child) {
    if (child is RenderTextBox) {
      return child.widthSizeType;
    } else if (child is RenderElementBoundary) {
      return child.widthSizeType;
    }
    return null;
  }

  BoxSizeType _getChildHeightSizeType(RenderBox child) {
    if (child is RenderTextBox) {
      return child.heightSizeType;
    } else if (child is RenderElementBoundary) {
      return child.heightSizeType;
    }
    return null;
  }

  bool _isCrossAxisDefinedSize(RenderBox child) {
    BoxSizeType widthSizeType = _getChildWidthSizeType(child);
    BoxSizeType heightSizeType = _getChildHeightSizeType(child);

    if (style != null) {
      switch (_flexDirection) {
        case FlexDirection.row:
        case FlexDirection.rowReverse:
          return heightSizeType != null && heightSizeType == BoxSizeType.specified;
        case FlexDirection.column:
        case FlexDirection.columnReverse:
          return widthSizeType != null && widthSizeType == BoxSizeType.specified;
      }
    }

    return false;
  }

  double _getBaseConstraints(RenderObject child) {
    // set default value
    double minConstraints = 0;
    if (child is RenderTextBox) {
      return minConstraints;
    } else if (child is RenderElementBoundary) {
      String flexBasis = _getFlexBasis(child);

      if (_flexDirection == FlexDirection.row) {
        String width = child.style['width'];
        if (flexBasis == 'auto') {
          if (width != null) {
            minConstraints = CSSLength.toDisplayPortValue(width) ?? 0;
          } else {
            minConstraints = 0;
          }
        } else {
          minConstraints = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
        }
      } else {
        String height = child.style['height'];
        if (flexBasis == 'auto') {
          if (height != null) {
            minConstraints = CSSLength.toDisplayPortValue(height) ?? 0;
          } else {
            minConstraints = 0;
          }
        } else {
          minConstraints = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
        }
      }
    }
    return minConstraints;
  }

  double _getCrossSize(RenderBox child) {
    switch (_flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        return child.size.height;
      case FlexDirection.columnReverse:
      case FlexDirection.column:
        return child.size.width;
    }
    return null;
  }

  double _getMainSize(RenderBox child) {
    switch (_flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        return child.size.width;
      case FlexDirection.column:
      case FlexDirection.columnReverse:
        return child.size.height;
    }
    return null;
  }

  // detect should use content size suggestion instead of content-based minimum size
  double getContentBasedMinimumSize(RenderBox child, double maxMainSize) {
    if (child is RenderElementBoundary) {
      CSSStyleDeclaration style = child.style;

      switch (_flexDirection) {
        case FlexDirection.column:
        case FlexDirection.columnReverse:
          if (style.contains('minHeight')) {
            double minHeight = CSSLength.toDisplayPortValue(style['minHeight']);
            return minHeight < maxMainSize ? maxMainSize : minHeight;
          }
          return child.size.height > maxMainSize ? child.size.height : maxMainSize;
        case FlexDirection.row:
        case FlexDirection.rowReverse:
          if (style.contains('minWidth')) {
            double minWidth = CSSLength.toDisplayPortValue(style['minWidth']);
            return minWidth < maxMainSize ? maxMainSize : minWidth;
          }
          return child.size.width > maxMainSize ? child.size.width : maxMainSize;
      }
    }
    return maxMainSize;
  }

  @override
  void performLayout() {
    RenderBox child = firstChild;
    Element element = getEventTargetByTargetId<Element>(targetId);
    // Layout positioned element
    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
      // Layout placeholder of positioned element(absolute/fixed) in new layer
      if (childParentData.isPositioned) {
        layoutPositionedChild(element, this, child);
      } else if (child is RenderPositionHolder && isPlaceholderPositioned(child)) {
        _layoutChildren(child);
      }

      child = childParentData.nextSibling;
    }
    // Layout non positioned element and its placeholder
    _layoutChildren(null);

    // Set offset of positioned elemen
    child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (childParentData.isPositioned) {
        setPositionedChildOffset(element, this, child, size);
      }
      child = childParentData.nextSibling;
    }
  }

  bool _isChildDisplayNone(RenderObject child) {
    CSSStyleDeclaration style;
    if (child is RenderTextBox) {
      style = child.style;
    } else if (child is RenderElementBoundary) {
      style = child.style;
    }

    if (style == null) return false;

    return style['display'] == 'none';
  }

  bool isPlaceholderPositioned(RenderObject child) {
    if (child is RenderPositionHolder) {
      RenderElementBoundary realDisplayedBox = child.realDisplayedBox;
      CSSPositionType positionType = resolvePositionFromStyle(realDisplayedBox.style);
      if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
        return true;
      }
    }
    return false;
  }

  void _layoutChildren(RenderPositionHolder placeholderChild) {
    double elementWidth = getElementComputedWidth(targetId);
    double elementHeight = getElementComputedHeight(targetId);

    // If no child exists, stop layout.
    if (childCount == 0) {
      Size preferredSize = Size(
        elementWidth ?? 0,
        elementHeight ?? 0,
      );
      size = constraints.constrain(preferredSize);
      return;
    }

    assert(constraints != null);

    double maxWidth = 0;
    if (elementWidth != null) {
      maxWidth = elementWidth;
    }

    double maxHeight = 0;
    if (elementHeight != null) {
      maxHeight = elementHeight;
    }

    // maxMainSize still can be updated by content size suggestion and transferred size suggestion
    // https://www.w3.org/TR/css-flexbox-1/#specified-size-suggestion
    // https://www.w3.org/TR/css-flexbox-1/#content-size-suggestion
    double maxMainSize = isHorizontalFlexDirection(_flexDirection) ? maxWidth : maxHeight;
    double maxCrossSize = isHorizontalFlexDirection(_flexDirection) ? maxHeight : maxWidth;
    final bool canFlex = maxMainSize < double.infinity;
    final BoxSizeType mainSizeType = maxMainSize == 0.0 ? BoxSizeType.automatic : BoxSizeType.specified;

    double crossSize = 0.0;
    RenderBox child = placeholderChild ?? firstChild;
    Map<int, dynamic> childSizeMap = {};

    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    int _effectiveChildCount = 0;

    // Determine used flex factor, size inflexible items, calculate free space.
    int totalFlexGrow = 0;
    bool hasFlexShrink = false;
    int totalChildren = 0;

    // Max length of each flex line
    double flexLineLimit = 0.0;
    if (elementWidth != null) {
      flexLineLimit = elementWidth;
    } else {
      flexLineLimit = CSSComputedMixin.getElementComputedMaxWidth(targetId);
    }

    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
      // Exclude positioned placeholder renderObject when layout non placeholder object
      // and positioned renderObject
      if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
        child = childParentData.nextSibling;
        continue;
      }

      double baseConstraints = _getBaseConstraints(child);
      BoxConstraints innerConstraints;

      int childNodeId;
      if (child is RenderTextBox) {
        childNodeId = child.targetId;
      } else if (child is RenderElementBoundary) {
        childNodeId = child.targetId;
      }
      CSSStyleDeclaration childStyle;
      if (child is RenderTextBox) {
        childStyle = getEventTargetByTargetId<Element>(targetId)?.style;
      } else if (child is RenderElementBoundary) {
        childStyle = getEventTargetByTargetId<Element>(childNodeId)?.style;
      }

      BoxSizeType sizeType = _getChildHeightSizeType(child);
      if (isHorizontalFlexDirection(_flexDirection)) {
        double maxCrossAxisSize;

        // Caculate max height constaints
        if (sizeType == BoxSizeType.specified) {
          maxCrossAxisSize = CSSLength.toDisplayPortValue(childStyle['height']);
        } else {
          // Child in flex line expand automatic when height is not specified
          if (flexWrap == FlexWrap.wrap || flexWrap == FlexWrap.wrapReverse) {
            maxCrossAxisSize = double.infinity;
          } else if (child is RenderTextBox) {
            maxCrossAxisSize = double.infinity;
          } else {
            maxCrossAxisSize = elementHeight ?? double.infinity;
          }
        }
        innerConstraints = BoxConstraints(
          minWidth: baseConstraints,
          maxHeight: maxCrossAxisSize,
        );
      } else {
        innerConstraints = BoxConstraints(
          minHeight: baseConstraints
        );
      }

      child.layout(innerConstraints, parentUsesSize: true);
      double childMainSize = _getMainSize(child);
      double childCrossSize = _getCrossSize(child);

      // get minimum content based size
      // https://www.w3.org/TR/css-flexbox-1/#min-size-auto
      maxMainSize = getContentBasedMinimumSize(child, maxMainSize);

      childSizeMap[childNodeId] = {
        'size': _getMainSize(child),
        'flexShrink': _getFlexShrink(child),
      };

      // Caculate flex line
      if ((flexWrap == FlexWrap.wrap || flexWrap == FlexWrap.wrapReverse) &&
        _effectiveChildCount > 0 &&
        (runMainAxisExtent + childMainSize > flexLineLimit)) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;

        runMetrics.add(_RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          _effectiveChildCount,
          totalFlexGrow,
          hasFlexShrink,
        ));
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        _effectiveChildCount = 0;

        totalFlexGrow = 0;
        hasFlexShrink = false;
      }
      runMainAxisExtent += childMainSize;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossSize);
      _effectiveChildCount += 1;

      childParentData.runIndex = runMetrics.length;

      assert(child.parentData == childParentData);

      totalChildren++;
      final int flexGrow = _getFlexGrow(child);
      final int flexShrink = _getFlexShrink(child);
      if (flexShrink != 0) {
        hasFlexShrink = true;
      }

      if (flexGrow > 0) {
        assert(() {
          final String identity = isHorizontalFlexDirection(_flexDirection) ? 'row' : 'column';
          final String axis = isHorizontalFlexDirection(_flexDirection) ? 'horizontal' : 'vertical';
          final String dimension = isHorizontalFlexDirection(_flexDirection) ? 'width' : 'height';
          DiagnosticsNode error, message;
          final List<DiagnosticsNode> addendum = <DiagnosticsNode>[];
          if (!canFlex) {
            error = ErrorSummary(
              'RenderFlex children have non-zero flex but incoming $dimension constraints are unbounded.');
            message = ErrorDescription(
              'When a $identity is in a parent that does not provide a finite $dimension constraint, for example '
                'if it is in a $axis scrollable, it will try to shrink-wrap its children along the $axis '
                'axis. Setting a flex on a child (e.g. using Expanded) indicates that the child is to '
                'expand to fill the remaining space in the $axis direction.');
            RenderBox node = this;
            switch (_flexDirection) {
              case FlexDirection.row:
              case FlexDirection.rowReverse:
                while (!node.constraints.hasBoundedWidth && node.parent is RenderBox) node = node.parent;
                if (!node.constraints.hasBoundedWidth) node = null;
                break;
              case FlexDirection.column:
              case FlexDirection.columnReverse:
                while (!node.constraints.hasBoundedHeight && node.parent is RenderBox) node = node.parent;
                if (!node.constraints.hasBoundedHeight) node = null;
                break;
            }
            if (node != null) {
              addendum.add(node.describeForError('The nearest ancestor providing an unbounded width constraint is'));
            }
            addendum.add(ErrorHint('See also: https://flutter.dev/layout/'));
          } else {
            return true;
          }
          throw FlutterError.fromParts(<DiagnosticsNode>[
            error,
            message,
            ErrorDescription(
              'These two directives are mutually exclusive. If a parent is to shrink-wrap its child, the child '
                'cannot simultaneously expand to fit its parent.'),
            ErrorHint('Consider setting mainAxisSize to MainAxisSize.min and using FlexFit.loose fits for the flexible '
              'children (using Flexible rather than Expanded). This will allow the flexible children '
              'to size themselves to less than the infinite remaining space they would otherwise be '
              'forced to take, and then will cause the RenderFlex to shrink-wrap the children '
              'rather than expanding to fit the maximum constraints provided by the parent.'),
            ErrorDescription(
              'If this message did not help you determine the problem, consider using debugDumpRenderTree():\n'
                '  https://flutter.dev/debugging/#rendering-layer\n'
                '  http://api.flutter.dev/flutter/rendering/debugDumpRenderTree.html'),
            describeForError('The affected RenderFlex is', style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<dynamic>('The creator information is set to', debugCreator,
              style: DiagnosticsTreeStyle.errorProperty)
          ]
            ..addAll(addendum)
            ..add(ErrorDescription(
              'If none of the above helps enough to fix this problem, please don\'t hesitate to file a bug:\n'
                '  https://github.com/flutter/flutter/issues/new?template=BUG.md')));
        }());
        totalFlexGrow += childParentData.flexGrow;
      }

      crossSize = crossAxisExtent != 0.0 ? crossAxisExtent : math.max(crossSize, childMainSize);

      // Only layout placeholder renderObject child
      child = placeholderChild == null ? childParentData.nextSibling : null;
    }

    if (_effectiveChildCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        _effectiveChildCount,
        totalFlexGrow,
        hasFlexShrink,
      ));

      crossSize = crossAxisExtent;
    } else {
      // Stop layout when no non positioned child exists
      Size preferredSize = Size(
        elementWidth ?? 0,
        elementHeight ?? 0,
      );
      size = constraints.constrain(preferredSize);
      return;
    }

    final int runCount = runMetrics.length;

    double containerCrossAxisExtent = 0.0;

    bool isVerticalDirection = isVerticalFlexDirection(_flexDirection);
    if (isVerticalDirection) {
      containerCrossAxisExtent = elementWidth ?? 0;
    } else {
      containerCrossAxisExtent = elementHeight ?? 0;
    }

    final double crossAxisFreeSpace = math.max(0.0, containerCrossAxisExtent - crossAxisExtent);

    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;
    switch (alignContent) {
      case AlignContent.flexStart:
      case AlignContent.start:
        break;
      case AlignContent.flexEnd:
      case AlignContent.end:
        runLeadingSpace = crossAxisFreeSpace;
        break;
      case AlignContent.center:
        runLeadingSpace = crossAxisFreeSpace / 2.0;
        break;
      case AlignContent.spaceBetween:
        runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
        break;
      case AlignContent.spaceAround:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        runLeadingSpace = runBetweenSpace / 2.0;
        break;
      case AlignContent.spaceEvenly:
        runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
        runLeadingSpace = runBetweenSpace;
        break;
      case AlignContent.stretch:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        break;
    }

    double crossAxisOffset = runLeadingSpace;

    child = placeholderChild != null ? placeholderChild : firstChild;

    // Layout child on each flex line
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final int totalFlexGrow = metrics.totalFlexGrow;
      final bool hasFlexShrink = metrics.hasFlexShrink;

      // Distribute free space to flexible children, and determine baseline.
      final double freeMainAxisSpace =
      mainSizeType == BoxSizeType.automatic ? 0 : (canFlex ? maxMainSize : 0.0) - runMainAxisExtent;
      bool isFlexGrow = freeMainAxisSpace >= 0 && totalFlexGrow > 0;
      bool isFlexShrink = freeMainAxisSpace < 0 && hasFlexShrink;
      if (isFlexGrow || isFlexShrink || alignItems == AlignItems.stretch && placeholderChild == null) {
        final double spacePerFlex = canFlex && totalFlexGrow > 0 ? (freeMainAxisSpace / totalFlexGrow) : double.nan;
        while (child != null) {
          final RenderFlexParentData childParentData = child.parentData;
          // Exclude positioned placeholder renderObject when layout non placeholder object
          // and positioned renderObject
          if (placeholderChild == null &&
            (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
            child = childParentData.nextSibling;
            continue;
          }

          if (childParentData.runIndex != i) break;

          double maxChildExtent;
          double minChildExtent;

          if (_isChildDisplayNone(child)) {
            // Skip No Grow and unsized child.
            child = childParentData.nextSibling;
            continue;
          }

          if (isFlexGrow && freeMainAxisSpace >= 0) {
            final int flexGrow = _getFlexGrow(child);
            final double mainSize = _getMainSize(child);
            maxChildExtent = canFlex ? mainSize + spacePerFlex * flexGrow : double.infinity;

            double baseConstraints = _getBaseConstraints(child);
            // get the maximum child size between baseConstraints and maxChildExtent.
            maxChildExtent = math.max(baseConstraints, maxChildExtent);
            minChildExtent = maxChildExtent;
          } else if (isFlexShrink) {
            int childNodeId;
            if (child is RenderTextBox) {
              childNodeId = child.targetId;
            } else if (child is RenderElementBoundary) {
              childNodeId = child.targetId;
            }

            // Skip RenderPlaceHolder child
            if (childNodeId == null) {
              child = childParentData.nextSibling;
              continue;
            }

            double shrinkValue = _getShrinkConstraints(child, childSizeMap, freeMainAxisSpace);

            dynamic current = childSizeMap[childNodeId];
            double computedSize = current['size'] + shrinkValue;

            // if shrink size is lower than child's min-content, should reset to min-content size
            // @TODO no proper way to get real min-content of child element.
            if (mainSizeType == BoxSizeType.automatic) {
              if (isHorizontalFlexDirection(flexDirection) &&
                computedSize < child.size.width &&
                _getChildWidthSizeType(child) == BoxSizeType.automatic) {
                computedSize = child.size.width;
              } else if (isVerticalFlexDirection(flexDirection) &&
                computedSize < child.size.height &&
                _getChildHeightSizeType(child) == BoxSizeType.automatic) {
                computedSize = child.size.height;
              }
            }

            maxChildExtent = minChildExtent = computedSize;
          } else {
            maxChildExtent = minChildExtent = _getMainSize(child);
          }

          BoxConstraints innerConstraints;
          // @TODO: minChildExtent.isNegative
          if (alignItems == AlignItems.stretch) {
            switch (_flexDirection) {
              case FlexDirection.row:
              case FlexDirection.rowReverse:
                double minMainAxisSize = minChildExtent ?? child.size.width;
                double maxMainAxisSize = maxChildExtent ?? double.infinity;
                double minCrossAxisSize;
                double maxCrossAxisSize;

                // if child have predefined size
                if (_isCrossAxisDefinedSize(child)) {
                  if (child.hasSize) {
                    BoxSizeType sizeType = _getChildHeightSizeType(child);

                    // child have predefined height, use previous layout height.
                    if (sizeType == BoxSizeType.specified) {
                      // for empty child width, maybe it's unloaded image, set constraints range.
                      if (child.size.isEmpty) {
                        minCrossAxisSize = 0.0;
                        maxCrossAxisSize = constraints.maxHeight;
                      } else {
                        minCrossAxisSize = child.size.height;
                        maxCrossAxisSize = child.size.height;
                      }
                    } else {
                      // expand child's height to constraints.maxHeight;
                      minCrossAxisSize = constraints.maxHeight;
                      maxCrossAxisSize = constraints.maxHeight;
                    }
                  } else {
                    // child is't layout, so set minHeight
                    minCrossAxisSize = maxCrossSize;
                    maxCrossSize = double.infinity;
                  }
                } else if (child is! RenderTextBox) {
                  // Stretch child height to flex line' height
                  double flexLineHeight = runCrossAxisExtent + runBetweenSpace;
                  minCrossAxisSize = flexLineHeight;
                  maxCrossAxisSize = flexLineHeight;
                } else {
                  minCrossAxisSize = 0.0;
                  maxCrossAxisSize = double.infinity;
                }

                innerConstraints = BoxConstraints(
                  minWidth: minMainAxisSize,
                  maxWidth: maxMainAxisSize,
                  minHeight: minCrossAxisSize,
                  maxHeight: maxCrossAxisSize);
                break;
              case FlexDirection.column:
              case FlexDirection.columnReverse:
                double mainAxisMinSize = minChildExtent ?? child.size.height;
                double mainAxisMaxSize = maxChildExtent ?? double.infinity;
                double minCrossAxisSize;
                double maxCrossAxisSize;

                // if child have predefined size
                if (_isCrossAxisDefinedSize(child)) {
                  if (child.hasSize) {
                    BoxSizeType sizeType = _getChildWidthSizeType(child);

                    // child have predefined width, use previous layout width.
                    if (sizeType == BoxSizeType.specified) {
                      // for empty child width, maybe it's unloaded image, set constraints range.
                      if (child.size.isEmpty) {
                        minCrossAxisSize = 0.0;
                        maxCrossAxisSize = constraints.maxWidth;
                      } else {
                        minCrossAxisSize = child.size.width;
                        maxCrossAxisSize = child.size.width;
                      }
                    } else {
                      // expand child's height to constraints.maxWidth;
                      minCrossAxisSize = constraints.maxWidth;
                      maxCrossAxisSize = constraints.maxWidth;
                    }
                  } else {
                    // child is't layout, so set minHeight
                    minCrossAxisSize = maxCrossSize;
                    maxCrossSize = double.infinity;
                  }
                } else if (child is! RenderTextBox) {
                  // only scretch ElementBox, not TextBox.
                  minCrossAxisSize = maxCrossSize;
                  maxCrossAxisSize = math.max(maxCrossSize, constraints.maxWidth);
                } else {
                  // for RenderTextBox, there are no cross Axis constraints.
                  minCrossAxisSize = 0.0;
                  maxCrossAxisSize = double.infinity;
                }

                innerConstraints = BoxConstraints(
                  minHeight: mainAxisMinSize,
                  maxHeight: mainAxisMaxSize,
                  minWidth: minCrossAxisSize,
                  maxWidth: maxCrossAxisSize);
                break;
            }
          } else {
            switch (_flexDirection) {
              case FlexDirection.row:
              case FlexDirection.rowReverse:
                innerConstraints =
                  BoxConstraints(minWidth: minChildExtent, maxWidth: maxChildExtent, maxHeight: constraints.maxHeight);
                break;
              case FlexDirection.column:
              case FlexDirection.columnReverse:
                innerConstraints =
                  BoxConstraints(maxWidth: constraints.maxWidth, minHeight: minChildExtent, maxHeight: maxChildExtent);
                break;
            }
          }
          child.layout(innerConstraints, parentUsesSize: true);
          crossSize = math.max(crossSize, _getCrossSize(child));
          // Only layout placeholder renderObject child
          child = childParentData.nextSibling;
        }
      }
    }

    _RunMetrics maxMainSizeMetrics = runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    // Find max size of flex lines
    double maxAllocatedMainSize = maxMainSizeMetrics.mainAxisExtent;

    // Align items along the main axis.
    final double idealMainSize = mainSizeType != BoxSizeType.automatic ? maxMainSize : maxAllocatedMainSize;

    double actualSize;

    // Get layout width from children's width by flex axis
    double constraintWidth = isHorizontalFlexDirection(_flexDirection) ? idealMainSize : crossSize;
    // Get max of element's width and children's width if element's width exists
    if (elementWidth != null) {
      constraintWidth = math.max(constraintWidth, elementWidth);
    }

    // Get layout height from children's height by flex axis
    double constraintHeight = isHorizontalFlexDirection(_flexDirection) ? crossSize : idealMainSize;
    // Get max of element's height and children's height if element's height exists
    if (elementHeight != null) {
      constraintHeight = math.max(constraintHeight, elementHeight);
    }

    switch (_flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        size = constraints
            .constrain(Size(math.max(constraintWidth, idealMainSize), constraints.constrainHeight(constraintHeight)));
        actualSize = size.width;
        crossSize = size.height;
        break;
      case FlexDirection.column:
      case FlexDirection.columnReverse:
        size = constraints
            .constrain(Size(math.max(constraintWidth, crossSize), constraints.constrainHeight(constraintHeight)));
        actualSize = size.height;
        crossSize = size.width;
        break;
    }
    child = placeholderChild != null ? placeholderChild : firstChild;

    for (int i = 0; i < runCount; ++i) {
      double actualSizeDelta;
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;

      actualSizeDelta = actualSize - runMainAxisExtent;
      _overflow = math.max(0.0, -actualSizeDelta);
      final double remainingSpace = math.max(0.0, actualSizeDelta);
      double leadingSpace;
      double betweenSpace;

      // flipMainAxis is used to decide whether to lay out left-to-right/top-to-bottom (false), or
      // right-to-left/bottom-to-top (true). The _startIsTopLeft will return null if there's only
      // one child and the relevant direction is null, in which case we arbitrarily decide not to
      // flip, but that doesn't have any detectable effect.
      final bool flipMainAxis = !(_startIsTopLeft(flexDirection) ?? true);
      switch (justifyContent) {
        case JustifyContent.flexStart:
        case JustifyContent.start:
          leadingSpace = 0.0;
          betweenSpace = 0.0;
          break;
        case JustifyContent.flexEnd:
        case JustifyContent.end:
          leadingSpace = remainingSpace;
          betweenSpace = 0.0;
          break;
        case JustifyContent.center:
          leadingSpace = remainingSpace / 2.0;
          betweenSpace = 0.0;
          break;
        case JustifyContent.spaceBetween:
          leadingSpace = 0.0;
          betweenSpace = totalChildren > 1 ? remainingSpace / (totalChildren - 1) : 0.0;
          break;
        case JustifyContent.spaceAround:
          betweenSpace = totalChildren > 0 ? remainingSpace / totalChildren : 0.0;
          leadingSpace = betweenSpace / 2.0;
          break;
        default:
      }

      // Position elements
      double childMainPosition = flipMainAxis ? actualSize - leadingSpace : leadingSpace;
      while (child != null) {
        final RenderFlexParentData childParentData = child.parentData;
        // Exclude positioned placeholder renderObject when layout non placeholder object
        // and positioned renderObject
        if (placeholderChild == null &&
          (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
          child = childParentData.nextSibling;
          continue;
        }
        if (childParentData.runIndex != i) break;

        double childCrossPosition;

        AlignSelf alignSelf = childParentData.alignSelf;
        if (alignSelf == AlignSelf.auto) {
          switch (alignItems) {
            case AlignItems.flexStart:
            case AlignItems.start:
            case AlignItems.flexEnd:
            case AlignItems.end:
              childCrossPosition = _startIsTopLeft(flipDirection(flexDirection)) ==
                (alignItems == AlignItems.flexStart || alignItems == AlignItems.start)
                ? 0.0
                : crossSize - _getCrossSize(child);
              break;
            case AlignItems.center:
              childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
              break;
            case AlignItems.stretch:
              childCrossPosition = 0.0;
              break;
            default:
              break;
          }
        } else {
          switch (alignSelf) {
            case AlignSelf.flexStart:
            case AlignSelf.start:
            case AlignSelf.flexEnd:
            case AlignSelf.end:
              childCrossPosition = _startIsTopLeft(flipDirection(flexDirection)) ==
                (alignSelf == AlignSelf.flexStart || alignSelf == AlignSelf.start)
                ? 0.0
                : crossSize - _getCrossSize(child);
              break;
            case AlignSelf.center:
              childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
              break;
            case AlignSelf.stretch:
              childCrossPosition = 0.0;
              break;
            default:
              break;
          }
        }

        if (flipMainAxis) childMainPosition -= _getMainSize(child);

        double crossOffset;
        if (flexWrap == FlexWrap.wrapReverse) {
          crossOffset = constraintHeight - (childCrossPosition + crossAxisOffset + _getCrossSize(child));
        } else {
          crossOffset = childCrossPosition + crossAxisOffset;
        }

        Offset relativeOffset = _getOffset(childMainPosition, crossOffset);

        CSSStyleDeclaration childStyle;
        if (child is RenderTextBox) {
          childStyle = getEventTargetByTargetId<Element>(targetId)?.style;
        } else if (child is RenderElementBoundary) {
          int childNodeId = child.targetId;
          childStyle = getEventTargetByTargetId<Element>(childNodeId)?.style;
        }

        /// Apply position relative offset change
        applyRelativeOffset(relativeOffset, child, childStyle);

        if (flipMainAxis) {
          childMainPosition -= betweenSpace;
        } else {
          childMainPosition += _getMainSize(child) + betweenSpace;
        }


        // Only layout placeholder renderObject child
        child = placeholderChild == null ? childParentData.nextSibling : null;
      }

      crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }

  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    bool isVerticalDirection = isVerticalFlexDirection(_flexDirection);
    if (isVerticalDirection) {
      return Offset(crossAxisOffset, mainAxisOffset);
    } else {
      return Offset(mainAxisOffset, crossAxisOffset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    List<RenderObject> children = getChildrenAsList();
    children.sort((RenderObject prev, RenderObject next) {
      RenderFlexParentData prevParentData = prev.parentData;
      RenderFlexParentData nextParentData = next.parentData;
      // Place positioned element after non positioned element
      if (prevParentData.position == CSSPositionType.static && nextParentData.position != CSSPositionType.static) {
        return -1;
      }
      if (prevParentData.position != CSSPositionType.static && nextParentData.position == CSSPositionType.static) {
        return 1;
      }
      // z-index applies to flex-item ignoring position property
      int prevZIndex = prevParentData.zIndex ?? 0;
      int nextZIndex = nextParentData.zIndex ?? 0;
      return prevZIndex - nextZIndex;
    });

    for (var child in children) {
      // Don't paint placeholder of positioned element
      if (child is! RenderPositionHolder) {
        final RenderFlexParentData childParentData = child.parentData;
        context.paintChild(child, childParentData.offset + offset);
        child = childParentData.nextSibling;
      }
    }
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) => _hasOverflow ? Offset.zero & size : null;

  @override
  String toStringShort() {
    String header = super.toStringShort();
    if (_overflow is double && _hasOverflow) header += ' OVERFLOWING';
    return header;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FlexDirection>('flexDirection', flexDirection));
    properties.add(DiagnosticsProperty<JustifyContent>('justifyContent', justifyContent));
    properties.add(DiagnosticsProperty<AlignItems>('alignItems', alignItems));
    properties.add(DiagnosticsProperty<FlexWrap>('flexWrap', flexWrap));
  }

  RenderFlexParentData getPositionParentDataFromStyle(CSSStyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();
    CSSPositionType positionType = resolvePositionFromStyle(style);
    parentData.position = positionType;

    if (style.contains('top')) {
      parentData.top = CSSLength.toDisplayPortValue(style['top']);
    }
    if (style.contains('left')) {
      parentData.left = CSSLength.toDisplayPortValue(style['left']);
    }
    if (style.contains('bottom')) {
      parentData.bottom = CSSLength.toDisplayPortValue(style['bottom']);
    }
    if (style.contains('right')) {
      parentData.right = CSSLength.toDisplayPortValue(style['right']);
    }
    parentData.width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
    parentData.height = CSSLength.toDisplayPortValue(style['height']) ?? 0;
    parentData.zIndex = CSSLength.toInt(style['zIndex']);

    parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;

    return parentData;
  }
}

class RenderFlexItem extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RenderFlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RenderFlexParentData>,
        DebugOverflowIndicatorMixin {
  RenderFlexItem({RenderBox child}) {
    add(child);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderFlexParentData) {
      RenderFlexParentData flexParentData = RenderFlexParentData();
      child.parentData = flexParentData;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void performLayout() {
    RenderBox child = firstChild;
    if (child != null) {
      BoxConstraints innerConstraint = constraints;
      child.layout(innerConstraint, parentUsesSize: true);
      size = child.size;
    } else {
      size = Size.zero;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
