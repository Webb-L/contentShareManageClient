import 'package:content_share_manage/api/content.dart';
import 'package:content_share_manage/components/device/DeviceCard.dart';
import 'package:content_share_manage/components/dialog.dart';
import 'package:flutter/material.dart';

import '../../model/content.dart';

class ContentCard extends StatelessWidget {
  final Content content;
  final VoidCallback deleteContent;

  const ContentCard(this.content, {Key? key, required this.deleteContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var routeResult = await Navigator.pushNamed(context, "/content", arguments: content.id);
        if (routeResult==1) {
          deleteContent();
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Card(
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/devices", arguments: content.deviceName),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {}, icon: deviceType(content.deviceType)),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(content.deviceName),
                    const Spacer(),
                    IconButton(
                        onPressed: () async {
                          try {
                            await deleteContentById(content.id);
                            deleteContent();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(e
                                    .toString()
                                    .replaceFirst("Exception:", ""))));
                          }
                        },
                        icon: const Icon(Icons.delete))
                  ],
                ),
              ),
              Expanded(child: Text(content.text,maxLines: 4))
            ],
          ),
        ),
      ),
    );
  }
}
