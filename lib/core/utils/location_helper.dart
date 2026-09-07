import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String address;
  final String? errorMessage;
  final bool isMocked;
  final double? distanceToOfficeMeters;
  final String? nearestCampusName;

  LocationResult({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    required this.address,
    this.errorMessage,
    this.isMocked = false,
    this.distanceToOfficeMeters,
    this.nearestCampusName,
  });

  factory LocationResult.failure(String message, {bool isMocked = false}) {
    return LocationResult(
      isSuccess: false,
      address: 'Lokasi tidak diketahui',
      errorMessage: message,
      isMocked: isMocked,
    );
  }

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    required String address,
    bool isMocked = false,
    double? distanceToOfficeMeters,
    String? nearestCampusName,
  }) {
    return LocationResult(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      address: address,
      isMocked: isMocked,
      distanceToOfficeMeters: distanceToOfficeMeters,
      nearestCampusName: nearestCampusName,
    );
  }
}

class PPKDCampus {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PPKDCampus({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationHelper {
  // Daftar Kampus Resmi PPKD DKI Jakarta dengan Koordinat Presisi
  static const List<PPKDCampus> allCampuses = [
    PPKDCampus(
      name: 'PPKD Jakarta Pusat',
      address: 'Jl. Karet Pasar Baru Barat V No. 23, Karet Tengsin, Tanah Abang',
      latitude: -6.21072,
      longitude: 106.81327,
    ),
    PPKDCampus(
      name: 'PPKD Jakarta Timur',
      address: 'Jl. H. Naman No. 1, Pondok Kelapa, Duren Sawit',
      latitude: -6.23438,
      longitude: 106.93885,
    ),
    PPKDCampus(
      name: 'PPKD Jakarta Selatan',
      address: 'Jl. Buncit Raya No. 440, Kalibata, Pancoran',
      latitude: -6.26250,
      longitude: 106.83020,
    ),
    PPKDCampus(
      name: 'PPKD Jakarta Barat',
      address: 'Jl. Raya Daan Mogot KM 14 / Rusun Pesakih, Cengkareng',
      latitude: -6.14770,
      longitude: 106.70290,
    ),
    PPKDCampus(
      name: 'PPKD Jakarta Utara',
      address: 'Jl. Gereja Tugu No. 20, Semper Barat, Cilincing',
      latitude: -6.13110,
      longitude: 106.92480,
    ),
  ];

  // Koordinat Resmi PPKD Jakarta Pusat (Default fallback)
  static const double ppkdOfficeLat = -6.21072;
  static const double ppkdOfficeLng = 106.81327;
  static const double defaultMaxRadiusMeters = 1000.0; // Batas radius 1000 meter (1 KM) toleran GPS gedung

  /// Mencari kampus PPKD terdekat dari posisi saat ini
  static ({PPKDCampus campus, double distanceMeters}) getNearestCampus(
    double latitude,
    double longitude,
  ) {
    PPKDCampus nearest = allCampuses.first;
    double minDistance = double.infinity;

    for (final c in allCampuses) {
      final d = Geolocator.distanceBetween(
        latitude,
        longitude,
        c.latitude,
        c.longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        nearest = c;
      }
    }

    return (campus: nearest, distanceMeters: minDistance);
  }

  /// Memeriksa izin akses, anti-Mock GPS, dan mendapatkan koordinat & alamat pengguna saat ini
  static Future<LocationResult> getCurrentLocationWithAddress() async {
    try {
      // 1. Cek apakah layanan GPS pada perangkat aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          'Layanan GPS non-aktif. Harap aktifkan GPS di pengaturan perangkat Anda.',
        );
      }

      // 2. Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
            'Izin akses lokasi ditolak oleh pengguna.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          'Izin lokasi ditolak secara permanen. Harap aktifkan izin lokasi di pengaturan aplikasi.',
        );
      }

      // 3. Ambil posisi GPS dengan akurasi tinggi (fallback ke posisi terakhir jika timeout/indoor)
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return LocationResult.failure(
          'Tidak dapat mendeteksi sinyal GPS. Pastikan GPS aktif dan berada di area yang terjangkau sinyal.',
        );
      }

      // 4. CEK ANTI-FAKE GPS (Mock Location Protection)
      if (position.isMocked) {
        return LocationResult.failure(
          'Terdeteksi menggunakan Lokasi Palsu (Fake GPS / Mock Location)! Sistem PPKD melarang keras manipulasi lokasi.',
          isMocked: true,
        );
      }

      // 5. Hitung jarak ke kampus PPKD terdekat secara dinamis
      final nearest = getNearestCampus(
        position.latitude,
        position.longitude,
      );

      // 6. Reverse geocoding (koordinat -> alamat)
      String address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        isMocked: false,
        distanceToOfficeMeters: nearest.distanceMeters,
        nearestCampusName: nearest.campus.name,
      );
    } catch (e) {
      return LocationResult.failure('Gagal mengambil lokasi: $e');
    }
  }

  /// Menghitung jarak pengguna ke kampus PPKD terdekat
  static double getDistanceToPPKD(double latitude, double longitude) {
    return getNearestCampus(latitude, longitude).distanceMeters;
  }

  /// Memeriksa apakah pengguna berada dalam radius kantor PPKD
  static bool isWithinPPKD(
    double latitude,
    double longitude, {
    double maxRadius = defaultMaxRadiusMeters,
  }) {
    final distance = getDistanceToPPKD(latitude, longitude);
    return distance <= maxRadius;
  }

  /// Mengonversi Latitude & Longitude menjadi nama jalan/wilayah
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final geocodingService = geocoding.Geocoding();
      List<geocoding.Placemark> placemarks =
          await geocodingService.placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];

        if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
        if (p.subLocality != null && p.subLocality!.isNotEmpty) {
          parts.add(p.subLocality!);
        }
        if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
        if (p.subAdministrativeArea != null &&
            p.subAdministrativeArea!.isNotEmpty) {
          parts.add(p.subAdministrativeArea!);
        }
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
          parts.add(p.administrativeArea!);
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (_) {
      // Jika geocoding gagal (misal koneksi labil saat reverse), tampilkan koordinat
    }

    return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
  }
}
