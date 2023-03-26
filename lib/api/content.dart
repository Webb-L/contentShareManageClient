import 'dart:convert';

import 'package:content_share_manage/main.dart';

import '../model/content.dart';

Future<List<Content>> queryContentByLimit(int start, int end) async {
  List<Content> contents = [];

  var result =
      jsonDecode(await httpClient.get("content", "&start=$start&end=$end"));
  for (var value in (result as List<dynamic>)) {
    var deviceType = value["DeviceType"] as int;
    try {
      value["Text"] = deviceType == 6
          ? value["Text"]
          : httpClient.encrypter.decrypt64(value["Text"], iv: httpClient.iv);
    } catch (e) {}
    contents.add(Content.toModel(value));
  }

  return contents;
}

Future<Content> sendContent(String content) async {
  var tempContent = jsonDecode(await httpClient.post("content", {
    "text": httpClient.encrypter.encrypt(content, iv: httpClient.iv).base64,
    "type": 1,
  }));

  try {
    tempContent["Text"] =
        httpClient.encrypter.decrypt64(tempContent["Text"], iv: httpClient.iv);
  } catch (e) {}

  return Content.toModel(tempContent);
}

Future<String> editContentById(Content content) async {
  var data = content.toJson();
  if (content.deviceType != 6) {
    data["Text"] =
        httpClient.encrypter.encrypt(content.text, iv: httpClient.iv).base64;
  }

  return await httpClient.put("content/${content.id}", data);
}

Future<Content> queryContentById(String id) async {
  var resultText = await httpClient.get("content/$id");
  var content = jsonDecode(resultText);

  var deviceType = content["DeviceType"] as int;
  try {
    content["Text"] = deviceType == 6
        ? content["Text"]
        : httpClient.encrypter.decrypt64(content["Text"], iv: httpClient.iv);
  } catch (e) {}
  return Content.toModel(content);
}

Future<String> deleteContentById(String id) async {
  return await httpClient.delete("content/$id");
}
