import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/data_source.dart';
import 'package:flutterclient/src/models/api/requests/download_translation_request.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/local_database/offline_database.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';
import 'package:flutterclient/src/services/remote/network_info/network_info.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterclient/injection_container.dart' as di;

import 'api_repository_impl_test.mocks.dart';

@GenerateMocks([DataSource, ZipDecoder, NetworkInfo],
    customMocks: [MockSpec<SharedPreferences>(returnNullOnMissingStub: true)])
void main() {
  late ApiRepositoryImpl repository;
  late MockDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockSharedPreferences mockSharedPreferences;
  late MockZipDecoder mockZipDecoder;

  setUp(() async {
    await di.init();

    mockDataSource = MockDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockSharedPreferences = MockSharedPreferences();
    mockZipDecoder = MockZipDecoder();

    repository = ApiRepositoryImpl(
        appState: _getAppState(),
        dataSource: mockDataSource,
        manager:
            SharedPreferencesManager(sharedPreferences: mockSharedPreferences),
        networkInfo: mockNetworkInfo,
        offlineDataSource: OfflineDatabase(),
        decoder: mockZipDecoder);
  });

  group('download', () {
    group('translation', () {
      final tRequest = DownloadTranslationRequest(
          clientId: 'test_client_id',
          applicationImages: false,
          contentMode: 'json',
          libraryImages: false,
          name: 'translation');

      final tBodyBytes = Uint8List.fromList('test'.codeUnits);

      test('should call decodeBytes and data source when getting valid data',
          () async {
        when(mockDataSource.downloadTranslation(tRequest))
            .thenAnswer((_) async => ApiResponse(request: tRequest, objects: [
                  DownloadResponseObject(
                      name: 'download',
                      translation: true,
                      bodyBytes: tBodyBytes)
                ]));

        when(mockZipDecoder.decodeBytes(tBodyBytes))
            .thenAnswer((_) => Archive());

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        await repository.downloadTranslation(tRequest);

        verify(mockDataSource.downloadTranslation(tRequest));
        verify(mockZipDecoder.decodeBytes(tBodyBytes));
        verify(mockNetworkInfo.isConnected);
      });
    });
  });
}

_getAppState() {
  return AppState()
    ..serverConfig =
        ServerConfig(baseUrl: 'testw/wdwdw/wdwqd/wdwdw', appName: 'test')
    ..applicationMetaData = ApplicationMetaDataResponseObject(
        name: 'applicationMetaData',
        langCode: 'en',
        languageResource: 'test',
        clientId: 'test_clientId',
        version: '1.0.0');
}
