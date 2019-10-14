import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/press_button_bloc.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/data/press_button.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'jvx_component.dart';

class JVxButton extends JVxComponent {
  String text = "";
  StreamSubscription<FetchProcess> apiStreamSubscription;
  PressButtonBloc pressButtonBloc = PressButtonBloc();

  JVxButton(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT);
  }

  void buttonPressed() {
<<<<<<< HEAD
    PressButton pressButton = PressButton(prefix0.Action(componentId: this.name,
        label: this.text));

    BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
=======
    pressButtonBloc.pressButtonController.add(
      PressButtonViewModel(clientId: globals.clientId, 
        action: prefix0.Action(componentId: this.name, 
        label: this.text))
    );
>>>>>>> 24c82427658660d58590b93f9088fa8e97dacb71
  }

  @override
  Widget getWidget() {
    return 
      SizedBox(
        child: RaisedButton(
          key: this.componentId, 
          onPressed: buttonPressed,
          color: UIData.ui_kit_color_2[400],
          elevation: 10,
          child: Text(text, 
            style: TextStyle(
              fontSize: style.fontSize,
              color: UIData.textColor
            )
          ),
          splashColor: this.background,
        ),
      );
  }
}