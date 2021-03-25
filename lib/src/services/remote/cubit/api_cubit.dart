import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/requests/data/delete_record_request.dart';
import 'package:flutterclient/src/models/api/requests/data/fetch_data_request.dart';
import 'package:flutterclient/src/models/api/requests/data/filter_data_request.dart';
import 'package:flutterclient/src/models/api/requests/data/insert_record_request.dart';
import 'package:flutterclient/src/models/api/requests/data/save_data_request.dart';
import 'package:flutterclient/src/models/api/requests/data/set_values_request.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../injection_container.dart';
import '../../../models/api/errors/failure.dart';
import '../../../models/api/request.dart';
import '../../../models/api/requests/application_style_request.dart';
import '../../../models/api/requests/change_request.dart';
import '../../../models/api/requests/close_screen_request.dart';
import '../../../models/api/requests/data/data_request.dart';
import '../../../models/api/requests/data/meta_data_request.dart';
import '../../../models/api/requests/device_status_request.dart';
import '../../../models/api/requests/download_images_request.dart';
import '../../../models/api/requests/download_translation_request.dart';
import '../../../models/api/requests/login_request.dart';
import '../../../models/api/requests/logout_request.dart';
import '../../../models/api/requests/menu_request.dart';
import '../../../models/api/requests/navigation_request.dart';
import '../../../models/api/requests/open_screen_request.dart';
import '../../../models/api/requests/press_button_request.dart';
import '../../../models/api/requests/set_component_value.dart';
import '../../../models/api/requests/startup_request.dart';
import '../../../models/api/requests/tab_close_request.dart';
import '../../../models/api/requests/tab_select_request.dart';
import '../../../models/api/requests/upload_request.dart';
import '../../../models/api/response_object.dart';
import '../../../models/api/response_object.dart';
import '../../../models/api/response_object.dart';
import '../../../models/api/response_objects/application_meta_data_response_object.dart';
import '../../../models/api/response_objects/application_parameters_response_object.dart';
import '../../../models/api/response_objects/application_style/application_style_response_object.dart';
import '../../../models/api/response_objects/authentication_data_response_object.dart';
import '../../../models/api/response_objects/close_screen_action_response_object.dart';
import '../../../models/api/response_objects/device_status_response_object.dart';
import '../../../models/api/response_objects/download_action_response_object.dart';
import '../../../models/api/response_objects/download_response_object.dart';
import '../../../models/api/response_objects/language_response_object.dart';
import '../../../models/api/response_objects/login_response_object.dart';
import '../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../models/api/response_objects/response_data/data/data_book.dart';
import '../../../models/api/response_objects/response_data/data/dataprovider_changed.dart';
import '../../../models/api/response_objects/response_data/meta_data/data_book_meta_data.dart';
import '../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../models/api/response_objects/restart_response_object.dart';
import '../../../models/api/response_objects/show_document_response_object.dart';
import '../../../models/api/response_objects/upload_action_response_object.dart';
import '../../../models/api/response_objects/user_data_response_object.dart';
import '../../../models/state/app_state.dart';
import '../../../util/download/download_helper.dart';
import '../../local/locale/supported_locale_manager.dart';
import '../../local/shared_preferences/shared_preferences_manager.dart';
import '../network_info/network_info.dart';
import '../rest/rest_client.dart';

part 'api_state.dart';

class ApiCubit extends Cubit<ApiState> {
  final RestClient client;
  final AppState appState;
  final SharedPreferencesManager manager;
  final NetworkInfo networkInfo;

  ApiCubit(
      {required this.client,
      required this.appState,
      required this.manager,
      required this.networkInfo})
      : super(ApiInitial());

  Future<void> startup(StartupRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/startup';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) => emit(r));
  }

  Future<void> applicationStyle(ApplicationStyleRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) => emit(r));
  }

  Future<void> downloadImages(DownloadImagesRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendDownloadRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) => emit(r));
  }

  Future<void> downloadTranslation(DownloadTranslationRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendDownloadRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) => emit(r));
  }

  Future<void> login(LoginRequest request) async {
    emit(ApiLoading());

    final path = appState.serverConfig!.baseUrl + '/api/v2/login';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    emit(ApiLoading(stop: true));

    either.fold((l) => emit(l), (r) {
      if (r.hasObject<AuthenticationDataResponseObject>()) {
        manager.authKey =
            r.getObjectByType<AuthenticationDataResponseObject>()!.authKey;
      }

      emit(r);
    });
  }

  Future<void> logout(LogoutRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/logout';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) {
      manager.authKey = null;
      manager.userData = null;

      appState.userData = null;

      emit(r);
    });
  }

  Future<void> openScreen(OpenScreenRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/v2/openScreen';

    emit(ApiLoading());

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    emit(ApiLoading(stop: true));

    either.fold((l) => emit(l), (r) {
      appState.currentMenuComponentId = request.componentId;
      emit(r);
    });
  }

  Future<void> navigation(NavigationRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/navigation';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) => emit(r));
  }

  Future<void> pressButton(PressButtonRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/v2/pressButton';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    either.fold((l) => emit(l), (r) => emit(r));
  }

  Future<ApiState> data(DataRequest request) async {
    String path = appState.serverConfig!.baseUrl;

    if (request is SetValuesRequest) {
      path += '/api/dal/setValues';
    } else if (request is InsertRecordRequest) {
      path += '/api/dal/insertRecord';
    } else if (request is FetchDataRequest) {
      path += '/api/dal/fetch';
    } else if (request is SaveDataRequest) {
      path += '/api/dal/save';
    } else if (request is FilterDataRequest) {
      path += '/api/dal/filter';
    } else if (request is DeleteRecordRequest) {
      path += '/api/dal/deleteRecord';
    } else if (request is MetaDataRequest) {
      path += '/api/dal/metaData';
    }

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    if (request is InsertRecordRequest && request.setValues != null) {
      this.data(request.setValues!);
    }

    return either.fold((l) {
      emit(l);
      return l;
    }, (r) {
      emit(r);
      return r;
    });
  }

  Future<void> change(ChangeRequest request) {
    // TODO: implement change
    throw UnimplementedError();
  }

  Future<void> closeScreen(CloseScreenRequest request) {
    // TODO: implement closeScreen
    throw UnimplementedError();
  }

  Future<void> deviceStatus(DeviceStatusRequest request) {
    // TODO: implement deviceStatus
    throw UnimplementedError();
  }

  Future<void> menu(MenuRequest request) {
    // TODO: implement menu
    throw UnimplementedError();
  }

  Future<void> setComponentValue(SetComponentValueRequest request) {
    // TODO: implement setComponentValue
    throw UnimplementedError();
  }

  Future<void> tabClose(TabCloseRequest request) {
    // TODO: implement tabClose
    throw UnimplementedError();
  }

  Future<void> tabSelect(TabSelectRequest request) {
    // TODO: implement tabSelect
    throw UnimplementedError();
  }

  Future<void> upload(UploadRequest request) {
    // TODO: implement upload
    throw UnimplementedError();
  }

  Future<Either<ApiError, ApiResponse>> _sendRequest(
      Uri uri, Request request) async {
    if (!kIsWeb) {
      if (!(await networkInfo.isConnected)) {
        return Left(ApiError(
            failure: ServerFailure(
                title: 'Internet problems.',
                message: 'No connection to the internet!',
                details: '',
                name: 'message.error')));
      }
    }

    Either<Failure, http.Response> either =
        await client.post(uri: uri, data: request.toJson());

    return either.fold((l) => Left(ApiError(failure: l)), (r) {
      if (r.statusCode != 404) {
        List decodedBody = _getDecodedBody(r);
        Failure? failure = _getErrorIfExists(decodedBody);

        if (failure != null) {
          return Left(ApiError(failure: failure));
        } else {
          final cookie = r.headers['set-cookie'];

          if (cookie != null && cookie.isNotEmpty) {
            final index = cookie.indexOf(';');

            if (client.headers == null) {
              client.headers = <String, String>{
                'Content-Type': 'application/json'
              };
            }

            client.headers!['cookie'] =
                (index == -1) ? cookie : cookie.substring(0, index);
          }

          ApiResponse response = ApiResponse.fromJson(request, decodedBody);

          return Right(response);
        }
      } else {
        return Left(ApiError(
            failure: Failure(
                details: '',
                message: 'App with appname not found',
                name: 'message.error',
                title: 'Not found')));
      }
    });
  }

  Future<Either<ApiError, ApiResponse>> _sendDownloadRequest(
      Uri uri, Request request) async {
    if (!kIsWeb) {
      if (!(await networkInfo.isConnected)) {
        return Left(ApiError(
            failure: ServerFailure(
                title: 'Internet problems.',
                message: 'No connection to the internet!',
                details: '',
                name: 'message.error')));
      }
    }

    Either<Failure, http.Response> either = await client.post(
        uri: uri,
        data: request.toJson(),
        timeout: appState.appConfig!.requestTimeout);

    return either.fold((l) => Left(ApiError(failure: l)), (r) async {
      bool isTranslation = (request is DownloadTranslationRequest);

      if (!kIsWeb) {
        deleteOutdatedData(
            baseUrl: appState.serverConfig!.baseUrl,
            translation: isTranslation);
      }

      Archive archive = ZipDecoder().decodeBytes(r.bodyBytes);

      late String localFilePath;

      if (!kIsWeb) {
        localFilePath = getLocalFilePath(
              baseDir: appState.baseDirectory,
              baseUrl: appState.serverConfig!.baseUrl,
              appName: appState.serverConfig!.appName,
              appVersion: appState.applicationMetaData!.version,
              translation: isTranslation,
            ) +
            '/';
      } else {
        localFilePath = '';
      }

      if (!isTranslation) {
        appState.fileConfig.images.clear();
      }

      for (final file in archive) {
        final filename = '$localFilePath${file.name}';

        if (!kIsWeb) {
          if (file.isFile) {
            var outputFile = File(filename);

            outputFile = await outputFile.create(recursive: true);

            await outputFile.writeAsBytes(file.content);

            if (isTranslation) {
              appState.translationConfig.possibleTranslations
                  .putIfAbsent(file.name, () => '$filename');

              String trimmedFilename = file.name;

              if (trimmedFilename.contains('_')) {
                trimmedFilename = trimmedFilename.substring(
                    trimmedFilename.indexOf('_') + 1,
                    trimmedFilename.indexOf('.'));
              } else {
                trimmedFilename = 'en';
              }

              if (!appState.translationConfig.supportedLocales
                  .contains(Locale(trimmedFilename))) {
                appState.translationConfig.supportedLocales
                    .add(Locale(trimmedFilename));
              }
            } else {
              appState.fileConfig.images.add(filename);
            }
          }
        } else {
          if (isTranslation) {
            appState.translationConfig.possibleTranslations
                .putIfAbsent(file.name, () => filename);

            String trimmedFilename = file.name;

            if (trimmedFilename.contains('_')) {
              trimmedFilename = trimmedFilename.substring(
                  trimmedFilename.indexOf('_') + 1,
                  trimmedFilename.indexOf('.'));
            } else {
              trimmedFilename = 'en';
            }

            if (!appState.translationConfig.supportedLocales
                .contains(Locale(trimmedFilename))) {
              appState.translationConfig.supportedLocales
                  .add(Locale(trimmedFilename));
            }
          } else {
            appState.fileConfig.images.add(filename);
          }

          if (file.isFile) {
            appState.fileConfig.files
                .putIfAbsent('/${file.name}', () => utf8.decode(file.content));
          }
        }
      }

      if (isTranslation) {
        manager.possibleTranslations =
            appState.translationConfig.possibleTranslations;

        sl<SupportedLocaleManager>().value =
            appState.translationConfig.supportedLocales;
      } else {
        manager.savedImages = appState.fileConfig.images;
      }

      ApiResponse response = ApiResponse(request: request, objects: [
        DownloadResponseObject(name: 'download', translation: isTranslation)
      ]);

      return Right(response);
    });
  }

  Failure? _getErrorIfExists(List<dynamic> responses) {
    if (responses.isNotEmpty) {
      for (final response in responses) {
        if (response['name'] == 'message.error' ||
            response['name'] == 'server.error' ||
            response['name'] == 'message.sessionexpired') {
          return ServerFailure.fromJson(response);
        }
      }
    }

    return null;
  }

  List<dynamic> _getDecodedBody(http.Response response) {
    String body = utf8Convert(response.body);

    dynamic decodedBody = json.decode(body);

    if (decodedBody is List)
      return decodedBody;
    else
      return [decodedBody];
  }

  String utf8Convert(String text) {
    try {
      List<int> bytes = text.toString().codeUnits;
      return utf8.decode(bytes);
    } catch (e) {
      print("Failed to decode string to utf-8!");
      return text;
    }
  }
}
