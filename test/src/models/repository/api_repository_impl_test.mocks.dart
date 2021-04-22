// Mocks generated by Mockito 5.0.5 from annotations
// in flutterclient/test/src/models/repository/api_repository_impl_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;

import 'package:archive/src/archive.dart' as _i4;
import 'package:archive/src/util/input_stream.dart' as _i27;
import 'package:archive/src/zip/zip_directory.dart' as _i3;
import 'package:archive/src/zip_decoder.dart' as _i26;
import 'package:flutterclient/src/models/api/data_source.dart' as _i5;
import 'package:flutterclient/src/models/api/requests/application_style_request.dart'
    as _i8;
import 'package:flutterclient/src/models/api/requests/change_request.dart'
    as _i14;
import 'package:flutterclient/src/models/api/requests/close_screen_request.dart'
    as _i15;
import 'package:flutterclient/src/models/api/requests/data/data_request.dart'
    as _i25;
import 'package:flutterclient/src/models/api/requests/device_status_request.dart'
    as _i16;
import 'package:flutterclient/src/models/api/requests/download_images_request.dart'
    as _i10;
import 'package:flutterclient/src/models/api/requests/download_request.dart'
    as _i11;
import 'package:flutterclient/src/models/api/requests/download_translation_request.dart'
    as _i9;
import 'package:flutterclient/src/models/api/requests/login_request.dart'
    as _i12;
import 'package:flutterclient/src/models/api/requests/logout_request.dart'
    as _i13;
import 'package:flutterclient/src/models/api/requests/menu_request.dart'
    as _i17;
import 'package:flutterclient/src/models/api/requests/navigation_request.dart'
    as _i18;
import 'package:flutterclient/src/models/api/requests/open_screen_request.dart'
    as _i19;
import 'package:flutterclient/src/models/api/requests/press_button_request.dart'
    as _i20;
import 'package:flutterclient/src/models/api/requests/set_component_value.dart'
    as _i21;
import 'package:flutterclient/src/models/api/requests/startup_request.dart'
    as _i7;
import 'package:flutterclient/src/models/api/requests/tab_close_request.dart'
    as _i22;
import 'package:flutterclient/src/models/api/requests/tab_select_request.dart'
    as _i23;
import 'package:flutterclient/src/models/api/requests/upload_request.dart'
    as _i24;
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart' as _i2;
import 'package:flutterclient/src/services/remote/network_info/network_info.dart'
    as _i28;
import 'package:mockito/mockito.dart' as _i1;
import 'package:shared_preferences/shared_preferences.dart' as _i29;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeApiState extends _i1.Fake implements _i2.ApiState {}

class _FakeZipDirectory extends _i1.Fake implements _i3.ZipDirectory {}

class _FakeArchive extends _i1.Fake implements _i4.Archive {}

/// A class which mocks [DataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockDataSource extends _i1.Mock implements _i5.DataSource {
  MockDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i2.ApiState> startup(_i7.StartupRequest? request) =>
      (super.noSuchMethod(Invocation.method(#startup, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> applicationStyle(
          _i8.ApplicationStyleRequest? request) =>
      (super.noSuchMethod(Invocation.method(#applicationStyle, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> downloadTranslation(
          _i9.DownloadTranslationRequest? request) =>
      (super.noSuchMethod(Invocation.method(#downloadTranslation, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> downloadImages(
          _i10.DownloadImagesRequest? request) =>
      (super.noSuchMethod(Invocation.method(#downloadImages, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> download(_i11.DownloadRequest? request) =>
      (super.noSuchMethod(Invocation.method(#download, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> login(_i12.LoginRequest? request) =>
      (super.noSuchMethod(Invocation.method(#login, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> logout(_i13.LogoutRequest? request) =>
      (super.noSuchMethod(Invocation.method(#logout, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> change(_i14.ChangeRequest? request) =>
      (super.noSuchMethod(Invocation.method(#change, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> closeScreen(_i15.CloseScreenRequest? request) =>
      (super.noSuchMethod(Invocation.method(#closeScreen, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> deviceStatus(_i16.DeviceStatusRequest? request) =>
      (super.noSuchMethod(Invocation.method(#deviceStatus, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> menu(_i17.MenuRequest? request) =>
      (super.noSuchMethod(Invocation.method(#menu, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> navigation(_i18.NavigationRequest? request) =>
      (super.noSuchMethod(Invocation.method(#navigation, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> openScreen(_i19.OpenScreenRequest? request) =>
      (super.noSuchMethod(Invocation.method(#openScreen, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> pressButton(_i20.PressButtonRequest? request) =>
      (super.noSuchMethod(Invocation.method(#pressButton, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> setComponentValue(
          _i21.SetComponentValueRequest? request) =>
      (super.noSuchMethod(Invocation.method(#setComponentValue, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> tabClose(_i22.TabCloseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#tabClose, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> tabSelect(_i23.TabSelectRequest? request) =>
      (super.noSuchMethod(Invocation.method(#tabSelect, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> upload(_i24.UploadRequest? request) =>
      (super.noSuchMethod(Invocation.method(#upload, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
  @override
  _i6.Future<_i2.ApiState> data(_i25.DataRequest? request) =>
      (super.noSuchMethod(Invocation.method(#data, [request]),
              returnValue: Future<_i2.ApiState>.value(_FakeApiState()))
          as _i6.Future<_i2.ApiState>);
}

/// A class which mocks [ZipDecoder].
///
/// See the documentation for Mockito's code generation for more information.
class MockZipDecoder extends _i1.Mock implements _i26.ZipDecoder {
  MockZipDecoder() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.ZipDirectory get directory =>
      (super.noSuchMethod(Invocation.getter(#directory),
          returnValue: _FakeZipDirectory()) as _i3.ZipDirectory);
  @override
  set directory(_i3.ZipDirectory? _directory) =>
      super.noSuchMethod(Invocation.setter(#directory, _directory),
          returnValueForMissingStub: null);
  @override
  _i4.Archive decodeBytes(List<int>? data,
          {bool? verify = false, String? password}) =>
      (super.noSuchMethod(
          Invocation.method(
              #decodeBytes, [data], {#verify: verify, #password: password}),
          returnValue: _FakeArchive()) as _i4.Archive);
  @override
  _i4.Archive decodeBuffer(_i27.InputStream? input,
          {bool? verify = false, String? password}) =>
      (super.noSuchMethod(
          Invocation.method(
              #decodeBuffer, [input], {#verify: verify, #password: password}),
          returnValue: _FakeArchive()) as _i4.Archive);
}

/// A class which mocks [NetworkInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockNetworkInfo extends _i1.Mock implements _i28.NetworkInfo {
  MockNetworkInfo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<bool> get isConnected =>
      (super.noSuchMethod(Invocation.getter(#isConnected),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
}

/// A class which mocks [SharedPreferences].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedPreferences extends _i1.Mock implements _i29.SharedPreferences {
  @override
  Set<String> getKeys() => (super.noSuchMethod(Invocation.method(#getKeys, []),
      returnValue: <String>{}) as Set<String>);
  @override
  Object? get(String? key) =>
      (super.noSuchMethod(Invocation.method(#get, [key])) as Object?);
  @override
  bool? getBool(String? key) =>
      (super.noSuchMethod(Invocation.method(#getBool, [key])) as bool?);
  @override
  int? getInt(String? key) =>
      (super.noSuchMethod(Invocation.method(#getInt, [key])) as int?);
  @override
  double? getDouble(String? key) =>
      (super.noSuchMethod(Invocation.method(#getDouble, [key])) as double?);
  @override
  String? getString(String? key) =>
      (super.noSuchMethod(Invocation.method(#getString, [key])) as String?);
  @override
  bool containsKey(String? key) =>
      (super.noSuchMethod(Invocation.method(#containsKey, [key]),
          returnValue: false) as bool);
  @override
  List<String>? getStringList(String? key) =>
      (super.noSuchMethod(Invocation.method(#getStringList, [key]))
          as List<String>?);
  @override
  _i6.Future<bool> setBool(String? key, bool? value) =>
      (super.noSuchMethod(Invocation.method(#setBool, [key, value]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> setInt(String? key, int? value) =>
      (super.noSuchMethod(Invocation.method(#setInt, [key, value]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> setDouble(String? key, double? value) =>
      (super.noSuchMethod(Invocation.method(#setDouble, [key, value]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> setString(String? key, String? value) =>
      (super.noSuchMethod(Invocation.method(#setString, [key, value]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> setStringList(String? key, List<String>? value) =>
      (super.noSuchMethod(Invocation.method(#setStringList, [key, value]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> remove(String? key) =>
      (super.noSuchMethod(Invocation.method(#remove, [key]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> commit() =>
      (super.noSuchMethod(Invocation.method(#commit, []),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> clear() => (super.noSuchMethod(Invocation.method(#clear, []),
      returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<void> reload() =>
      (super.noSuchMethod(Invocation.method(#reload, []),
          returnValue: Future<void>.value(null),
          returnValueForMissingStub: Future.value()) as _i6.Future<void>);
}
