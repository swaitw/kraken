/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


import 'package:flutter/services.dart';
import 'package:kraken/src/module/module_manager.dart';

class ClipBoardModule extends BaseModule {
  @override
  String get name => 'Clipboard';
  ClipBoardModule(ModuleManager? moduleManager) : super(moduleManager);

  static Future<String> readText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) return '';
    return data.text ?? '';
  }

  static Future<void> writeText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void dispose() {}

  @override
  String invoke(String method, dynamic params, callback) {
    if (method == 'readText') {
      ClipBoardModule.readText().then((String value) {
        callback(data: value);
      }).catchError((e, stack) {
        callback(error: '$e\n$stack');
      });
    } else if (method == 'writeText') {
      ClipBoardModule.writeText(params).then((_) {
        callback();
      }).catchError((e, stack) {
        callback(error: '');
      });
    }
    return '';
  }
}
