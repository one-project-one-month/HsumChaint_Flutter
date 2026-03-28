import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(RxInterface<dynamic> rx) {
    _worker = ever<dynamic>(rx, (_) => notifyListeners());
  }

  late final Worker _worker;

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }
}
