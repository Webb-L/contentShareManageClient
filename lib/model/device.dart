class Device {
  late String name;
  late String token;
  late int type;
  late bool isAdmin;
  late bool isRead;
  late bool isSend;

  Device(this.name, this.token, this.type, this.isAdmin,
      this.isRead, this.isSend);

  static Device toModel(dynamic json) {
    return Device(
        json["Name"] as String,
        json["Token"] as String,
        json["Type"] as int,
        json["IsAdmin"] as bool,
        json["IsRead"] as bool,
        json["IsSend"] as bool);
  }
}
