/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Created by changlei on 2020/7/30.
///
/// 处理自定义键盘输入
class CustomTextInput implements CustomTextInputClient {
  /// 处理自定义键盘输入
  CustomTextInput({this.connection});

  static const MethodChannel _textInput = SystemChannels.textInput;

  /// 接收textField连接键盘的时候
  final CustomTextInputConnection connection;

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
    return _sendPlatformMessage('TextInputClient.requestExistingInputState');
  }

  @override
  Future<void> updateEditingStateWithTag(TextEditingValue value) {
    return _sendPlatformMessage('TextInputClient.updateEditingStateWithTag', value.toJSON());
  }

  @override
  Future<void> updateEditingValue(TextEditingValue value) {
    return _sendPlatformMessage('TextInputClient.updateEditingState', value.toJSON());
  }

  @override
  Future<void> performAction(TextInputAction action) {
    return _sendPlatformMessage('TextInputClient.performAction', action.toString());
  }

  @override
  Future<void> updateFloatingCursor(RawFloatingCursorPoint point) {
    return _sendPlatformMessage('TextInputClient.updateFloatingCursor', <dynamic>[
      point.state.toString(),
      _toTextPointJson(point.state, point.offset),
    ]);
  }

  @override
  Future<void> showAutocorrectionPromptRect(int start, int end) {
    return _sendPlatformMessage('TextInputClient.showAutocorrectionPromptRect', <dynamic>[start, end]);
  }

  @override
  Future<void> connectionClosed() {
    return _sendPlatformMessage('TextInputClient.onConnectionClosed');
  }

  Future<void> _sendPlatformMessage(String name, [dynamic arguments]) async {
    assert(isRegistered);
    assert(_client > 0);
    await _textInput.binaryMessenger.handlePlatformMessage(
      _textInput.name,
      _textInput.codec.encodeMethodCall(_methodCall(name, arguments)),
      null,
    );
  }

  MethodCall _methodCall(String name, dynamic arguments) {
    final List<dynamic> newArguments = <dynamic>[_client];
    if (arguments is List) {
      newArguments.addAll(arguments);
    } else {
      newArguments.add(arguments);
    }
    return MethodCall(name, newArguments);
  }

  Future<dynamic> _handleTextInputCall(MethodCall call) async {
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
      case 'TextInput.setStyle':
        _setStyle(call.arguments as Map<String, dynamic>);
        break;
    }
  }

  void _setClient(List<dynamic> args) {
    _client = args.first as int;
    final Map<String, dynamic> clientArgs = args[1] as Map<String, dynamic>;
    connection?.setClient(_client, _toTextInputConfiguration(clientArgs));
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

  void _setEditingState(Map<String, dynamic> args) {
    connection?.setEditingState(TextEditingValue.fromJSON(args));
  }

  void _requestAutofill() {
    connection?.requestAutofill();
  }

  void _setEditableSizeAndTransform(Map<String, dynamic> args) {
    final Size editableBoxSize = Size(args['width'] as double, args['height'] as double);
    final Matrix4 transform =
        Matrix4.fromList((args['transform'] as List<dynamic>).map((dynamic e) => e as double).toList());
    connection?.setEditableSizeAndTransform(editableBoxSize, transform);
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

  /// Send text styling information.
  ///
  /// This information is used by the Flutter Web Engine to change the style
  /// of the hidden native input's content. Hence, the content size will match
  /// to the size of the editable widget's content.
  void setStyle(
    String fontFamily,
    double fontSize,
    FontWeight fontWeight,
    TextDirection textDirection,
    TextAlign textAlign,
  );
}

TextInputConfiguration _toTextInputConfiguration(Map<String, dynamic> clientArgs) {
  return TextInputConfiguration(
    inputType: _toTextInputType(clientArgs['inputType'] as Map<String, dynamic>),
    obscureText: clientArgs['obscureText'] as bool,
    autocorrect: clientArgs['autocorrect'] as bool,
    smartDashesType: SmartDashesType.values[int.tryParse(clientArgs['smartDashesType'] as String)],
    smartQuotesType: SmartQuotesType.values[int.tryParse(clientArgs['smartQuotesType'] as String)],
    enableSuggestions: clientArgs['enableSuggestions'] as bool,
    actionLabel: clientArgs['actionLabel'] as String,
    inputAction: _toTextInputAction(clientArgs['inputAction'] as String),
    textCapitalization: _toTextCapitalization(clientArgs['textCapitalization'] as String),
    keyboardAppearance: _toBrightness(clientArgs['keyboardAppearance'] as String),
    autofillConfiguration: _toAutofillConfiguration(clientArgs['autofill'] as Map<String, dynamic>),
  );
}

TextInputType _toTextInputType(Map<String, dynamic> args) {
  final String name = args['name'] as String;
  switch (name) {
    case 'TextInputType.text':
      return TextInputType.text;
      break;
    case 'TextInputType.multiline':
      return TextInputType.multiline;
      break;
    case 'TextInputType.number':
      return TextInputType.numberWithOptions(
        signed: args['signed'] as bool,
        decimal: args['decimal'] as bool,
      );
      break;
    case 'TextInputType.phone':
      return TextInputType.phone;
      break;
    case 'TextInputType.datetime':
      return TextInputType.datetime;
      break;
    case 'TextInputType.emailAddress':
      return TextInputType.emailAddress;
      break;
    case 'TextInputType.url':
      return TextInputType.url;
      break;
    case 'TextInputType.visiblePassword':
      return TextInputType.visiblePassword;
      break;
    case 'TextInputType.name':
      return TextInputType.name;
      break;
    case 'TextInputType.address':
      return TextInputType.streetAddress;
      break;
  }
  throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown text input type: $args')]);
}

AutofillConfiguration _toAutofillConfiguration(Map<String, dynamic> args) {
  if (args == null) {
    return null;
  }
  final Map<String, dynamic> editingValueJson = args['editingValue'] as Map<String, dynamic>;
  return AutofillConfiguration(
    uniqueIdentifier: args['uniqueIdentifier'] as String,
    autofillHints: args['hints'] as List<String>,
    currentEditingValue: editingValueJson == null ? null : TextEditingValue.fromJSON(editingValueJson),
  );
}

Brightness _toBrightness(String name) {
  switch (name) {
    case 'Brightness.dark':
      return Brightness.dark;
      break;
    case 'Brightness.light':
      return Brightness.light;
      break;
  }
  throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown brightness: $name')]);
}

TextCapitalization _toTextCapitalization(String name) {
  switch (name) {
    case 'TextCapitalization.none':
      return TextCapitalization.none;
      break;
    case 'TextCapitalization.characters':
      return TextCapitalization.characters;
      break;
    case 'TextCapitalization.sentences':
      return TextCapitalization.sentences;
      break;
    case 'TextCapitalization.words':
      return TextCapitalization.words;
      break;
  }
  throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Unknown text capitalization: $name')]);
}

TextInputAction _toTextInputAction(String action) {
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

Map<String, dynamic> _toTextPointJson(FloatingCursorDragState state, Offset encoded) {
  assert(state != null, 'You must provide a state to set a new editing point.');
  assert(encoded.dx != null, 'You must provide a value for the horizontal location of the floating cursor.');
  assert(encoded.dy != null, 'You must provide a value for the vertical location of the floating cursor.');
  return state == FloatingCursorDragState.Update
      ? <String, dynamic>{'X': encoded.dx, 'Y': encoded.dy}
      : <String, dynamic>{'X': 0, 'Y': 0};
}
