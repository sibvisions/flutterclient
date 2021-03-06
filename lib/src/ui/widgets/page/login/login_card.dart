import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../models/api/requests/login_request.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../../util/app/text_utils.dart';
import '../../../../util/translation/app_localizations.dart';
import 'gradient_button.dart';

class LoginCard extends StatefulWidget {
  final String lastUsername;
  final AppState appState;
  final ApiCubit cubit;

  const LoginCard(
      {Key? key,
      required this.lastUsername,
      required this.appState,
      required this.cubit})
      : super(key: key);

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  String loginUsername = '', loginPassword = '';

  late AnimationController controller;
  late Animation<double> animation;

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  String get title {
    if (widget.appState.applicationStyle?.loginStyle?.title != null)
      return widget.appState.applicationStyle!.loginStyle!.title!;
    else
      return widget.appState.serverConfig!.appName;
  }

  Widget _loginBuilder() => Form(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    onChanged: (username) => loginUsername = username,
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.green),
                        labelText:
                            AppLocalizations.of(context)!.text('Username:'),
                        labelStyle: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600)),
                  )),
              new SizedBox(
                height: 10.0,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _passwordController,
                    onChanged: (password) => loginPassword = password,
                    style: new TextStyle(fontSize: 14.0, color: Colors.black),
                    decoration: new InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.text('Password:'),
                        labelStyle: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600)),
                    obscureText: true,
                  )),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  if (!widget.appState.appConfig!.hideLoginCheckbox)
                    Checkbox(
                      value: rememberMe,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? val) {
                        setState(() {
                          rememberMe = val!;
                        });
                      },
                    ),
                  if (!widget.appState.appConfig!.hideLoginCheckbox)
                    TextButton(
                        onPressed: () {
                          setState(() {
                            rememberMe = !rememberMe;
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.text('Remember me?'),
                        )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                      child: GradientButton(
                          appState: widget.appState,
                          onPressed: () {
                            TextUtils.unfocusCurrentTextfield(context);
                            _login(context);
                          },
                          text: AppLocalizations.of(context)!.text('Login')))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 10),
                      child: new TextButton.icon(
                        onPressed: () {
                          if (mounted) {
                            Navigator.of(context).pushNamed(Routes.settings);
                          }
                        },
                        label: Text(
                            AppLocalizations.of(context)!.text('Settings')),
                        icon: FaIcon(
                          FontAwesomeIcons.cog,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      );

  Widget loginCard() {
    return Opacity(
      opacity: animation.value,
      child: SizedBox(
        width: !kIsWeb ? MediaQuery.of(context).size.width * 0.85 : 400,
        child: Card(
          color: Colors.white,
          elevation: 2.0,
          child: _loginBuilder(),
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    if (loginUsername.trim().isNotEmpty && loginPassword.trim().isNotEmpty) {
      LoginRequest request = LoginRequest(
          clientId: widget.appState.applicationMetaData?.clientId ?? '',
          createAuthKey: rememberMe,
          username: loginUsername,
          password: loginPassword);

      widget.cubit.login(request);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter username and password!')));
    }
  }

  @override
  void initState() {
    super.initState();

    rememberMe = widget.appState.appConfig!.rememberMeChecked;
    loginUsername = widget.lastUsername;

    _usernameController = TextEditingController(text: loginUsername);
    _passwordController = TextEditingController();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));

    animation.addListener(() => setState(() {}));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loginCard();
  }
}
