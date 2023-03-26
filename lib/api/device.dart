import 'dart:convert';


import 'package:content_share_manage/main.dart';

import '../model/device.dart';

Future<List<Device>> queryDeviceByLimit(int start, int end) async {
  List<Device> devices = [];

  for (var value
      in (jsonDecode(await httpClient.get("device", "&start=$start&end=$end"))
          as List<dynamic>)) {
    devices.add(Device.toModel(value));
  }

  return devices;
}

Future<Device> createDevice(Map<String, dynamic> data) async {
  return Device.toModel(jsonDecode(await httpClient.post("device", data)));
}

Future<String> updateDeviceByName(
    String name, Map<String, dynamic> data) async {
  return await httpClient.put("device/$name", data);
}

Future<String> deleteDeviceByName(String name) async {
  return await httpClient.delete("device/$name");
}
