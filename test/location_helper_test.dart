import 'package:flutter_test/flutter_test.dart';
import 'package:presensync/core/utils/location_helper.dart';

void main() {
  group('LocationHelper & Geofence Tests', () {
    test('Calculates 0m distance for exact PPKD Jakarta Pusat coordinates', () {
      final nearest = LocationHelper.getNearestCampus(-6.21072, 106.81327);
      expect(nearest.campus.name, 'PPKD Jakarta Pusat');
      expect(nearest.distanceMeters, closeTo(0.0, 1.0));
      expect(LocationHelper.isWithinPPKD(-6.21072, 106.81327), isTrue);
    });

    test('Indoor GPS jitter (~100m) is comfortably within 1000m radius', () {
      // Slightly offset latitude within the PPKD building grounds
      const indoorLat = -6.21090;
      const indoorLng = 106.81335;
      final distance = LocationHelper.getDistanceToPPKD(indoorLat, indoorLng);
      expect(distance, lessThan(100.0));
      expect(LocationHelper.isWithinPPKD(indoorLat, indoorLng), isTrue);
    });

    test('Detects nearest campus dynamically for PPKD Jakarta Timur', () {
      // Coordinates of PPKD Jakarta Timur (Pondok Kelapa)
      const jaktimLat = -6.23438;
      const jaktimLng = 106.93885;
      final nearest = LocationHelper.getNearestCampus(jaktimLat, jaktimLng);
      expect(nearest.campus.name, 'PPKD Jakarta Timur');
      expect(nearest.distanceMeters, closeTo(0.0, 1.0));
      expect(LocationHelper.isWithinPPKD(jaktimLat, jaktimLng), isTrue);
    });

    test('Old inaccurate coordinate is approximately ~605m from real PPKD building', () {
      // Old coordinate that was previously hardcoded
      const oldLat = -6.2088;
      const oldLng = 106.8184;
      final distance = LocationHelper.getDistanceToPPKD(oldLat, oldLng);
      // Confirms why user was seeing ~605-647 meters discrepancy
      expect(distance, closeTo(605.0, 50.0));
    });

    test('Default radius threshold is 1000 meters', () {
      expect(LocationHelper.defaultMaxRadiusMeters, 1000.0);
    });
  });
}
