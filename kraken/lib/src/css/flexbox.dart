/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Flexible Box Layout: https://drafts.csswg.org/css-flexbox-1/

mixin CSSFlexboxMixin {
  void decorateRenderFlex(RenderFlexLayout renderObject, CSSStyleDeclaration style) {
    if (style != null) {
      Axis axis;
      TextDirection textDirection;
      VerticalDirection verticalDirection;
      String direction = style[FLEX_DIRECTION];
      switch (direction) {
        case 'row':
          axis = Axis.horizontal;
          textDirection = TextDirection.ltr;
          verticalDirection = VerticalDirection.down;
          break;
        case 'row-reverse':
          axis = Axis.horizontal;
          verticalDirection = VerticalDirection.down;
          textDirection = TextDirection.rtl;
          break;
        case 'column':
          axis = Axis.vertical;
          textDirection = TextDirection.ltr;
          verticalDirection = VerticalDirection.down;
          break;
        case 'column-reverse':
          axis = Axis.vertical;
          verticalDirection = VerticalDirection.up;
          textDirection = TextDirection.ltr;
          break;
        default:
          axis = Axis.horizontal;
          textDirection = TextDirection.ltr;
          verticalDirection = VerticalDirection.down;
          break;
      }

      renderObject.verticalDirection = verticalDirection;
      renderObject.direction = axis;
      renderObject.textDirection = textDirection;
      renderObject.mainAxisAlignment = _getJustifyContent(style, axis);
      renderObject.crossAxisAlignment = _getAlignItems(style, axis);
    }
  }

  MainAxisAlignment _getJustifyContent(CSSStyleDeclaration style, Axis axis) {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;

    if (style.contains(TEXT_ALIGN) && axis == Axis.horizontal) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          mainAxisAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          mainAxisAlignment = MainAxisAlignment.center;
          break;
      }
    }

    if (style.contains(JUSTIFY_CONTENT)) {
      String justifyContent = style[JUSTIFY_CONTENT];
      switch (justifyContent) {
        case 'flex-end':
          mainAxisAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          mainAxisAlignment = MainAxisAlignment.center;
          break;
        case 'space-between':
          mainAxisAlignment = MainAxisAlignment.spaceBetween;
          break;
        case 'space-around':
          mainAxisAlignment = MainAxisAlignment.spaceAround;
          break;
      }
    }
    return mainAxisAlignment;
  }

  CrossAxisAlignment _getAlignItems(CSSStyleDeclaration style, Axis axis) {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch;
    if (style.contains(TEXT_ALIGN) && axis == Axis.vertical) {
      String textAlign = style[TEXT_ALIGN];
      switch (textAlign) {
        case 'right':
          crossAxisAlignment = CrossAxisAlignment.end;
          break;
        case 'center':
          crossAxisAlignment = CrossAxisAlignment.center;
          break;
      }
    }
    if (style.contains(ALIGN_ITEMS)) {
      String alignItems = style[ALIGN_ITEMS];
      switch (alignItems) {
        case 'flex-start':
          crossAxisAlignment = CrossAxisAlignment.start;
          break;
        case 'center':
          crossAxisAlignment = CrossAxisAlignment.center;
          break;
        case 'baseline':
          crossAxisAlignment = CrossAxisAlignment.baseline;
          break;
        case 'flex-end':
          crossAxisAlignment = CrossAxisAlignment.end;
          break;
        default:
          crossAxisAlignment = CrossAxisAlignment.stretch;
      }
    }
    return crossAxisAlignment;
  }
}

class CSSFlexItem {
  static const String GROW = 'flexGrow';
  static const String SHRINK = 'flexShrink';
  static const String BASIS = 'flexBasis';
  static const String ALIGN_ITEMS = 'alignItems';

  static RenderFlexParentData getParentData(CSSStyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();

    String grow = style[GROW];
    parentData.flexGrow = CSSStyleDeclaration.isNullOrEmptyValue(grow)
        ? 0 // Grow default to 0.
        : CSSLength.toInt(grow);

    String shrink = style[SHRINK];
    parentData.flexShrink = CSSStyleDeclaration.isNullOrEmptyValue(shrink)
        ? 1 // Shrink default to 1.
        : CSSLength.toInt(shrink);

    String basis = style[BASIS];
    parentData.flexBasis = CSSStyleDeclaration.isNullOrEmptyValue(basis)
        ? 'auto' // flexBasis default to auto.
        : basis;

    return parentData;
  }
}
