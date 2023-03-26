import 'dart:io';

import 'package:content_share_manage/api/index.dart';
import 'package:content_share_manage/page/content/content_info_page.dart';
import 'package:content_share_manage/page/device/device_manage_page.dart';
import 'package:content_share_manage/page/init_page.dart';
import 'package:content_share_manage/page/main_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

MyHttpClient httpClient = MyHttpClient();

void main() {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle('内容分享管理');
      setWindowMinSize(const Size(300, 500));
    }
  }

  runApp(const MyApp());

  httpClient.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '内容分享管理',
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme:
          ThemeData(colorScheme: const ColorScheme.dark(), useMaterial3: true),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        var routes = <String, WidgetBuilder>{
          "/": (context) => const InitPage(),
          "/home": (context) => const MainPage(),
          "/devices": (context) => const DeviceManagePage(),
          "/content": (context) => ContentInfoPage(
                id: settings.arguments.toString(),
              ),
        };

        WidgetBuilder builder = routes[settings.name]!;
        return MaterialPageRoute(builder: (context) => builder(context));
      },
    );
  }
}
