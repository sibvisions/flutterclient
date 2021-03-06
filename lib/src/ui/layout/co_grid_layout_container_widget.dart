import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/layout/widgets/co_grid_layout.dart';
import 'package:flutterclient/src/ui/layout/widgets/co_grid_layout_constraint.dart';

import '../component/component_widget.dart';
import '../container/co_container_widget.dart';
import '../widgets/builder/custom_stateful_builder.dart';
import 'co_layout.dart';

class CoGridLayoutContainerWidget extends StatelessWidget
    with CoLayout<String> {
  // The number of rows.
  int rows = 1;

  // The number of columns.
  int columns = 1;

  /// stores all constraints. */
  Map<ComponentWidget, String> _constraintMap = <ComponentWidget, String>{};

  //List<CoGridLayoutConstraintData> children = <CoGridLayoutConstraintData>[];

  CoGridLayoutContainerWidget(Key key) : super(key: key);

  CoGridLayoutContainerWidget.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData) {
    updateLayoutString(layoutString);
    this.container = pContainer;
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
    List<String> parameter = layoutString.split(",");

    rows = int.parse(parameter[7]);
    columns = int.parse(parameter[8]);
  }

  @override
  void addLayoutComponent(ComponentWidget pComponent, String? pConstraint) {
    if (pConstraint == null || pConstraint.isEmpty) {
      throw new ArgumentError(
          "Constraint " + pConstraint.toString() + " is not allowed!");
    } else {
      if (setState != null)
        setState!(
            () => _constraintMap.putIfAbsent(pComponent, () => pConstraint));
      else
        _constraintMap.putIfAbsent(pComponent, () => pConstraint);
    }
  }

  @override
  String? getConstraints(ComponentWidget comp) {
    return _constraintMap[comp];
  }

  @override
  void removeLayoutComponent(ComponentWidget pComponent) {
    if (this.setState != null) {
      setState!(() {
        _constraintMap.removeWhere((c, s) =>
            c.componentModel.componentId.toString() ==
            pComponent.componentModel.componentId.toString());
      });
    } else {
      _constraintMap.removeWhere((c, s) =>
          c.componentModel.componentId.toString() ==
          pComponent.componentModel.componentId.toString());
    }
  }

  CoGridLayoutConstraints? getConstraintsFromString(String pConstraints) {
    List<String> constr = pConstraints.split(";");

    if (constr.length == 5) {
      int? gridX = int.tryParse(constr[0]);
      int? gridY = int.tryParse(constr[1]);
      int? gridHeight = int.tryParse(constr[2]);
      int? gridWidth = int.tryParse(constr[3]);
      EdgeInsets ins = EdgeInsets.zero;

      if (constr[4].length > 0) {
        List<String> insData = constr[4].split(",");

        if (insData.length == 4) {
          double? left = int.tryParse(insData[0])?.toDouble();
          double? top = int.tryParse(insData[1])?.toDouble();
          double? right = int.tryParse(insData[2])?.toDouble();
          double? bottom = int.tryParse(insData[3])?.toDouble();

          ins =
              EdgeInsets.fromLTRB(left ?? 0, top ?? 0, right ?? 0, bottom ?? 0);
        }
      }

      if (gridX != null &&
          gridY != null &&
          gridHeight != null &&
          gridWidth != null) {
        return CoGridLayoutConstraints.fromGridPositionAndSizeAndInsets(
            gridX, gridY, gridHeight, gridWidth, ins);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomStatefulBuilder(
      dispose: () => super.setState,
      builder: (context, setState) {
        super.setState = setState;

        List<CoGridLayoutConstraintData> children =
            <CoGridLayoutConstraintData>[];
        this._constraintMap.forEach((k, v) {
          if (k.componentModel.isVisible) {
            CoGridLayoutConstraints? constraint =
                this.getConstraintsFromString(v);
            Key? key = this.getKeyByComponentId(k.componentModel.componentId);

            if (key == null) {
              key = this.createKey(k.componentModel.componentId);
            }

            if (constraint != null) {
              constraint.comp = k;
              children.add(new CoGridLayoutConstraintData(
                key: key,
                child: k,
                id: constraint,
              ));
            }
          }
        });

        return Container(
            child: CoGridLayoutWidget(
          key: key,
          container: container!,
          children: children,
          rows: rows,
          columns: columns,
          margins: margins,
          horizontalGap: horizontalGap,
          verticalGap: verticalGap,
        ));
      },
    );
  }
}
