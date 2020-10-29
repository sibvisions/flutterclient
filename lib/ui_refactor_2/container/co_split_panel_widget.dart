import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/widgets/split_view.dart';
import '../../utils/globals.dart' as globals;
import '../component/component_widget.dart';
import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';
import 'container_component_model.dart';

class CoSplitPanelWidget extends CoContainerWidget {
  CoSplitPanelWidget({ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoSplitPanelWidgetState();
}

class CoSplitPanelWidgetState extends CoContainerWidgetState {
  final splitViewKey = GlobalKey();

  ScrollController scrollControllerView1 =
      ScrollController(keepScrollOffset: true);
  ScrollController scrollControllerView2 =
      ScrollController(keepScrollOffset: true);

  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  /// Constant for relative anchors.
  static const RELATIVE = 2;

  int dividerPosition;
  int dividerAlignment;

  double currentSplitviewWeight;

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    dividerPosition =
        changedComponent.getProperty<int>(ComponentProperty.DIVIDER_POSITION);
    dividerAlignment = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_ALIGNMENT, HORIZONTAL);
  }

  void _calculateDividerPosition(
      BoxConstraints constraints, SplitViewMode splitViewMode) {
    if (this.currentSplitviewWeight == null) {
      if (this.dividerPosition != null &&
          this.dividerPosition >= 0 &&
          constraints.maxWidth != null &&
          splitViewMode == SplitViewMode.Horizontal) {
        this.currentSplitviewWeight =
            this.dividerPosition / constraints.maxWidth;
      } else if (this.dividerPosition != null &&
          this.dividerPosition >= 0 &&
          constraints.maxHeight != null &&
          (splitViewMode == SplitViewMode.Vertical)) {
        this.currentSplitviewWeight =
            this.dividerPosition / constraints.maxHeight;
      } else {
        this.currentSplitviewWeight = 0.5;
      }
    }
  }

  SplitViewMode get defaultSplitViewMode {
    return (dividerAlignment == HORIZONTAL || dividerAlignment == RELATIVE)
        ? SplitViewMode.Horizontal
        : SplitViewMode.Vertical;
  }

  SplitViewMode get splitViewMode {
    if (kIsWeb &&
        (globals.layoutMode == 'Full' || globals.layoutMode == 'Small')) {
      return defaultSplitViewMode;
    }

    if (defaultSplitViewMode == SplitViewMode.Horizontal) {
      if (MediaQuery.of(context).size.width >= 667) return defaultSplitViewMode;
    } else {
      if (MediaQuery.of(context).size.height >= 667)
        return defaultSplitViewMode;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    ComponentWidget firstComponent =
        getComponentWithContraint("FIRST_COMPONENT");
    ComponentWidget secondComponent =
        getComponentWithContraint("SECOND_COMPONENT");
    List<Widget> widgets = new List<Widget>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (firstComponent != null) {
        widgets.add(SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CoScrollPanelLayout(
              parentConstraints: constraints,
              children: [
                CoScrollPanelLayoutId(
                    parentConstraints: constraints, child: firstComponent)
              ],
            )));
      } else {
        widgets.add(Container());
      }

      if (secondComponent != null) {
        widgets.add(SingleChildScrollView(
            //scrollDirection: Axis.horizontal,
            child: CoScrollPanelLayout(
          parentConstraints: constraints,
          children: [
            CoScrollPanelLayoutId(
                parentConstraints: constraints, child: secondComponent)
          ],
        )));
      } else {
        widgets.add(Container());
      }

      if (this.splitViewMode != null) {
        _calculateDividerPosition(constraints, this.splitViewMode);

        return SplitView(
          key: splitViewKey,
          initialWeight: currentSplitviewWeight,
          gripColor: Colors.grey.withOpacity(0.3),
          handleColor: Colors.grey[800].withOpacity(0.5),
          view1: widgets[0],
          view2: widgets[1],
          viewMode: this.splitViewMode,
          onWeightChanged: (value) {
            currentSplitviewWeight = value;
          },
          scrollControllerView1: scrollControllerView1,
          scrollControllerView2: scrollControllerView2,
        );
      } else {
        return SplitView(
          key: splitViewKey,
          initialWeight: 0.5,
          showHandle: false,
          view1: widgets[0],
          view2: widgets[1],
          viewMode: SplitViewMode.Vertical,
          scrollControllerView1: scrollControllerView1,
          scrollControllerView2: scrollControllerView2,
        );
      }
    });
  }
}