import 'dart:io';

import 'package:content_share_manage/api/device.dart';
import 'package:content_share_manage/main.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatefulWidget {
  const InitPage({Key? key}) : super(key: key);

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  // 服务器地址
  TextEditingController httpUrlController =
      TextEditingController(text: "http://127.0.0.1:8000");

  // 服务器密码
  TextEditingController httpPassController = TextEditingController();

  // 设备名称
  TextEditingController deviceNameController =
      TextEditingController(text: kIsWeb ? "web" : Platform.operatingSystem);

  // 加密密钥
  TextEditingController encryptionKeyController = TextEditingController();

  // 加密偏移量
  TextEditingController encryptionOffsetController = TextEditingController();

  @override
  void initState() {
    (() async {
      var sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token") ?? "";
      if (token.isNotEmpty) {
        Navigator.pushNamed(context, "/home");
      }

      httpUrlController.text = sharedPreferences.getString("serverUrl") ?? "";
      httpPassController.text = sharedPreferences.getString("serverPass") ?? "";
      encryptionKeyController.text =
          sharedPreferences.getString("encryptionKey") ?? "";
      encryptionOffsetController.text =
          sharedPreferences.getString("encryptionOffset") ?? "";
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              exit(0);
            },
            icon: const Icon(Icons.close)),
        title: const Text("初始化"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    labelText: '服务器地址',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                httpUrlController.text = "";
                              }),
                          icon: const Icon(
                            Icons.close,
                          )),
                    ),
                    hintText: 'http://127.0.0.1:8000'),
                controller: httpUrlController,
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                (() async {
                                  var sharedPreferences =
                                      await SharedPreferences.getInstance();
                                  sharedPreferences.setString(
                                      "serverUrl", httpUrlController.text);
                                  httpClient.setUrl(httpUrlController.text);
                                  try {
                                    httpPassController.text = await httpClient
                                        .get("settings/password");
                                    sharedPreferences.setString(
                                        "serverPass", httpPassController.text);
                                    httpClient.setPass(httpPassController.text);
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(error.toString())));
                                  }
                                })();
                              }),
                          icon: const Icon(
                            Icons.password,
                          )),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                httpPassController.text = "";
                              }),
                          icon: const Icon(
                            Icons.close,
                          )),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    labelText: '服务器密码',
                    hintText: '点击左侧按钮自动获取'),
                controller: httpPassController,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: const [
                  Text("设备信息"),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  labelText: '设备名称',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: IconButton(
                        onPressed: () => setState(() {
                              deviceNameController.text = "";
                            }),
                        icon: const Icon(
                          Icons.close,
                        )),
                  ),
                ),
                controller: deviceNameController,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        var sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            "serverUrl", httpUrlController.text);
                        sharedPreferences.setString(
                            "serverPass", httpPassController.text);
                        httpClient.setUrl(httpUrlController.text);
                        httpClient.setPass(httpPassController.text);

                        late int type;
                        if (kIsWeb) {
                          type = 4;
                        } else {
                          if (Platform.isAndroid) {
                            type = 0;
                          }
                          if (Platform.isIOS) {
                            type = 1;
                          }
                          if (Platform.isLinux) {
                            type = 2;
                          }
                          if (Platform.isMacOS) {
                            type = 3;
                          }
                          if (Platform.isWindows) {
                            type = 5;
                          }
                        }

                        try {
                          var device = await createDevice({
                            "name": deviceNameController.text,
                            "type": type,
                          });
                          sharedPreferences.setString("token", device.token);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("连接成功！")));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e
                                  .toString()
                                  .replaceFirst("Exception:", ""))));
                        }
                      },
                      child: const Text("测试连接")),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: const [
                  Expanded(child: Text("加密(下方数据仅会保存在本地)")),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              TextField(
                maxLength: 16,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                encryptionKeyController.text =
                                    Encrypt.Key.fromSecureRandom(16)
                                        .base64
                                        .substring(0, 16);
                              }),
                          icon: const Icon(
                            Icons.abc,
                          )),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                encryptionKeyController.text = "";
                              }),
                          icon: const Icon(
                            Icons.close,
                          )),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    labelText: '密钥',
                    hintText: '点击左侧按钮自动生成'),
                controller: encryptionKeyController,
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                maxLength: 16,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                encryptionOffsetController.text =
                                    Encrypt.Key.fromSecureRandom(16)
                                        .base64
                                        .substring(0, 16);
                              }),
                          icon: const Icon(
                            Icons.abc,
                          )),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                encryptionOffsetController.text = "";
                              }),
                          icon: const Icon(
                            Icons.close,
                          )),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    labelText: '偏移量',
                    hintText: '点击左侧按钮自动生成'),
                controller: encryptionOffsetController,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        var sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            "encryptionKey", encryptionKeyController.text);
                        sharedPreferences.setString("encryptionOffset",
                            encryptionOffsetController.text);
                        Navigator.pushNamed(context, "/");
                        httpClient.init();
                      },
                      child: const Text("进入")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
