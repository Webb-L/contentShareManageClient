import 'package:content_share_manage/api/device.dart';
import 'package:content_share_manage/components/dialog.dart';
import 'package:content_share_manage/model/device.dart';
import 'package:flutter/material.dart';

class DeviceCard extends StatefulWidget {
  final Device device;
  final VoidCallback deleteDeviceCallback;

  const DeviceCard(this.device, {Key? key, required this.deleteDeviceCallback})
      : super(key: key);

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {}, icon: deviceType(widget.device.type)),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                  child: Text(
                widget.device.name,
                overflow: TextOverflow.ellipsis,
              )),
              const Spacer(),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 0,
                      enabled: !widget.device.isAdmin,
                      child: const Text("删除")),
                  PopupMenuItem(
                      value: 1,
                      child: Text(widget.device.isAdmin ? "取消管理员" : "设置为管理员")),
                ],
                onSelected: (index) async {
                  switch (index) {
                    case 0:
                      deleteDevice(widget.device.name);
                      break;
                    case 1:
                      var updateStatus =
                          await updateDevice(widget.device.name, {
                        "Type": widget.device.type,
                        "IsAdmin": !widget.device.isAdmin,
                        "IsRead": widget.device.isRead,
                        "IsSend": widget.device.isSend
                      });
                      if (updateStatus) {
                        setState(() {
                          widget.device.isAdmin = !widget.device.isAdmin;
                        });
                      }
                      break;
                    default:
                      break;
                  }
                },
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Row(
                  children: [
                    const Text("查看"),
                    Switch(
                        value: widget.device.isRead,
                        onChanged: (status) async {
                          var updateStatus =
                          await updateDevice(widget.device.name, {
                            "Type": widget.device.type,
                            "IsAdmin": widget.device.isAdmin,
                            "IsRead": !widget.device.isRead,
                            "IsSend": widget.device.isSend
                          });
                          if (updateStatus) {
                            setState(() {
                              widget.device.isRead = !widget.device.isRead;
                            });
                          }
                        })
                  ],
                ),
                Row(
                  children: [
                    const Text("发送"),
                    Switch(
                        value: widget.device.isSend,
                        onChanged: (status) async {
                          var updateStatus =
                          await updateDevice(widget.device.name, {
                            "Type": widget.device.type,
                            "IsAdmin": widget.device.isAdmin,
                            "IsRead": widget.device.isRead,
                            "IsSend": !widget.device.isSend
                          });
                          if (updateStatus) {
                            setState(() {
                              widget.device.isSend = !widget.device.isSend;
                            });
                          }
                        })
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  deleteDevice(name) async {
    bool? deleteStatus = await deleteDialog(context);
    if (deleteStatus == null) return;

    try {
      await deleteDeviceByName(name);
      widget.deleteDeviceCallback();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception:", ""))));
    }
  }

  Future<bool> updateDevice(String name, Map<String, dynamic> data) async {
    try {
      await updateDeviceByName(widget.device.name, data);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception:", ""))));
      return false;
    }
  }
}

Widget deviceType(int deviceType) {
  Widget widget;
  switch (deviceType) {
    case 0:
      widget = const Icon(Icons.android, color: Colors.green);
      break;
    case 2:
      widget = const Icon(Icons.code, color: Colors.orangeAccent);
      break;
    case 1:
    case 3:
      widget = Icon(Icons.apple, color: Colors.grey.shade500);
      break;
    case 4:
      widget = const Icon(Icons.web, color: Colors.orangeAccent);
      break;
    case 5:
      widget = const Icon(Icons.desktop_windows, color: Colors.blueAccent);
      break;
    case 6:
      widget = const Icon(Icons.webhook);
      break;
    default:
      widget = const Icon(Icons.account_tree, color: Colors.red);
      break;
  }
  return widget;
}
