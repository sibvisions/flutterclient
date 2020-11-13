import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';

import '../../../models/api/request.dart';
import '../../../models/api/request/device_status.dart';
import '../../../models/api/request/download.dart';
import '../../../models/api/request/navigation.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/request/upload.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/api/so_action.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/menu_arguments.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/get_menu_widget.dart';
import '../../frames/app_frame.dart';
import '../../screen/i_screen.dart';
import '../../screen/so_component_creator.dart';
import '../../screen/so_screen.dart';
import '../dialogs/upload_file_picker.dart';
import '../menu/menu_drawer_widget.dart';

class OpenScreenPageWidget extends StatefulWidget {
  final String title;
  final Response response;
  final String menuComponentId;
  final String templateName;
  final List<MenuItem> items;
  final AppState appState;

  const OpenScreenPageWidget(
      {Key key,
      this.title,
      this.response,
      this.menuComponentId,
      this.templateName,
      this.items,
      this.appState})
      : super(key: key);

  @override
  _OpenScreenPageWidgetState createState() => _OpenScreenPageWidgetState();
}

class _OpenScreenPageWidgetState extends State<OpenScreenPageWidget>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Orientation lastOrientation;
  double width;
  double height;
  RestartableTimer _deviceStatusTimer;
  String rawComponentId;
  String title;
  bool closeCurrentScreen;

  Response currentResponse;

  GlobalKey screenKey;

  String get menuMode {
    if (widget.appState.applicationStyle != null &&
        widget.appState.applicationStyle?.menuMode != null)
      return widget.appState.applicationStyle?.menuMode;
    else
      return 'grid';
  }

  void _firePreviewerListener() {
    // if (widget.appState.appListener != null)
    //   widget.appState.appListener.fireOnUpdateListener(ApplicationApi(context));
  }

  void _createDeviceStatusTimer() {
    if (lastOrientation == null) {
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    } else if (lastOrientation != MediaQuery.of(context).orientation ||
        width != MediaQuery.of(context).size.width ||
        height != MediaQuery.of(context).size.height) {
      DeviceStatus deviceStatus = DeviceStatus(
          screenSize: MediaQuery.of(context).size,
          timeZoneCode: '',
          langCode: '',
          clientId: widget.appState.clientId);

      BlocProvider.of<ApiBloc>(context).add(deviceStatus);
      lastOrientation = MediaQuery.of(context).orientation;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
      // if (_deviceStatusTimer == null) {
      //   _deviceStatusTimer =
      //       RestartableTimer(const Duration(milliseconds: 50), () {
      //     DeviceStatus status = DeviceStatus(
      //         screenSize: MediaQuery.of(context).size,
      //         timeZoneCode: "",
      //         langCode: "");
      //     BlocProvider.of<ApiBloc>(context).add(status);
      //     lastOrientation = MediaQuery.of(context).orientation;
      //     width = MediaQuery.of(context).size.width;
      //     height = MediaQuery.of(context).size.height;

      //     _deviceStatusTimer.cancel();
      //     _deviceStatusTimer = null;
      //   });
      // } else {
      //   _deviceStatusTimer.reset();
      // }
    }
  }

  _blocListener() => BlocListener<ApiBloc, Response>(
        listener: (BuildContext context, Response state) {
          if (state.request.requestType != RequestType.LOADING) {
            if (state.request.requestType == RequestType.MENU) {
              widget.appState.items = state.menu.entries;
            }

            if (state.request.requestType == RequestType.CLOSE_SCREEN) {
              Navigator.of(context).pushReplacementNamed('/menu',
                  arguments: MenuArguments(widget.appState.items, true));
            } else {
              if (isScreenRequest(state.request.requestType)) {
                if (state.responseData.screenGeneric != null &&
                    !state.responseData.screenGeneric.update) {
                  setState(() {
                    title = state.responseData.screenGeneric.screenTitle;
                  });
                }

                setState(() {
                  currentResponse = state;
                });

                if (state.closeScreenAction != null) {
                  setState(() {
                    this.closeCurrentScreen = true;
                  });
                } else {
                  setState(() {
                    this.closeCurrentScreen = false;
                  });
                }

                if (state.request.requestType == RequestType.DEVICE_STATUS) {
                  setState(() {
                    widget.appState.layoutMode =
                        state.deviceStatusResponse.layoutMode;
                  });
                }

                _checkForButtonAction(state);

                if (state.request.requestType == RequestType.OPEN_SCREEN) {
                  if (mounted &&
                      _scaffoldKey.currentState != null &&
                      _scaffoldKey.currentState.isEndDrawerOpen)
                    SchedulerBinding.instance.addPostFrameCallback(
                        (_) => Navigator.of(context).pop());

                  widget.response.request = state.request;
                  widget.response.responseData = state.responseData;

                  rawComponentId =
                      state.responseData?.screenGeneric?.componentId;
                }

                if (state.responseData.screenGeneric != null &&
                    !state.responseData.screenGeneric.update) {
                  widget.response.request = state.request;
                  widget.response.responseData = state.responseData;

                  rawComponentId = state.responseData.screenGeneric.componentId;
                }

                if (state.request.requestType == RequestType.NAVIGATION &&
                    state.responseData.screenGeneric == null) {
                  Navigator.of(context).pushReplacementNamed('/menu',
                      arguments: MenuArguments(widget.appState.items, true));
                }
              }
            }
          }
        },
        child: WillPopScope(
            onWillPop: () async => _onWillPop(),
            child: Scaffold(
                endDrawer: _endDrawer(),
                key: _scaffoldKey,
                appBar: _appBar(this.title),
                body: Builder(builder: (BuildContext context) {
                  SoScreen screen;

                  if (this.currentResponse.request.requestType !=
                      RequestType.DEVICE_STATUS) {
                    screen = SoScreen(
                        screenKey: this.screenKey,
                        componentId: rawComponentId,
                        closeCurrentScreen: this.closeCurrentScreen,
                        componentCreator: SoComponentCreator(context),
                        response: this.currentResponse);
                  }

                  if (widget.appState.applicationStyle != null &&
                      widget.appState.applicationStyle?.desktopIcon != null) {
                    widget.appState.appFrame.setScreen(Container(
                        decoration: BoxDecoration(
                            color: (widget.appState.applicationStyle != null &&
                                    widget.appState.applicationStyle
                                            ?.desktopColor !=
                                        null)
                                ? widget.appState.applicationStyle?.desktopColor
                                : null,
                            image: !kIsWeb
                                ? DecorationImage(
                                    image: FileImage(File(
                                        '${widget.appState.dir}${widget.appState.applicationStyle?.desktopIcon}')),
                                    fit: BoxFit.cover)
                                : DecorationImage(
                                    image: widget.appState.files.containsKey(
                                            widget.appState.applicationStyle
                                                .desktopIcon)
                                        ? MemoryImage(base64Decode(
                                            widget.appState.files[widget
                                                .appState
                                                .applicationStyle
                                                .desktopIcon]))
                                        : null,
                                    fit: BoxFit.cover,
                                  )),
                        child: this.currentResponse.request.requestType !=
                                RequestType.DEVICE_STATUS
                            ? screen
                            : widget.appState.appFrame.screen));

                    return widget.appState.appFrame.getWidget();
                  } else if (widget.appState.applicationStyle != null &&
                      widget.appState.applicationStyle?.desktopColor != null) {
                    widget.appState.appFrame.setScreen(Container(
                        decoration: BoxDecoration(
                            color:
                                widget.appState.applicationStyle?.desktopColor),
                        child: this.currentResponse.request.requestType !=
                                RequestType.DEVICE_STATUS
                            ? screen
                            : widget.appState.appFrame.screen));

                    return widget.appState.appFrame.getWidget();
                  } else {
                    widget.appState.appFrame.setScreen(
                        this.currentResponse.request.requestType !=
                                RequestType.DEVICE_STATUS
                            ? screen
                            : widget.appState.appFrame.screen);
                    return widget.appState.appFrame.getWidget();
                  }
                }))),
      );

  AppBar _appBar(String title) {
    return widget.appState.appFrame.showScreenHeader
        ? AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            actions: <Widget>[
              IconButton(
                icon: FaIcon(FontAwesomeIcons.ellipsisV),
                onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigation navigation = Navigation(
                    clientId: widget.appState.clientId,
                    componentId: rawComponentId);

                Future.delayed(const Duration(milliseconds: 100), () {
                  BlocProvider.of<ApiBloc>(context).add(navigation);
                });
              },
            ),
            title: Text(title),
          )
        : null;
  }

  MenuDrawerWidget _endDrawer() => widget.appState.appFrame.showScreenHeader
      ? MenuDrawerWidget(
          appState: widget.appState,
          menuItems: widget.items,
          listMenuItems: true,
          currentTitle: widget.title,
          groupedMenuMode:
              (widget.appState.applicationStyle?.menuMode == 'grid_grouped' ||
                      widget.appState.applicationStyle?.menuMode == 'list') &
                  hasMultipleGroups(),
        )
      : null;

  bool hasMultipleGroups() {
    int groupCount = 0;
    String lastGroup = "";
    if (widget.items != null) {
      widget.items?.forEach((m) {
        if (m.group != lastGroup) {
          groupCount++;
          lastGroup = m.group;
        }
      });
    }
    return (groupCount > 1);
  }

  _onWillPop() async {
    Navigation navigation = Navigation(
        clientId: widget.appState.clientId, componentId: rawComponentId);

    BlocProvider.of<ApiBloc>(context).add(navigation);

    bool close = false;

    await for (Response res in BlocProvider.of<ApiBloc>(context)) {
      if (res.request.requestType == RequestType.NAVIGATION) {
        close = true;
      }
    }

    return close;
  }

  _checkForButtonAction(Response state) {
    if (state.request.requestType == RequestType.PRESS_BUTTON) {
      if (state.downloadAction != null) {
        Download download = Download(
            applicationImages: false,
            libraryImages: false,
            clientId: widget.appState.clientId,
            fileId: state.downloadAction.fileId,
            name: 'file',
            requestType: RequestType.DOWNLOAD);

        BlocProvider.of<ApiBloc>(context).add(download);
      } else if (state.uploadAction != null) {
        openFilePicker(context, widget.appState).then((file) {
          if (file != null) {
            Upload upload = Upload(
                clientId: widget.appState.clientId,
                file: file,
                fileId: state.uploadAction.fileId,
                requestType: RequestType.UPLOAD);

            BlocProvider.of<ApiBloc>(context).add(upload);
          }
        });
      } else if (state.closeScreenAction != null) {
        if (state.responseData.screenGeneric == null)
          Navigator.of(context).pushReplacementNamed('/menu',
              arguments: MenuArguments(widget.appState.items, true));
      }
    }
  }

  _onPressed(MenuItem menuItem) {
    if (widget.appState.screenManager != null &&
        !widget.appState.screenManager
            .getScreen(menuItem.componentId)
            .withServer()) {
      IScreen screen = widget.appState.screenManager
          .getScreen(menuItem.componentId);

      widget.appState.appFrame.setScreen(screen);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => widget.appState.appFrame.getWidget()));
    } else {
      SoAction action =
          SoAction(componentId: menuItem.componentId, label: menuItem.text);

      this.title = action.label;

      OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: widget.appState.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN,
      );

      BlocProvider.of<ApiBloc>(context).add(openScreen);
    }
  }

  _appFrame() {
    if (widget.appState.appFrame is AppFrame) {
      widget.appState.appFrame = AppFrame(context);
    }

    getMenuWidget(
        context, widget.appState, hasMultipleGroups(), _onPressed, menuMode);
  }

  @override
  void initState() {
    super.initState();

    this.currentResponse = widget.response;

    this.title = widget.title;

    _appFrame();

    rawComponentId = widget.response.responseData.screenGeneric.componentId;

    this.screenKey =
        GlobalKey<ComponentScreenWidgetState>(debugLabel: rawComponentId);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    _firePreviewerListener();

    _createDeviceStatusTimer();

    return _blocListener();
  }
}