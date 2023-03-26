import 'dart:ui';

import 'package:content_share_manage/api/content.dart';
import 'package:content_share_manage/components/dialog.dart';
import 'package:content_share_manage/model/content.dart';
import 'package:flutter/material.dart';

class ContentInfoPage extends StatefulWidget {
  final String id;

  const ContentInfoPage({Key? key, required this.id}) : super(key: key);

  @override
  State<ContentInfoPage> createState() => _ContentInfoPageState();
}

class _ContentInfoPageState extends State<ContentInfoPage> {
  Content? content;
  final TextEditingController _editController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    (() async {
      try {
        var value = await queryContentById(widget.id);
        setState(() {
          content = value;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst("Exception:", ""))));
      }
    })();
    super.initState();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("详情"),
        actions: [
          IconButton(
              onPressed: () async {
                var deleteStatus = await deleteDialog(context);
                if (deleteStatus == null || !deleteStatus) return;

                try {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(await deleteContentById(content!.id))));
                  Navigator.of(context).pop(1);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(e.toString().replaceFirst("Exception:", ""))));
                }
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () async {
                _editController.text = content!.text;
                bool updateStatus = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Form(
                            key: _formKey,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '编辑内容',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "不能为空!";
                                }
                                return null;
                              },
                              minLines: 1,
                              maxLines: 100,
                              controller: _editController,
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text("取消")),
                            TextButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  Navigator.pop(context, true);
                                },
                                child: const Text("确定"))
                          ],
                        ));

                if (!updateStatus) return;

                setState(() {
                  content!.text = _editController.text;
                });
                var result = await editContentById(content!);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result)));
              },
              icon: const Icon(Icons.edit)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            var value = await queryContentById(widget.id);
            setState(() {
              content = value;
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString().replaceFirst("Exception:", ""))));
          }
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),
          child: SingleChildScrollView(
              child: SizedBox(
            width: size.width,
            child: content == null
                ? const LinearProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SelectableText(content!.text),
                  ),
          )),
        ),
      ),
    );
  }
}
