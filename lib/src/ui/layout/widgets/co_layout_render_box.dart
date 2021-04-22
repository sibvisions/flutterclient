import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CoLayoutRenderBox extends RenderBox {
  // only used in parent layouts
  Size? _preferredLayoutSize;
  Size? minimumLayoutSize;
  Size? maximumLayoutSize;
  bool valid = false;
  String debugInfo = "";

  Size? get preferredLayoutSize {
    if (_preferredLayoutSize != null && _preferredLayoutSize!.height == 55)
      return null;
    //return Size(_preferredLayoutSize!.width, _preferredLayoutSize!.height);
    return _preferredLayoutSize;
  }

  set preferredLayoutSize(Size? value) {
    _preferredLayoutSize = value;
  }

  Size? getChildLayoutPreferredSize(RenderBox renderBox) {
    CoLayoutRenderBox? nextLayoutRenderBox = getNextLayoutRenderBox(renderBox);

    if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
      CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

      log("$debugInfo returns preferredLayoutSize ${childLayout.preferredLayoutSize}");
      return childLayout.preferredLayoutSize;
    }

    return null;
  }

  CoLayoutRenderBox? getNextLayoutRenderBox(RenderBox renderBox) {
    if (renderBox is RenderShiftedBox) {
      if (renderBox is CoLayoutRenderBox) return renderBox as CoLayoutRenderBox;
      if (renderBox.child != null)
        return getNextLayoutRenderBox(renderBox.child!);
    }

    return null;
  }

  Size? getChildLayoutMinimumSize(RenderBox renderBox) {
    if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
      CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

      return childLayout.minimumLayoutSize;
    }

    return null;
  }

  Size? getChildLayoutMaximumSize(RenderBox renderBox) {
    if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
      CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

      return childLayout.maximumLayoutSize;
    }

    return null;
  }

  Size layoutRenderBox(RenderBox renderBox, BoxConstraints constraints) {
    if (constraints.maxHeight == double.infinity &&
        constraints.maxWidth == double.infinity) {
      try {
        if (renderBox.hasSize) return renderBox.size;
        renderBox.layout(BoxConstraints.tightForFinite(), parentUsesSize: true);
        return renderBox.size;
      } catch (e) {
        BoxConstraints boxConstraints = BoxConstraints(
            minHeight: constraints.minHeight,
            minWidth: constraints.minWidth,
            maxHeight: double.maxFinite,
            maxWidth: constraints.maxWidth);

        renderBox.layout(normalizeConstraints(boxConstraints),
            parentUsesSize: true);
        Size size = renderBox.size;

        if (size != null) {
          boxConstraints = BoxConstraints(
              minHeight: constraints.minHeight,
              minWidth: constraints.minWidth,
              maxHeight: constraints.maxHeight,
              maxWidth: double.maxFinite);

          renderBox.layout(normalizeConstraints(boxConstraints),
              parentUsesSize: true);

          size = Size(size.width, renderBox.size.height);
        }
      }
    } else {
      renderBox.layout(normalizeConstraints(constraints), parentUsesSize: true);
      return renderBox.size;
    }

    return size;
  }

  BoxConstraints normalizeConstraints(BoxConstraints constraints) {
    //return constraints;
    double minWidth = constraints.minWidth < 0 ? 0 : constraints.minWidth;
    double maxWidth = constraints.maxWidth < 0 ? 0 : constraints.maxWidth;
    double minHeight = constraints.minHeight < 0 ? 0 : constraints.minHeight;
    double maxHeight = constraints.maxHeight < 0 ? 0 : constraints.maxHeight;

    if (minWidth > maxWidth) minWidth = maxWidth;
    if (minHeight > maxHeight) minHeight = maxHeight;

    return BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight);
  }
}
