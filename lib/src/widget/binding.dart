/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */
library binding;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

part 'package:flutter_grasp/src/service/default_binary_messenger.dart';

/// Created by changlei on 2021/9/13.
///
/// Interface for classes that register with the Widgets layer binding.
class GraspWidgetsFlutterBinding extends WidgetsFlutterBinding {
  /// Returns an instance of the [WidgetsBinding], creating and
  /// initializing it if necessary. If one is created, it will be a
  /// [WidgetsFlutterBinding]. If one was previously initialized, then
  /// it will at least implement [WidgetsBinding].
  ///
  /// You only need to call this method if you need the binding to be
  /// initialized before calling [runApp].
  ///
  /// In the `flutter_test` framework, [testWidgets] initializes the
  /// binding instance to a [TestWidgetsFlutterBinding], not a
  /// [WidgetsFlutterBinding].
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      GraspWidgetsFlutterBinding();
    }
    return WidgetsBinding.instance!;
  }

  @override
  @protected
  BinaryMessenger createBinaryMessenger() {
    return _DefaultBinaryMessenger._(super.createBinaryMessenger());
  }
}

/// Inflate the given widget and attach it to the screen.
///
/// The widget is given constraints during layout that force it to fill the
/// entire screen. If you wish to align your widget to one side of the screen
/// (e.g., the top), consider using the [Align] widget. If you wish to center
/// your widget, you can also use the [Center] widget.
///
/// Calling [runApp] again will detach the previous root widget from the screen
/// and attach the given widget in its place. The new widget tree is compared
/// against the previous widget tree and any differences are applied to the
/// underlying render tree, similar to what happens when a [StatefulWidget]
/// rebuilds after calling [State.setState].
///
/// Initializes the binding using [WidgetsFlutterBinding] if necessary.
///
/// See also:
///
///  * [WidgetsBinding.attachRootWidget], which creates the root widget for the
///    widget hierarchy.
///  * [RenderObjectToWidgetAdapter.attachToRenderTree], which creates the root
///    element for the element hierarchy.
///  * [WidgetsBinding.handleBeginFrame], which pumps the widget pipeline to
///    ensure the widget, element, and render trees are all built.
void runGraspApp(Widget app) {
  GraspWidgetsFlutterBinding.ensureInitialized()
    // ignore: invalid_use_of_protected_member
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}
