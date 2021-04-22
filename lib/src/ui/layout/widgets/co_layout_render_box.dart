import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterclient/flutterclient.dart';

class CoLayoutRenderBox extends RenderBox {
  // only used in parent layouts
  Size? preferredLayoutSize;
  Size? minimumLayoutSize;
  Size? maximumLayoutSize;
  bool valid = false;
  String debugInfo = "";

  Size? getChildLayoutPreferredSize(ComponentModel model) {
    if (model is ContainerComponentModel) return model.preferredLayoutSize;

    return null;
  }

  Size? getChildLayoutMinimumSize(ComponentModel model) {
    if (model is ContainerComponentModel) return model.minimumLayoutSize;

    return null;
  }

  Size? getChildLayoutMaximumSize(ComponentModel model) {
    if (model is ContainerComponentModel) return model.maximumLayoutSize;

    return null;
  }
  // Size? getChildLayoutPreferredSize(RenderBox renderBox) {
  //   if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
  //     CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

  //     log("$debugInfo returns preferredLayoutSize ${childLayout.preferredLayoutSize}");
  //     return childLayout.preferredLayoutSize;
  //   }

  //   return null;
  // }

  // Size? getChildLayoutMinimumSize(RenderBox renderBox) {
  //   if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
  //     CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

  //     return childLayout.minimumLayoutSize;
  //   }

  //   return null;
  // }

  // Size? getChildLayoutMaximumSize(RenderBox renderBox) {
  //   if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
  //     CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

  //     return childLayout.maximumLayoutSize;
  //   }

  //   return null;
  // }

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
