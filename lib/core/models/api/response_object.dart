enum ResponseObjectType {
  APPLICATIONMETADATA,
  APPLICATION_STYLE,
  LANGUAGE,
  SCREEN_GENERIC,
  DAL_FETCH,
  DAL_METADATA,
  DAL_DATAPROVIDERCHANGED,
  LOGIN,
  MENU,
  AUTHENTICATIONDATA,
  DOWNLOAD,
  UPLOAD,
  CLOSESCREEN,
  USERDATA,
  SHOWDOCUMENT,
  DEVICESTATUS,
  RESTART,
  ERROR,
}

ResponseObjectType getResponseObjectTypeEnum(String responseObjectType) {
  responseObjectType = 'ResponseObjectType.${responseObjectType.toUpperCase()}';

  return ResponseObjectType.values.firstWhere(
      (f) => f.toString() == responseObjectType.replaceFirst('.', '_', 19),
      orElse: () => null);
}

abstract class ResponseObject {
  ResponseObjectType type;
  String name;
  String componentId;

  ResponseObject({this.name});

  ResponseObject.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      componentId = json['componentId']; 
}