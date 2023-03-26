import 'package:flutter/material.dart';

class DeviceSimpleCard extends StatelessWidget {
  const DeviceSimpleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                FlutterLogo(),
                Text("设备名称"),
                Spacer(),
                Icon(Icons.settings)
              ],
            ),
            Text("内容数量")
          ],
        ),
      ),
    );
  }
}
