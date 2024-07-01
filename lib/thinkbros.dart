library thinkbros;

import 'package:flutter/services.dart';

class Bros {
  static Future<bool> print({
    int? printCount = 1,
    String? uri = 'GS1_gs25.gsretail.com/01/08808244101109/',
    String? goodsName = '제주삼다수 그린 0.5L',
    int? discount = 10,
    String? printerName = '',
    required int price,
  }) async {
    const methodChannel = MethodChannel('printer');

    // 할인된 가격 계산
    int discountedPrice({required int price, required int discountPercent}) {
      double discount = (price * (discountPercent / 100)).toDouble();
      int discountedPrice = (price - discount).round();
      return discountedPrice;
    }

    final printData = {
      'goodsName': goodsName,
      'printCount': printCount.toString(),
      'uri': uri,
      'price': price.toString(),
      'discount': discount.toString(),
      'discountPrice':
          discountedPrice(price: price, discountPercent: discount ?? 10)
              .toString(),
      'printerName': printerName,
    };

    final result = await methodChannel.invokeMethod('print', printData);
    return result;
  }
}
