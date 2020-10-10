/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

bool isMobileNo(String mobile) {
  if (TextUtils.isEmpty(mobile) || mobile.length != 11) {
    return false;
  }
  final RegExp exp = RegExp(
    '^((\\d{3})|(\\d{3}-))?1[3-9][0-9]\\d{8}\$',
  );
  return exp.hasMatch(mobile);
}

bool isHidenMobileNo(String mobile) {
  if (TextUtils.isEmpty(mobile) || mobile.length != 11) {
    return false;
  }
  final RegExp exp = RegExp(
    '^((\\d{3})|(\\d{3}-))?1[3-9][0-9](\\*{4}|\\d{4})\\d{4}\$',
  );
  return exp.hasMatch(mobile);
}

bool isLandlineNumber(String mobile) {
  if (TextUtils.isEmpty(mobile) || mobile.length < 11) {
    return false;
  }
  final RegExp exp = RegExp(
    '^[0](([1-9]\\d-[2-8]\\d{7})|([1-9]\\d{2}-[2-8]\\d{6}))\$',
  );
  return exp.hasMatch(mobile);
}

bool canCallPhone(String mobile) {
  return isMobileNo(mobile) || isLandlineNumber(mobile);
}

bool isNetPath(String path) {
  final RegExp regExp = RegExp(r'^((ht|f)tps?):\/\/[\w\-]+(\.[\w\-]+)+([\w\-.,@?^=%&:\/~+#]*[\w\-@?^=%&\/~+#])?');
  return path != null && regExp.hasMatch(path);
}

TextInputFormatter mobileFormatter({bool canInputHidenMobile = false}) {
  return canInputHidenMobile
      ? FilteringTextInputFormatter.allow(RegExp(
          r'\d|\*',
        ))
      : FilteringTextInputFormatter.digitsOnly;
}

Future<bool> callPhone(BuildContext context, String phone) async {
  final String url = 'tel:$phone';
  if (TextUtils.isEmpty(phone) || await canLaunch(url)) {
    return await launch(url);
  } else {
    throw '电话号码出现异常';
  }
}
