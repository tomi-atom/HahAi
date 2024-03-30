import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  late BannerAd _bannerAd;

  BannerAd get bannerAd => _bannerAd;

  void initialize() {
    // Replace the test ad unit ID with your own ad unit ID
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5082169806538743/8242010920', // Change this with your actual ad unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          // Ad has been loaded
        },
        onAdFailedToLoad: (ad, error) {
          // Ad failed to load
          ad.dispose();
        },
      ),
    );

    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd.load();
  }
}
