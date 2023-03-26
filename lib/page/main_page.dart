import 'dart:ui';

import 'package:content_share_manage/api/content.dart';
import 'package:content_share_manage/components/content/ContentCard.dart';
import 'package:content_share_manage/model/content.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int start = 0;
  int count = 30;
  bool isFinishLoading = false;
  List<Content> contents = [];
  final ScrollController _scrollController = ScrollController();
  bool firstOpen = true;


  final TextEditingController _sendController = TextEditingController();

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
                (await queryContentByLimit(start * count, (start + 1) * 30));
            setState(() {
              isFinishLoading = tempList.isEmpty;
              contents.addAll(tempList);
            });
          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString().replaceFirst("Exception:", ""))));
          }
        })();
      }
    });

    (() async {
      try {
        contents.clear();
        var tempList =
            (await queryContentByLimit(start * 30, (start + 1) * 30));
        firstOpen = false;
        setState(() {
          contents.addAll(tempList);
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
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/devices");
            },
            icon: const Icon(Icons.devices)),
        title: const Text("最新的内容"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: RefreshIndicator(
          onRefresh: _refreshData,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            }),
            child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridItemWidth < 1 ? 1 : gridItemWidth,
                    mainAxisExtent: 160),
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: contents.length + 1,
                itemBuilder: (context, index) {
                  if (index == contents.length) {
                    if (isFinishLoading ||
                        (firstOpen && contents.isEmpty) ||
                        contents.length <= 30) {
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
                  return ContentCard(
                    contents.elementAt(index),
                    deleteContent: () {
                      setState(() {
                        contents.removeAt(index);
                      });
                    },
                  );
                }),
          )),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '发送的内容',
                      ),
                      minLines: 1,
                      maxLines: 100,
                      controller: _sendController,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("取消")),
                      TextButton(
                          onPressed: () async {
                            try {
                              await sendContent(_sendController.text)
                                  .then((content) {
                                setState(() {
                                  contents.insert(0, content);
                                });
                              });
                              _sendController.text = "";
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(e
                                          .toString()
                                          .replaceFirst("Exception:", ""))));
                            }
                            Navigator.pop(context);
                          },
                          child: const Text("确定"))
                    ],
                  );
                });
          },
          icon: const Icon(Icons.send),
          label: const Text("发送")),
    );
  }

  Future<void> _refreshData() async {
    isFinishLoading = false;
    start = 0;

    try {
      contents.clear();
      var tempList = (await queryContentByLimit(start * 30, (start + 1) * 30));
      setState(() {
        (() async {
          contents.addAll(tempList);
        })();
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception:", ""))));
    }
  }
}
