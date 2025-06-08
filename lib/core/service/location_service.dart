import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    return true;
  }

  Future<Position> getCurrentLocation() async {
    await ensureLocationPermission();
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Layanan lokasi tidak aktif');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
