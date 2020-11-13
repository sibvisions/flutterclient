import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/request.dart';
import '../../models/api/response/response_data.dart';
import '../component/co_action_component_widget.dart';
import '../component/component_model.dart';
import '../component/component_widget.dart';
import '../component/popup_menu/co_menu_item_widget.dart';
import '../component/popup_menu/co_popup_menu_button_widget.dart';
import '../component/popup_menu/co_popup_menu_widget.dart';
import '../component/popup_menu/popup_button_component_model.dart';
import '../component/popup_menu/popup_component_model.dart';
import '../container/co_container_widget.dart';
import '../container/container_component_model.dart';
import '../editor/celleditor/co_referenced_cell_editor_widget.dart';
import '../editor/co_editor_widget.dart';
import 'component_model_manager.dart';
import 'i_component_creator.dart';
import 'so_data_screen.dart';

enum CoState {
  /// Component is added to the widget tree
  Added,

  /// Component is not added to the widget tree
  Free,

  /// Component was destroyed
  Destroyed
}

class ComponentScreenWidget extends StatefulWidget {
  final IComponentCreator componentCreator;
  final Response response;
  final bool closeCurrentScreen;

  const ComponentScreenWidget(
      {Key key, this.componentCreator, this.response, this.closeCurrentScreen})
      : super(key: key);

  static ComponentScreenWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<ComponentScreenWidgetState>();

  @override
  ComponentScreenWidgetState createState() => ComponentScreenWidgetState();
}

class ComponentScreenWidgetState extends State<ComponentScreenWidget>
    with SoDataScreen {
  Map<String, ComponentWidget> components = <String, ComponentWidget>{};
  Map<String, ComponentWidget> additionalComponents =
      <String, ComponentWidget>{};

  ComponentModelManager _componentModelManager = ComponentModelManager();

  bool debug = true;
  ComponentWidget headerComponent;
  ComponentWidget footerComponent;

  ComponentWidget rootComponent;

  @override
  Widget build(BuildContext context) {
    if (widget.closeCurrentScreen != null && widget.closeCurrentScreen) {
      components = <String, ComponentWidget>{};
    }

    this.context = context;

    ResponseData responseData = widget.response.responseData;
    Request request = widget.response.request;

    if (request != null && responseData != null)
      this.updateData(request, responseData);
    if (responseData.screenGeneric != null) {
      this.updateComponents(
          responseData.screenGeneric.changedComponents);
      rootComponent = this.getRootComponent();
    }

    if (rootComponent != null) {
      return rootComponent;
    }
    return Container();
  }

  void updateComponents(List<ChangedComponent> changedComponents) {
    if (debug) print("ComponentScreen updateComponents:");
    changedComponents?.forEach((changedComponent) {
      String parentComponentId =
          changedComponent.getProperty<String>(ComponentProperty.PARENT, null);
      if (changedComponent.additional ||
          (parentComponentId != null &&
              additionalComponents.containsKey(parentComponentId)) ||
          additionalComponents.containsKey(changedComponent.id))
        _updateComponent(changedComponent, additionalComponents);
      else
        _updateComponent(changedComponent, components);
    });
  }

  void _updateComponent(ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    if (container.containsKey(changedComponent.id)) {
      ComponentWidget component = container[changedComponent.id];

      if (changedComponent.destroy) {
        if (debug) print("Destroy component (id:" + changedComponent.id + ")");
        _destroyComponent(component, container);
      } else if (changedComponent.remove) {
        if (debug) print("Remove component (id:" + changedComponent.id + ")");
        _removeComponent(component, container);
      } else {
        _moveComponent(component, changedComponent, container);

        if (component.componentModel.coState != CoState.Added) {
          _addComponent(changedComponent, container);
        }

        component.componentModel.toUpdateComponents.add(ToUpdateComponent(
            changedComponent: changedComponent,
            componentId: changedComponent.id));
        component.componentModel.update();

        if (component.componentModel?.parentComponentId != null) {
          ComponentWidget parentComponent =
              container[component.componentModel.parentComponentId];
          if (parentComponent != null && parentComponent is CoContainerWidget) {
            (parentComponent.componentModel as ContainerComponentModel)
                .toUpdateComponentProperties
                .add(ToUpdateComponent(
                    changedComponent: changedComponent,
                    componentId: component.componentModel.componentId));
            (parentComponent.componentModel as ContainerComponentModel)
                .update();
          }
        }
      }
    } else {
      if (!changedComponent.destroy && !changedComponent.remove) {
        if (debug) {
          String parent =
              changedComponent.getProperty<String>(ComponentProperty.PARENT);
          print("Add component (id:" +
              changedComponent.id +
              ",parent:" +
              (parent != null ? parent : "") +
              ", className: " +
              (changedComponent.className != null
                  ? changedComponent.className
                  : "") +
              ")");
        }
        this._addComponent(changedComponent, container);
      } else {
        print("Cannot remove or destroy component with id " +
            changedComponent.id +
            ", because its not in the components list.");
      }
    }
  }

  void _addComponent(
      ChangedComponent component, Map<String, ComponentWidget> container) {
    ComponentWidget componentClass;

    if (!container.containsKey(component.id)) {
      ComponentModel componentModel =
          _componentModelManager.addComponentModel(component.id, component);

      componentClass =
          widget?.componentCreator?.createComponent(componentModel);

      if (componentClass is CoEditorWidget) {
        if (componentClass.cellEditor is CoReferencedCellEditorWidget) {
          (componentClass.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .data = this.getComponentData((componentClass.cellEditor
                  as CoReferencedCellEditorWidget)
              .changedCellEditor
              .linkReference
              .dataProvider);
        }
      } else if (componentClass is CoActionComponentWidget) {
        componentClass?.componentModel?.onButtonPressed = this.onButtonPressed;
      } else if (component.additional && componentClass is CoPopupMenuWidget) {
        if (components
                .containsKey(componentClass.componentModel.parentComponentId) &&
            components[componentClass.componentModel.parentComponentId]
                is CoPopupMenuButtonWidget) {
          CoPopupMenuButtonWidget btn =
              components[componentClass.componentModel.parentComponentId];
          (btn.componentModel as PopupButtonComponentModel).menu =
              componentClass;
        }
      } else if (componentClass is CoMenuItemWidget) {
        if (container
                .containsKey(componentClass.componentModel.parentComponentId) &&
            container[componentClass.componentModel.parentComponentId]
                is CoPopupMenuWidget) {
          CoPopupMenuWidget menu =
              container[componentClass.componentModel.parentComponentId];
          (menu.componentModel as PopupComponentModel)
              .updateMenuItem(componentClass);
        }
      }
    } else {
      componentClass = container[component.id];

      if (componentClass is CoEditorWidget) {
        if (componentClass.cellEditor is CoReferencedCellEditorWidget) {
          (componentClass.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .data = this.getComponentData((componentClass.cellEditor
                  as CoReferencedCellEditorWidget)
              .changedCellEditor
              .linkReference
              .dataProvider);
        }
      }
    }

    if (componentClass != null) {
      componentClass?.componentModel?.coState = CoState.Added;
      container.putIfAbsent(component.id, () => componentClass);
      _addToParent(componentClass, container);
    }
  }

  void _addToParent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    if (component.componentModel.parentComponentId?.isNotEmpty ?? false) {
      ComponentWidget parentComponent =
          container[component.componentModel.parentComponentId];
      if (parentComponent != null && parentComponent is CoContainerWidget) {
        if (parentComponent.componentModel.componentState != null) {
          (parentComponent.componentModel.componentState
                  as CoContainerWidgetState)
              .addWithConstraints(
                  component, component.componentModel.constraints);
        } else {
          (parentComponent.componentModel as ContainerComponentModel)
              .toUpdateComponentProperties
              .add(ToUpdateComponent(
                  changedComponent: component.componentModel.changedComponent,
                  componentId: component.componentModel.componentId));

          (parentComponent.componentModel as ContainerComponentModel).update();
        }
      }
    }
  }

  void _removeComponent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    _removeFromParent(component);
  }

  void _removeFromParent(ComponentWidget component) {
    if (component.componentModel.parentComponentId != null &&
        component.componentModel.parentComponentId.isNotEmpty) {
      ComponentWidget parentComponent =
          components[component.componentModel.parentComponentId];
      if (parentComponent != null && parentComponent is CoContainerWidget) {
        (parentComponent.componentModel.componentState
                as CoContainerWidgetState)
            ?.removeWithComponent(component);
      }
    }
  }

  void _destroyComponent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    _removeComponent(component, container);
    container.remove(component.componentModel.componentId);
    component.componentModel.componentState.state = CoState.Destroyed;
  }

  void _moveComponent(ComponentWidget component, ChangedComponent newComponent,
      Map<String, ComponentWidget> container) {
    String parent = newComponent.getProperty(ComponentProperty.PARENT);
    String constraints =
        newComponent.getProperty(ComponentProperty.CONSTRAINTS);
    String layout = newComponent.getProperty(ComponentProperty.LAYOUT);
    String layoutData = newComponent.getProperty(ComponentProperty.LAYOUT_DATA);

    if (newComponent.hasProperty(ComponentProperty.LAYOUT_DATA) &&
        layoutData != null &&
        layoutData.isNotEmpty) {
      if (component is CoContainerWidget) {
        (component.componentModel as ContainerComponentModel)
            .toUpdateLayout
            .add(layoutData);

        (component.componentModel as ContainerComponentModel).update();
      }
    }

    if (newComponent.hasProperty(ComponentProperty.LAYOUT) &&
        layout != null &&
        layout.isNotEmpty) {
      if (component is CoContainerWidget) {
        (component.componentModel as ContainerComponentModel)
            .toUpdateLayout
            .add(layoutData);

        (component.componentModel as ContainerComponentModel).update();
      }
    }

    if (newComponent.hasProperty(ComponentProperty.PARENT) &&
        component.componentModel.parentComponentId != parent) {
      if (debug)
        print("Move component (id:" +
            newComponent.id +
            ",oldParent:" +
            (component.componentModel.parentComponentId != null
                ? component.componentModel.parentComponentId
                : "") +
            ",newParent:" +
            (parent != null ? parent : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.componentModel.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (parent != null) {
        component.componentModel.parentComponentId = parent;
        _addToParent(component, container);
      }
    } else if (newComponent.hasProperty(ComponentProperty.CONSTRAINTS) &&
        component.componentModel.constraints != constraints) {
      if (debug)
        print("Update constraints (id:" +
            newComponent.id +
            ",oldConstraints:" +
            (component.componentModel.constraints != null
                ? component.componentModel.constraints
                : "") +
            ",newConstraints:" +
            (constraints != null ? constraints : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.componentModel.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (constraints != null) {
        component.componentModel.constraints = constraints;

        component.componentModel.update();
        _addToParent(component, container);
      }
    }
  }

  ComponentWidget getRootComponent() {
    ComponentWidget rootComponent = this.components.values.firstWhere(
        (element) =>
            element.componentModel.parentComponentId == null &&
            element.componentModel.coState == CoState.Added,
        orElse: () => null);

    /*
    if (headerComponent != null || footerComponent != null) {
      ComponentWidget headerFooterPanel =
          CoPanelWidget(componentModel: ComponentModel('headerFooterPanel'));
      (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
              .layout =
          CoBorderLayout.fromLayoutString(
              headerFooterPanel, 'BorderLayout,0,0,0,0,0,0,', '');
      if (headerComponent != null) {
        (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
            .addWithConstraints(headerComponent, 'North');
      }
      (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
          .addWithConstraints(rootComponent, 'Center');
      if (footerComponent != null) {
        (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
            .addWithConstraints(footerComponent, 'South');
      }

      return headerFooterPanel;
    }
    */

    return rootComponent;
  }

  setHeader(ComponentWidget headerComponent) {
    this.headerComponent = headerComponent;
  }

  setFooter(ComponentWidget footerComponent) {
    this.footerComponent = footerComponent;
  }

  replaceComponent(ComponentWidget compToReplace, ComponentWidget newComp) {
    if (compToReplace != null) {
      newComp.componentModel.componentState.parentComponentId =
          compToReplace.componentModel.componentState.parentComponentId;
      newComp.componentModel.componentState.constraints =
          compToReplace.componentModel.componentState.constraints;
      newComp.componentModel.componentState.minimumSize =
          compToReplace.componentModel.componentState.minimumSize;
      newComp.componentModel.componentState.maximumSize =
          compToReplace.componentModel.componentState.maximumSize;
      newComp.componentModel.componentState.preferredSize =
          compToReplace.componentModel.componentState.preferredSize;
      _removeFromParent(compToReplace);
      _addToParent(newComp, components);
    }
  }

  ComponentWidget getComponentFromName(String componentName) {
    return this.components.values.firstWhere(
        (element) =>
            element?.componentModel?.componentState?.name == componentName &&
            element?.componentModel?.coState == CoState.Added,
        orElse: () => null);
  }

  void debugPrintComponent(ComponentWidget component, int level) {
    if (component != null) {
      String debugString = " |" * level;
      Size size = _getSizes(component.key);
      String keyString = component.key.toString();
      keyString =
          keyString.substring(keyString.indexOf(" ") + 1, keyString.length - 1);

      debugString += " id: " +
          keyString +
          ", Name: " +
          component.componentModel.componentState.name.toString() +
          ", parent: " +
          (component.componentModel.componentState.parentComponentId != null
              ? component.componentModel.componentState.parentComponentId
              : "") +
          ", className: " +
          component.runtimeType.toString() +
          ", constraints: " +
          (component.componentModel.componentState.constraints != null
              ? component.componentModel.componentState.constraints
              : "") +
          ", size:" +
          (size != null ? size.toString() : "nosize");

      if (component.componentModel.componentState is CoEditorWidgetState) {
        debugString += ", dataProvider: " +
            (component.componentModel.componentState as CoEditorWidgetState)
                .dataProvider;
      }

      if (component is CoContainerWidget) {
        debugString += ", layout: " +
            ((component.componentModel.componentState as CoContainerWidgetState).layout != null &&
                    (component.componentModel.componentState as CoContainerWidgetState)
                            .layout
                            .rawLayoutString !=
                        null
                ? (component.componentModel.componentState as CoContainerWidgetState)
                    .layout
                    .rawLayoutString
                : "") +
            ", layoutData: " +
            ((component.componentModel.componentState as CoContainerWidgetState).layout !=
                        null &&
                    (component.componentModel.componentState as CoContainerWidgetState)
                            .layout
                            .rawLayoutData !=
                        null
                ? (component.componentModel.componentState as CoContainerWidgetState)
                    .layout
                    .rawLayoutData
                : "") +
            ", childCount: " +
            ((component.componentModel.componentState as CoContainerWidgetState).components != null
                ? (component.componentModel.componentState as CoContainerWidgetState)
                    .components
                    .length
                    .toString()
                : "0");
        print(debugString);

        if ((component.componentModel.componentState as CoContainerWidgetState)
                .components !=
            null) {
          (component.componentModel.componentState as CoContainerWidgetState)
              .components
              .forEach((c) {
            debugPrintComponent(c, (level + 1));
          });
        }
      } else {
        print(debugString);
      }
    }
  }

  void debugPrintCurrentWidgetTree() {
    if (debug) {
      ComponentWidget component = getRootComponent();
      print("--------------------");
      print("Current widget tree:");
      print("--------------------");
      debugPrintComponent(component, 0);
      print("--------------------");
    }
  }

  Size _getSizes(GlobalKey key) {
    if (key != null && key.currentContext != null) {
      final RenderBox renderBox = key.currentContext.findRenderObject();
      if (renderBox != null && renderBox.hasSize) {
        return renderBox.size;
      }
    }

    return null;
  }

  List<ComponentWidget> getChildren(String componentId) {
    if (!this.components.containsKey(componentId)) {
      return null;
    }

    List<ComponentWidget> children = <ComponentWidget>[];

    this.components.forEach((key, value) {
      if (value.componentModel.parentComponentId == componentId &&
          value.componentModel.coState == CoState.Added) {
        children.add(value);
      }
    });

    return children;
  }
}