import 'dart:io';

class AdHelper {
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // test ad unit id
      return 'ca-app-pub-3940256099942544/1033173712';

      // actual ad unit id
      //return 'ca-app-pub-6874554141570912/9323577479';
    } else if (Platform.isIOS) {
      // test id for IOS
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}