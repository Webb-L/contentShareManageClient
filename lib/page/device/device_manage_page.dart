import 'dart:ui';

import 'package:content_share_manage/components/device/DeviceCard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/device.dart';
import '../../model/device.dart';

class DeviceManagePage extends StatefulWidget {
  const DeviceManagePage({Key? key}) : super(key: key);

  @override
  State<DeviceManagePage> createState() => _DeviceManagePageState();
}

class _DeviceManagePageState extends State<DeviceManagePage> {
  int start = 0;
  int count = 30;
  bool isFinishLoading = false;
  List<Device> devices = [];
  final ScrollController _scrollController = ScrollController();
  bool firstOpen = true;

  String serverUrl = "";

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFinishLoading) {
        start++;
        (() async {
          try {
            var tempList =
                (await queryDeviceByLimit(start * count, (start + 1) * 30));
            setState(() {
              isFinishLoading = tempList.isEmpty;
              devices.addAll(tempList);
            });
          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString().replaceFirst("Exception:", ""))));
          }
        })();
      }
    });

    (() async {
      var sharedPreferences = await SharedPreferences.getInstance();
      serverUrl = sharedPreferences.getString("serverUrl") ?? "";

      try {
        devices.clear();
        var tempList = (await queryDeviceByLimit(start * 30, (start + 1) * 30));
        firstOpen = false;
        setState(() {
          devices.addAll(tempList);
        });
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst("Exception:", ""))));
      }
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int gridItemWidth = MediaQuery.of(context).size.width ~/ 300;

    return Scaffold(
      appBar: AppBar(
        title: const Text("设备管理"),
        actions: [
          IconButton(
              onPressed: () {
                createWebHookDevice(context);
              },
              icon: const Icon(Icons.webhook))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridItemWidth < 1 ? 1 : gridItemWidth,
                  mainAxisExtent: 120),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: devices.length + 1,
              itemBuilder: (context, index) {
                if (index == devices.length) {
                  if (isFinishLoading ||
                      (firstOpen && devices.isEmpty) ||
                      devices.length <= 30) {
                    return Center(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.not_interested,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text("找不到更多数据\n你可以点击右下角的发送按钮")
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: const [
                      SizedBox(
                        height: 20,
                      ),
                      Text("加载更多数据中..."),
                      SizedBox(
                        height: 8,
                      ),
                      CircularProgressIndicator()
                    ],
                  );
                }
                return DeviceCard(devices[index], deleteDeviceCallback: () {
                  setState(() {
                    devices.removeAt(index);
                  });
                });
              }),
        ),
      ),
    );
  }

  void createWebHookDevice(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController webhookName = TextEditingController();
          var helperText = "";
          return AlertDialog(
            title: const Text("创建WebHook设备"),
            content: TextField(
              maxLength: 32,
              decoration: InputDecoration(
                  helperText: helperText,
                  border: const OutlineInputBorder(),
                  labelText: "设备名称"),
              controller: webhookName,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("取消")),
              TextButton(
                  onPressed: () async {
                    try {
                      var device = await createDevice(
                          {"name": webhookName.text, "type": 6});
                      Navigator.of(context).pop(true);
                      showWebHookDevice(device.token);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              e.toString().replaceFirst("Exception:", ""))));
                    }
                  },
                  child: const Text("创建"))
            ],
          );
        });
  }

  Future<void> _refreshData() async {
    isFinishLoading = false;
    start = 0;

    try {
      devices.clear();
      var tempList = (await queryDeviceByLimit(start * 30, (start + 1) * 30));
      setState(() {
        (() async {
          devices.addAll(tempList);
        })();
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception:", ""))));
    }
  }

  Future<bool?> showWebHookDevice(String token) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("如何使用："),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "凭证：",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SelectableText(token),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "发送内容：",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "GET请求(URL)：",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SelectableText(
                      "${sharedPreferences.getString("serverUrl") ?? ""}/webhook/$token/?type=1&text=发送的内容"),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "POST请求(URL)：",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SelectableText(
                      "${sharedPreferences.getString("serverUrl") ?? ""}/webhook/$token/"),
                  Text(
                    "POST请求(请求数据)：",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SelectableText('{"type":1,"text":"发送的内容"}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("我知道了")),
            ],
          );
        });
  }
}
