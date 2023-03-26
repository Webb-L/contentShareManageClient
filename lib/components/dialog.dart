import 'package:flutter/material.dart';

Future<bool?> deleteDialog(context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return baseDialog(
          title: "删除提示",
          content: "你确定需要删除吗?",
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("取消")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("确定")),
          ],
        );
      });
}

Widget baseDialog({required String title, required String content, required List<TextButton> actions}) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: actions,
  );
}
