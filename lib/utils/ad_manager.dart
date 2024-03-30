import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String getAdUnitId() {
    if (Platform.isAndroid) {
      // Gunakan ini jika perangkat adalah Android
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // Gunakan ini jika perangkat adalah iOS
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Platform tidak didukung');
    }
  }

  static BannerAd createBannerAd(AdSize adSize, BannerAdListener listener) {
    return BannerAd(
      size: adSize,
      adUnitId: getAdUnitId(),
      request: const AdRequest(),
      listener: listener,
    );
  }
}
