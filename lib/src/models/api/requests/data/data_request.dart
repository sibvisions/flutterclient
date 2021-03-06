import 'package:flutterclient/src/models/api/request.dart';

class DataRequest extends Request {
  final String dataProvider;

  @override
  String get debugInfo => 'clientId: $clientId, dataProvider: $dataProvider';

  DataRequest(
      {required String clientId,
      bool reload = false,
      required this.dataProvider})
      : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'dataProvider': dataProvider, ...super.toJson()};
}
