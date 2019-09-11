import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/main.dart';
import '../model/changed_component.dart';
import 'component/jvx_component.dart';
import 'container/jvx_container.dart';
import 'jvx_component_creater.dart';

class JVxScreen {
  String title = "OpenScreen";
  Key componentId;
  Map<String, JVxComponent> components = <String, JVxComponent>{};
  BuildContext context;
  Function buttonCallback;

  JVxScreen(this.componentId, List<ChangedComponent> changedComponents, this.context, this.buttonCallback) {

    for(var i = 0; i < changedComponents.length; i++){
      this.addComponent(changedComponents[i], context);
    }
  }

  JVxScreen.withoutArgs();

  updateComponents(List<ChangedComponent> changedComponentsJson) {

    changedComponentsJson?.forEach((changedComponent) {
        if (components.containsKey(changedComponent.id)) {
          JVxComponent component = components[changedComponent.id];

          if (changedComponent.destroy) {
            destroyComponent(component);
          } else if (changedComponent.remove) {
            removeComponent(component);
          } else if (changedComponent.parent.isNotEmpty && changedComponent.parent!=component.parentComponentId) {

          }

          component?.updateProperties(changedComponent.componentProperties);

          if (component?.parentComponentId != null) {
            JVxComponent parentComponent = components[component.parentComponentId];
            if (parentComponent!= null && parentComponent is JVxContainer) {
              parentComponent.updateComponentProperties(component.componentId, changedComponent.componentProperties);
            }
          }
        }
    });
  }

  void addComponent(ChangedComponent component, BuildContext context) {

      if (!components.containsKey(component.id)) {
        JVxComponent componentClass = JVxComponentCreator.create(component, context);

        if (componentClass!= null) {
          components.putIfAbsent(component.id, () => componentClass);

          if (component.parent?.isNotEmpty ?? false) {
            JVxComponent parentComponent = components[component.parent];
            if (parentComponent!= null && parentComponent is JVxContainer) {
              componentClass.parentComponentId = component.parent;
              String constraint = component.componentProperties.getProperty("constraints");
              parentComponent.addWithConstraints(componentClass, constraint);
            }
          }
        }
      }
  }


  void removeComponent(JVxComponent component) {

  }

  void destroyComponent(JVxComponent component) {

  }

  void moveComponent(JVxComponent component) {
    
  }

  JVxComponent getRootComponent() {
    return this.components.values.firstWhere((element) => element.parentComponentId==null);
  }

  Widget getWidget() {
    JVxComponent component = this.getRootComponent();

    if (component!= null) {
      return component.getWidget();
    } else {
      // ToDO
      return Container(
        alignment: Alignment.center,
        child: Text('Test'),
      );
    }
  }
}