class Content {
  late String id;
  late String deviceName;
  late int deviceType;
  late int type;
  late String text;
  late int createDate;
  late int updateDate;

  Content(this.id, this.deviceName, this.deviceType, this.type, this.text,
      this.createDate, this.updateDate);

  static Content toModel(dynamic json) {
    return Content(
        json["Id"] as String,
        json["DeviceName"] as String,
        json["DeviceType"] as int,
        json["Type"] as int,
        json["Text"] as String,
        json["CreateDate"] as int,
        json["UpdateDate"] as int);
  }

  Map<String, dynamic> toJson() => {
        "Id": id,
        "DeviceName": deviceName,
        "Type": type,
        "Text": text,
      };
}
