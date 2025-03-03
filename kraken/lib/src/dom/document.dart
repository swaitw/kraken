/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

class Document extends Node {
  final HTMLElement documentElement;

  Document(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager, this.documentElement)
      : super(NodeType.DOCUMENT_NODE, targetId, nativeEventTarget, elementManager);

  void _handleEvent(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
  }

  @override
  String get nodeName => '#document';

  @override
  void addEvent(String eventType) {
    super.addEvent(eventType);
    documentElement.addEventListener(eventType, _handleEvent);
  }

  @override
  RenderObject? get renderer => throw FlutterError('Document did\'t have renderObject.');

  @override
  handleJSCall(String method, List argv) {
  }
}
