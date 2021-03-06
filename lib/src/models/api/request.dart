import 'package:uuid/uuid.dart';

class Request {
  final String clientId;
  final String id;
  final bool? reload;

  String get debugInfo => 'clientId: $clientId';

  Request({required this.clientId, this.reload = false}) : id = Uuid().v1();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
      };
}
