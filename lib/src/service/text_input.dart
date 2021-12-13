/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grasp/src/widget/binding.dart';

/// Created by changlei on 2020/7/30.
///
/// 处理自定义键盘输入
class CustomTextInput implements CustomTextInputClient {
  /// 处理自定义键盘输入
  CustomTextInput({this.connection});

  static const _textInput = SystemChannels.textInput;

  /// 接收textField连接键盘的时候
  final CustomTextInputConnection? connection;

  int _client = 0;
  bool _isVisible = false;

  /// Whether this [TestTextInput] is registered with [_textInput].
  ///
  /// Use [register] and [unregister] methods to control this value.
  bool get isRegistered => _textInput.checkMockMethodCallHandler(_handleTextInputCall);

  /// Whether the onscreen keyboard is visible to the user.
  bool get isVisible {
    assert(isRegistered);
    return _isVisible;
  }

  /// Whether there are any active clients listening to text input.
  bool get hasClients {
    assert(isRegistered);
    return _client > 0;
  }

  /// 安装自定义键盘
  void install() {
    _textInput.setMockMethodCallHandler(_handleTextInputCall);
  }

  /// 卸载
  void uninstall() {
    assert(isRegistered);
    _textInput.setMockMethodCallHandler(null);
  }

  /// 重新安装
  void reinstall() {
    _client = 0;
    _isVisible = false;
    install();
  }

  @override
  Future<void> requestExistingInputState() {
    return _handlePlatformMessage('TextInputClient.requestExistingInputState');
  }

  @override
  Future<void> updateEditingStateWithTag(TextEditingValue value) {
    return _handlePlatformMessage('TextInputClient.updateEditingStateWithTag', value.toJSON());
  }

  @override
  Future<void> updateEditingValue(TextEditingValue value) {
    return _handlePlatformMessage('TextInputClient.updateEditingState', value.toJSON());
  }

  @override
  Future<void> performAction(TextInputAction action) {
    return _handlePlatformMessage('TextInputClient.performAction', action.toString());
  }

  @override
  Future<void> performPrivateCommand(String action, Map<String, dynamic> data) {
    return _handlePlatformMessage('TextInputClient.performPrivateCommand', <String, dynamic>{
      'action': action,
      'data': data,
    });
  }

  @override
  Future<void> updateFloatingCursor(RawFloatingCursorPoint point) {
    return _handlePlatformMessage('TextInputClient.updateFloatingCursor', <dynamic>[
      point.state.toString(),
      TextInputDecoder.toTextPointJson(point.state, point.offset),
    ]);
  }

  @override
  Future<void> showAutocorrectionPromptRect(int start, int end) {
    return _handlePlatformMessage('TextInputClient.showAutocorrectionPromptRect', <dynamic>[start, end]);
  }

  @override
  Future<void> connectionClosed() {
    return _handlePlatformMessage('TextInputClient.onConnectionClosed');
  }

  Future<void> _handlePlatformMessage(String name, [dynamic arguments]) async {
    assert(isRegistered);
    assert(_client > 0);
    await _textInput.binaryMessenger.handlePlatformMessage(
      _textInput.name,
      _textInput.codec.encodeMethodCall(_methodCall(name, arguments)),
      null,
    );
  }

  /// ui.window is accessed directly instead of using ServicesBinding.instance.window
  /// because this method might be invoked before any binding is initialized.
  /// This issue was reported in #27541. It is not ideal to statically access
  /// ui.window because the Window may be dependency injected elsewhere with
  /// a different instance. However, static access at this location seems to be
  /// the least bad option.
  static Future<T?> sendPlatformMessage<T>(MethodCall methodCall) async {
    final completer = Completer<ByteData?>();
    // ui.window is accessed directly instead of using ServicesBinding.instance.window
    // because this method might be invoked before any binding is initialized.
    // This issue was reported in #27541. It is not ideal to statically access
    // ui.window because the Window may be dependency injected elsewhere with
    // a different instance. However, static access at this location seems to be
    // the least bad option.
    final codec = _textInput.codec;
    ui.window.sendPlatformMessage(_textInput.name, codec.encodeMethodCall(methodCall), (ByteData? reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    final result = await completer.future;
    if (result == null) {
      return null;
    }
    return codec.decodeEnvelope(result) as T?;
  }

  MethodCall _methodCall(String name, dynamic arguments) {
    final newArguments = <dynamic>[_client];
    if (arguments is List) {
      newArguments.addAll(arguments);
    } else {
      newArguments.add(arguments);
    }
    return MethodCall(name, newArguments);
  }

  Future<dynamic> _handleTextInputCall(MethodCall call) async {
    _onReceiveUserMessage(call);
    switch (call.method) {
      case 'TextInput.setClient':
        _setClient(call.arguments as List<dynamic>);
        break;
      case 'TextInput.hide':
        _hide();
        break;
      case 'TextInput.clearClient':
        _clearClient();
        break;
      case 'TextInput.updateConfig':
        _updateConfig(call.arguments as Map<String, dynamic>);
        break;
      case 'TextInput.setEditingState':
        _setEditingState(call.arguments as Map<String, dynamic>);
        break;
      case 'TextInput.show':
        _show();
        break;
      case 'TextInput.requestAutofill':
        _requestAutofill();
        break;
      case 'TextInput.setEditableSizeAndTransform':
        _setEditableSizeAndTransform(call.arguments as Map<String, dynamic>);
        break;
      case 'TextInput.setMarkedTextRect':
        _setMarkedTextRect(call.arguments as Map<String, dynamic>);
        break;
      case 'TextInput.setCaretRect':
        _setCaretRect(call.arguments as Map<String, dynamic>);
        break;
      case 'TextInput.setStyle':
        _setStyle(call.arguments as Map<String, dynamic>);
        break;
      case 'TextInput.finishAutofillContext':
        _finishAutofillContext(shouldSave: call.arguments as bool);
        break;
    }
  }

  void _setClient(List<dynamic> args) {
    _client = args.first as int;
    final clientArgs = args[1] as Map<String, dynamic>;
    connection?.setClient(_client, TextInputDecoder.toTextInputConfiguration(clientArgs));
  }

  void _show() {
    _isVisible = true;
    connection?.show();
  }

  void _hide() {
    _isVisible = false;
    connection?.hide();
  }

  void _clearClient() {
    _client = 0;
    _isVisible = false;
    connection?.clearClient();
  }

  void _updateConfig(Map<String, dynamic> args) {
    connection?.updateConfig(TextInputDecoder.toTextInputConfiguration(args));
  }

  void _setEditingState(Map<String, dynamic> args) {
    connection?.setEditingState(TextEditingValue.fromJSON(args));
  }

  void _requestAutofill() {
    connection?.requestAutofill();
  }

  void _setEditableSizeAndTransform(Map<String, dynamic> args) {
    final editableBoxSize = Size(args['width'] as double, args['height'] as double);
    final transform = Matrix4.fromList((args['transform'] as List<dynamic>).map((dynamic e) => e as double).toList());
    connection?.setEditableSizeAndTransform(editableBoxSize, transform);
  }

  void _setMarkedTextRect(Map<String, dynamic> args) {
    final size = Size(args['width'] as double, args['height'] as double);
    final offset = Offset(args['x'] as double, args['y'] as double);
    connection?.setComposingRect(offset & size);
  }

  void _setCaretRect(Map<String, dynamic> args) {
    final size = Size(args['width'] as double, args['height'] as double);
    final offset = Offset(args['x'] as double, args['y'] as double);
    connection?.setCaretRect(offset & size);
  }

  void _setStyle(Map<String, dynamic> args) {
    final dynamic fontWeightIndex = args['fontWeightIndex'];
    final dynamic textAlignIndex = args['textAlignIndex'];
    final dynamic textDirectionIndex = args['textDirectionIndex'];
    connection?.setStyle(
      args['fontFamily'] as String,
      args['fontSize'] as double,
      fontWeightIndex == null ? null : FontWeight.values[fontWeightIndex as int],
      textDirectionIndex == null ? null : TextDirection.values[textDirectionIndex as int],
      textAlignIndex == null ? null : TextAlign.values[textAlignIndex as int],
    );
  }

  void _finishAutofillContext({bool shouldSave = true}) {
    connection?.finishAutofillContext(shouldSave: shouldSave);
  }

  void _onReceiveUserMessage(MethodCall call) {
    connection?.onReceiveUserMessage(call);
  }
}

/// 处理自定义键盘输入
class DeltaCustomTextInput extends CustomTextInput implements DeltaCustomTextInputClient {
  @override
  Future<void> updateEditingValueWithDeltas(List<Map<String, dynamic>> textEditingDeltas) {
    return _handlePlatformMessage('TextInputClient.updateEditingStateWithDeltas', <String, dynamic>{
      'deltas': textEditingDeltas,
    });
  }
}

/// An interface to receive information from [TextInput].
///
/// See also:
///
///  * [TextInput.attach]
abstract class CustomTextInputClient {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const CustomTextInputClient();

  /// The requestExistingInputState request needs to be handled regardless of
  /// the client ID, as long as we have a _currentConnection.
  Future<void> requestExistingInputState();

  /// updateEditingStateWithTag
  Future<void> updateEditingStateWithTag(TextEditingValue value);

  /// Requests that this client update its editing state to the given value.
  Future<void> updateEditingValue(TextEditingValue value);

  /// Requests that this client perform the given action.
  Future<void> performAction(TextInputAction action);

  /// Request from the input method that this client perform the given private
  /// command.
  ///
  /// This can be used to provide domain-specific features that are only known
  /// between certain input methods and their clients.
  ///
  /// See also:
  ///   * [https://developer.android.com/reference/android/view/inputmethod/InputConnection#performPrivateCommand(java.lang.String,%20android.os.Bundle)],
  ///     which is the Android documentation for performPrivateCommand, used to
  ///     send a command from the input method.
  ///   * [https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#sendAppPrivateCommand],
  ///     which is the Android documentation for sendAppPrivateCommand, used to
  ///     send a command to the input method.
  Future<void> performPrivateCommand(String action, Map<String, dynamic> data);

  /// Updates the floating cursor position and state.
  Future<void> updateFloatingCursor(RawFloatingCursorPoint point);

  /// Requests that this client display a prompt rectangle for the given text range,
  /// to indicate the range of text that will be changed by a pending autocorrection.
  ///
  /// This method will only be called on iOS.
  Future<void> showAutocorrectionPromptRect(int start, int end);

  /// Platform notified framework of closed connection.
  ///
  /// [TextInputClient] should cleanup its connection and finalize editing.
  Future<void> connectionClosed();
}

/// An interface to receive granular information from [TextInput].
///
/// See also:
///
///  * [TextInput.attach]
///  * [TextInputConfiguration], to opt-in to receive [TextEditingDelta]'s from
///    the platforms [TextInput] you must set [TextInputConfiguration.enableDeltaModel]
///    to true.
abstract class DeltaCustomTextInputClient extends CustomTextInputClient {
  /// Requests that this client update its editing state by applying the deltas
  /// received from the engine.
  ///
  /// The list of [TextEditingDelta]'s are treated as changes that will be applied
  /// to the client's editing state. A change is any mutation to the raw text
  /// value, or any updates to the selection and/or composing region.
  ///
  /// Here is an example of what implementation of this method could look like:
  /// {@tool snippet}
  /// @override
  /// void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
  ///   TextEditingValue newValue = _previousValue;
  ///   for (final TextEditingDelta delta in textEditingDeltas) {
  ///     newValue = delta.apply(newValue);
  ///   }
  ///   _localValue = newValue;
  /// }
  /// {@end-tool}
  Future<void> updateEditingValueWithDeltas(List<Map<String, dynamic>> textEditingDeltas);
}

/// 详情请阅读[TextInput]源码
abstract class CustomTextInputConnection {
  /// This method actually notifies the embedding of the client. It is utilized
  /// by [attach] and by [_handleTextInputInvocation] for the
  /// `TextInputClient.requestExistingInputState` method.
  void setClient(int id, TextInputConfiguration configuration);

  /// Requests that the text input control become visible.
  void show();

  /// Stop interacting with the text input control.
  ///
  /// After calling this method, the text input control might disappear if no
  /// other client attaches to it within this animation frame.
  void hide();

  /// Stop interacting with the text input control.
  ///
  /// After calling this method, the text input control might disappear if no
  /// other client attaches to it within this animation frame.
  void clearClient();

  /// Requests that the text input control update itself according to the new
  /// [TextInputConfiguration].
  void updateConfig(TextInputConfiguration configuration);

  /// 详情请阅读[TextInput]源码
  void setEditingState(TextEditingValue value);

  /// Requests the platform autofill UI to appear.
  ///
  /// The call has no effect unless the currently attached client supports
  /// autofill, and the platform has a standalone autofill UI (for example, this
  /// call has no effect on iOS since its autofill UI is part of the software
  /// keyboard).
  void requestAutofill();

  /// Send the size and transform of the editable text to engine.
  ///
  /// The values are sent as platform messages so they can be used on web for
  /// example to correctly position and size the html input field.
  ///
  /// 1. [editableBoxSize]: size of the render editable box.
  ///
  /// 2. [transform]: a matrix that maps the local paint coordinate system
  ///                 to the [PipelineOwner.rootNode].
  void setEditableSizeAndTransform(Size editableBoxSize, Matrix4 transform);

  /// Send the smallest rect that covers the text in the client that's currently
  /// being composed.
  ///
  /// The given `rect` can not be null. If any of the 4 coordinates of the given
  /// [Rect] is not finite, a [Rect] of size (-1, -1) will be sent instead.
  ///
  /// This information is used for positioning the IME candidates menu on each
  /// platform.
  void setComposingRect(Rect rect);

  /// Sends the coordinates of caret rect. This is used on macOS for positioning
  /// the accent selection menu.
  void setCaretRect(Rect rect);

  /// Send text styling information.
  ///
  /// This information is used by the Flutter Web Engine to change the style
  /// of the hidden native input's content. Hence, the content size will match
  /// to the size of the editable widget's content.
  void setStyle(
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextDirection? textDirection,
    TextAlign? textAlign,
  );

  /// Finishes the current autofill context, and potentially saves the user
  /// input for future use if `shouldSave` is true.
  ///
  /// Typically, this method should be called when the user has finalized their
  /// input. For example, in a [Form], it's typically done immediately before or
  /// after its content is submitted.
  void finishAutofillContext({bool shouldSave = true});

  /// 接收到终端信息，顾名思义就是从TextField发来的消息
  void onReceiveUserMessage(MethodCall call);
}

/// [TextInput]相关数据解析器
class TextInputDecoder {
  const TextInputDecoder._();

  /// json转[TextInputConfiguration]
  static TextInputConfiguration toTextInputConfiguration(Map<String, dynamic> clientArgs) {
    return TextInputConfiguration(
      inputType: _toTextInputType(clientArgs['inputType'] as Map<String, dynamic>),
      readOnly: clientArgs['readOnly'] as bool,
      obscureText: clientArgs['obscureText'] as bool,
      autocorrect: clientArgs['autocorrect'] as bool,
      smartDashesType: SmartDashesType.values[int.tryParse(clientArgs['smartDashesType'] as String)!],
      smartQuotesType: SmartQuotesType.values[int.tryParse(clientArgs['smartQuotesType'] as String)!],
      enableSuggestions: clientArgs['enableSuggestions'] as bool,
      actionLabel: clientArgs['actionLabel'] as String,
      inputAction: _toTextInputAction(clientArgs['inputAction'] as String),
      textCapitalization: _toTextCapitalization(clientArgs['textCapitalization'] as String),
      keyboardAppearance: _toBrightness(clientArgs['keyboardAppearance'] as String),
      enableIMEPersonalizedLearning: clientArgs['enableIMEPersonalizedLearning'] as bool,
      autofillConfiguration: _toAutofillConfiguration(clientArgs['autofill'] as Map<String, dynamic>?),
      enableDeltaModel: clientArgs['enableDeltaModel'] as bool,
    );
  }

  static TextInputType _toTextInputType(Map<String, dynamic> args) {
    final name = args['name'] as String;
    switch (name) {
      case 'TextInputType.text':
        return TextInputType.text;
      case 'TextInputType.multiline':
        return TextInputType.multiline;
      case 'TextInputType.number':
        return TextInputType.numberWithOptions(
          signed: args['signed'] as bool,
          decimal: args['decimal'] as bool,
        );
      case 'TextInputType.phone':
        return TextInputType.phone;
      case 'TextInputType.datetime':
        return TextInputType.datetime;
      case 'TextInputType.emailAddress':
        return TextInputType.emailAddress;
      case 'TextInputType.url':
        return TextInputType.url;
      case 'TextInputType.visiblePassword':
        return TextInputType.visiblePassword;
      case 'TextInputType.name':
        return TextInputType.name;
      case 'TextInputType.address':
        return TextInputType.streetAddress;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown text input type: $args')]);
  }

  static AutofillConfiguration _toAutofillConfiguration(Map<String, dynamic>? args) {
    if (args == null) {
      return AutofillConfiguration.disabled;
    }
    final editingValueJson = args['editingValue'] as Map<String, dynamic>;
    return AutofillConfiguration(
      uniqueIdentifier: args['uniqueIdentifier'] as String,
      autofillHints: (args['hints'] as List<dynamic>).cast<String>(),
      currentEditingValue: TextEditingValue.fromJSON(editingValueJson),
      hintText: args['hintText'] as String?,
    );
  }

  static Brightness _toBrightness(String name) {
    switch (name) {
      case 'Brightness.dark':
        return Brightness.dark;
      case 'Brightness.light':
        return Brightness.light;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown brightness: $name')]);
  }

  static TextCapitalization _toTextCapitalization(String name) {
    switch (name) {
      case 'TextCapitalization.none':
        return TextCapitalization.none;
      case 'TextCapitalization.characters':
        return TextCapitalization.characters;
      case 'TextCapitalization.sentences':
        return TextCapitalization.sentences;
      case 'TextCapitalization.words':
        return TextCapitalization.words;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown text capitalization: $name')]);
  }

  static TextInputAction _toTextInputAction(String action) {
    switch (action) {
      case 'TextInputAction.none':
        return TextInputAction.none;
      case 'TextInputAction.unspecified':
        return TextInputAction.unspecified;
      case 'TextInputAction.go':
        return TextInputAction.go;
      case 'TextInputAction.search':
        return TextInputAction.search;
      case 'TextInputAction.send':
        return TextInputAction.send;
      case 'TextInputAction.next':
        return TextInputAction.next;
      case 'TextInputAction.previous':
        return TextInputAction.previous;
      case 'TextInputAction.continue_action':
        return TextInputAction.continueAction;
      case 'TextInputAction.join':
        return TextInputAction.join;
      case 'TextInputAction.route':
        return TextInputAction.route;
      case 'TextInputAction.emergencyCall':
        return TextInputAction.emergencyCall;
      case 'TextInputAction.done':
        return TextInputAction.done;
      case 'TextInputAction.newline':
        return TextInputAction.newline;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown text input action: $action')]);
  }

  /// [FloatingCursorDragState]和[Offset]转json
  static Map<String, dynamic> toTextPointJson(FloatingCursorDragState? state, Offset? encoded) {
    return state == FloatingCursorDragState.Update
        ? <String, dynamic>{'X': encoded?.dx, 'Y': encoded?.dy}
        : <String, dynamic>{'X': 0, 'Y': 0};
  }
}
