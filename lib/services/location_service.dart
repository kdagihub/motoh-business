import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensurePermission() async {
    var s = await Geolocator.checkPermission();
    if (s == LocationPermission.denied) {
      s = await Geolocator.requestPermission();
    }
    return s == LocationPermission.always || s == LocationPermission.whileInUse;
  }

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<Position?> getCurrentPosition() async {
    if (!await isServiceEnabled()) return null;
    if (!await ensurePermission()) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
