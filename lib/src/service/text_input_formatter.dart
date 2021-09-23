/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'dart:math';

import 'package:flutter/services.dart';

/// Created by changlei on 2020/05/26
///
/// 输入有效的小数
class DecimalTextInputFormatter extends FilteringTextInputFormatter {
  /// 构造函数
  DecimalTextInputFormatter({
    this.decimalDigits = 2,
    this.maxValue,
  })  : assert(decimalDigits >= 0 || decimalDigits == -1),
        _decimalDigitsRegExp = decimalDigits < 0 ? null : RegExp('\\d+\\.?\\d{0,$decimalDigits}'),
        super.allow(RegExp(decimalDigits == 0 ? r'\d+' : r'\d+\.?\d*'));

  /// 此参数等于0，相当于只能输入整数，等于-1，相当于不限制小数位数，默认等于2
  final int decimalDigits;

  /// 最大值，不设置的时候相当于不限制最大值
  final double? maxValue;
  final RegExp? _decimalDigitsRegExp;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final editingValue = super.formatEditUpdate(oldValue, newValue);
    var newValueText = editingValue.text;
    if (newValueText.isEmpty) {
      return editingValue;
    }
    final pointerIndex = newValueText.indexOf('.');
    final length = newValueText.length;
    final beforePointer = newValueText.substring(0, pointerIndex == -1 ? length : pointerIndex);
    var parsed = beforePointer.replaceFirst(RegExp(r'^0+'), '');
    if (parsed.isEmpty && beforePointer.isNotEmpty) {
      parsed = '0';
    }
    if (_decimalDigitsRegExp != null) {
      newValueText = _decimalDigitsRegExp!.stringMatch(newValueText) ?? '';
    }
    newValueText = newValueText.replaceFirst(beforePointer, parsed);
    var offset = editingValue.selection.baseOffset;
    if (parsed != beforePointer) {
      offset -= beforePointer.length - parsed.length;
    }
    final tryParse = double.tryParse(newValueText);
    if (maxValue != null && tryParse != null && tryParse > maxValue!) {
      return oldValue;
    }
    return editingValue.copyWith(
      text: newValueText,
      selection: TextSelection.collapsed(
        offset: min(offset, newValueText.length),
      ),
    );
  }
}

/// 可以设置最大值和负数，但是没有经过严格测试，请谨慎使用
class SymbolDecimalTextInputFormatter extends FilteringTextInputFormatter {
  /// 构造函数
  SymbolDecimalTextInputFormatter({
    this.decimalDigits = 2,
    this.maxValue,
  })  : assert(decimalDigits >= 0 || decimalDigits == -1),
        _decimalDigitsRegExp = decimalDigits < 0 ? null : RegExp('-?\\d*\\.?\\d{0,$decimalDigits}'),
        super.allow(RegExp(decimalDigits == 0 ? r'-?\d*' : r'-?(\d+\.)?\d*'));

  /// 此参数等于0，相当于只能输入整数，等于-1，相当于不限制小数位数，默认等于2
  final int decimalDigits;

  /// 最大值，不设置的时候相当于不限制最大值
  final double? maxValue;
  final RegExp? _decimalDigitsRegExp;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final editingValue = super.formatEditUpdate(oldValue, newValue);
    var newValueText = editingValue.text;
    if (newValueText.isEmpty) {
      return editingValue;
    }
    final pointerIndex = newValueText.indexOf('.');
    final length = newValueText.length;
    final beforePointer = newValueText.substring(0, pointerIndex == -1 ? length : pointerIndex);
    var parsed = beforePointer.replaceFirst(RegExp(r'^-?0+'), '');
    if (parsed.isEmpty && beforePointer.isNotEmpty) {
      parsed = '0';
    }
    if (!parsed.startsWith('-') && beforePointer.startsWith('-')) {
      parsed = '-' + parsed;
    }
    if (_decimalDigitsRegExp != null) {
      newValueText = _decimalDigitsRegExp!.stringMatch(newValueText) ?? '';
    }
    newValueText = newValueText.replaceFirst(beforePointer, parsed);
    var offset = editingValue.selection.baseOffset;
    if (parsed != beforePointer) {
      offset -= beforePointer.length - parsed.length;
    }
    final tryParse = double.tryParse(newValueText);
    if (maxValue != null && tryParse != null && tryParse > maxValue!) {
      return oldValue;
    }
    return editingValue.copyWith(
      text: newValueText,
      selection: TextSelection.collapsed(
        offset: min(offset, newValueText.length),
      ),
    );
  }
}
