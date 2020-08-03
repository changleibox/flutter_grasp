/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:flutter_test/flutter_test.dart';

/// Created by changlei on 2020/5/27.
///
/// 自定义TextInputFormatter测试
void main() {
  test('DecimalTextInputFormatter测试', () {
    final DecimalTextInputFormatter formatter = DecimalTextInputFormatter(decimalDigits: 2);
    TextEditingValue oldValue = TextEditingValue.empty;
    TextEditingValue newValue = TextEditingValue.empty;

    // 测试在不输入的情况下，或者清空的情况下，返回空
    oldValue = newValue;
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '');
    expect(newValue.selection, const TextSelection.collapsed(offset: -1));

    // 测试不允许单独输入一个.
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '.',
      selection: const TextSelection.collapsed(offset: -1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '');
    expect(newValue.selection, const TextSelection.collapsed(offset: -1));

    // 测试在输入无效字符的时候，返回空
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: 'gffgf',
      selection: const TextSelection.collapsed(offset: -1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '');
    expect(newValue.selection, TextSelection.collapsed(offset: -1));

    // 测试在输入无效字符加数字的时候，返回字符串里的数字
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: 'gffgf90',
      selection: const TextSelection.collapsed(offset: -1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '90');
    expect(newValue.selection, const TextSelection.collapsed(offset: -1));

    // 测试在输入无效字符穿插数字的时候，返回字符串里的数字
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '90gffgf90',
      selection: const TextSelection.collapsed(offset: -1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '9090');
    expect(newValue.selection, const TextSelection.collapsed(offset: -1));

    // 测试在输入一个0的时候，返回一个0
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '0',
      selection: const TextSelection.collapsed(offset: 1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '0');
    expect(newValue.selection, const TextSelection.collapsed(offset: 1));

    // 测试如果原来只输入一个0，然后再输入一个非0的数，这时候，应该返回这个数
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '8',
      selection: const TextSelection.collapsed(offset: 1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '8');
    expect(newValue.selection, const TextSelection.collapsed(offset: 1));

    // 测试在输入0.的时候，返回0.
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '0.',
      selection: const TextSelection.collapsed(offset: 2),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '0.');
    expect(newValue.selection, const TextSelection.collapsed(offset: 2));

    // 测试在输入0.00的时候，返回0.00
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '0.00',
      selection: const TextSelection.collapsed(offset: 4),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '0.00');
    expect(newValue.selection, const TextSelection.collapsed(offset: 4));

    // 测试在输入超过两位小数位的时候，应该返回两位小数位
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '0.001',
      selection: const TextSelection.collapsed(offset: 4),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '0.00');
    expect(newValue.selection, const TextSelection.collapsed(offset: 4));

    // 测试在整数位有多余无效0的时候，应该返回只有一个0，切光标还在原来位置
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '00.001',
      selection: const TextSelection.collapsed(offset: 1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '0.00');
    expect(newValue.selection, const TextSelection.collapsed(offset: 0));

    // 测试不能输入超过1个.
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '00..00',
      selection: const TextSelection.collapsed(offset: 3),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '0.00');
    expect(newValue.selection, const TextSelection.collapsed(offset: 2));

    // 测试正常输入
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '808.99',
      selection: const TextSelection.collapsed(offset: -1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '808.99');
    expect(newValue.selection, const TextSelection.collapsed(offset: -1));

    // 测试在删除正常输入的数以后，在字符串前面出现无效的0，这时候应该返回去掉无效0以后的数，光标移动最前面
    oldValue = newValue;
    newValue = newValue.copyWith(
      text: '08.99',
      selection: const TextSelection.collapsed(offset: 1),
    );
    newValue = formatter.formatEditUpdate(oldValue, newValue);
    expect(newValue.text, '8.99');
    expect(newValue.selection, const TextSelection.collapsed(offset: 0));
  });
}
