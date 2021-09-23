/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:url_launcher/url_launcher.dart';

/// Created by changlei on 2020/8/26.

/// 验证手机号
bool isMobileNo(String mobile) {
  if (TextUtils.isEmpty(mobile) || mobile.length != 11) {
    return false;
  }
  final exp = RegExp(
    '^((\\d{3})|(\\d{3}-))?1[3-9][0-9]\\d{8}\$',
  );
  return exp.hasMatch(mobile);
}

/// 验证是否为中间四位是*的手机号
bool isHidenMobileNo(String mobile) {
  if (TextUtils.isEmpty(mobile) || mobile.length != 11) {
    return false;
  }
  final exp = RegExp(
    '^((\\d{3})|(\\d{3}-))?1[3-9][0-9](\\*{4}|\\d{4})\\d{4}\$',
  );
  return exp.hasMatch(mobile);
}

/// 验证座机号
bool isLandlineNumber(String mobile) {
  if (TextUtils.isEmpty(mobile) || mobile.length < 11) {
    return false;
  }
  final exp = RegExp(
    '^[0](([1-9]\\d-[2-8]\\d{7})|([1-9]\\d{2}-[2-8]\\d{6}))\$',
  );
  return exp.hasMatch(mobile);
}

/// 判断是否可以拨打电话，换句话说就是是不是手机号或者座机号
bool canCallPhone(String mobile) {
  return isMobileNo(mobile) || isLandlineNumber(mobile);
}

/// 验证[path]是不是网址
bool isNetPath(String? path) {
  final regExp = RegExp(r'^((ht|f)tps?):\/\/[\w\-]+(\.[\w\-]+)+([\w\-.,@?^=%&:\/~+#]*[\w\-@?^=%&\/~+#])?');
  return path != null && regExp.hasMatch(path);
}

/// 手机号[TextInputFormatter]
TextInputFormatter mobileFormatter({bool canInputHidenMobile = false}) {
  return canInputHidenMobile
      ? FilteringTextInputFormatter.allow(RegExp(
          r'\d|\*',
        ))
      : FilteringTextInputFormatter.digitsOnly;
}

/// 拨打电话
Future<bool> callPhone(BuildContext context, String phone) async {
  final url = 'tel:$phone';
  if (TextUtils.isEmpty(phone) || await canLaunch(url)) {
    return await launch(url);
  } else {
    throw '电话号码出现异常';
  }
}
