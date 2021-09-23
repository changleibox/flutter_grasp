/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

/// Created by changlei on 2020/8/3.
///
/// 常用正则表达式

/// 特殊字符正则表达式
const String specialCharacterRegular = r'[@#￥¥%……&*（）]';

/// url正则表达式
/// (1)、地址必须以http/https/ftp/ftps开头；
/// (2)、地址不能包含双字节符号或非链接特殊字符。
const String urlRegular = r'^((ht|f)tps?):\/\/[\w\-]+(\.[\w\-]+)+([\w\-.,@?^=%&:\/~+#]*[\w\-@?^=%&\/~+#])?';

/// 手机号码正则表达式
const String mobileRegular = r'((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\d{8}';

/// 座机号码正则表达式
const String landlineRegular = r'0\d{2,3}-\d{7,8}|\(?0\d{2,3}[)-]?\d{7,8}|\(?0\d{2,3}[)-]*\d{7,8}';

/// 电话号码和座机正则表达式
const String phoneRegular = '($mobileRegular)|($landlineRegular)';
