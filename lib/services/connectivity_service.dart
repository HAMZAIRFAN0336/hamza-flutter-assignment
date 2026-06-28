import 'package:connectivity_plus/connectivity_plus.dart';

/// Small wrapper around connectivity_plus so the Repository doesn't
/// need to import or know about the package directly.
class ConnectivityService {
  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
