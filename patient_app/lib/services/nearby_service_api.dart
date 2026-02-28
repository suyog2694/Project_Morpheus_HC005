import '../models/service_unit.dart';

class NearbyServiceAPI {

  // This will later call backend
  static Future<List<ServiceUnit>> fetchServices(String type) async {

    // currently returns empty list
    // backend will replace this

    await Future.delayed(const Duration(seconds: 1));

    return [];
  }
}