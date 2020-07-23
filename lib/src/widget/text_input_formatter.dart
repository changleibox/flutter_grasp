/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'dart:math';

import 'package:flutter/services.dart';

/// Created by changlei on 2020/05/26
///
/// 输入有效的小数
class DecimalTextInputFormatter extends FilteringTextInputFormatter {
  DecimalTextInputFormatter({
    this.decimalDigits = 2,
  })  : assert(decimalDigits != null && decimalDigits >= 0 || decimalDigits == -1),
        _decimalDigitsRegExp = decimalDigits < 0 ? null : RegExp('\\d+\\.?\\d{0,$decimalDigits}'),
        super.allow(RegExp(decimalDigits == 0 ? r'\d+' : r'\d+\.?\d*'));

  /// 此参数等于0，相当于只能输入整数，等于-1，相当于不限制小数位数，默认等于2
  final int decimalDigits;
  final RegExp _decimalDigitsRegExp;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final TextEditingValue editingValue = super.formatEditUpdate(oldValue, newValue);
    String newValueText = editingValue.text;
    if (newValueText.isEmpty) {
      return editingValue;
    }
    final int pointerIndex = newValueText.indexOf('.');
    final int length = newValueText.length;
    final String beforePointer = newValueText.substring(0, pointerIndex == -1 ? length : pointerIndex);
    final String parsed = int.tryParse(beforePointer)?.toString();
    if (parsed == null) {
      return oldValue;
    }
    if (_decimalDigitsRegExp != null) {
      newValueText = _decimalDigitsRegExp.stringMatch(newValueText);
    }
    newValueText = newValueText.replaceFirst(beforePointer, parsed);
    int offset = editingValue.selection.baseOffset;
    if (parsed != beforePointer) {
      offset -= beforePointer.length - parsed.length;
    }
    return editingValue.copyWith(
      text: newValueText,
      selection: TextSelection.collapsed(
        offset: min(offset, newValueText.length),
      ),
    );
  }
}