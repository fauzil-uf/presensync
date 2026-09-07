import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:presensync/models/attendance_model.dart';
import 'package:presensync/viewmodels/attendance_viewmodel.dart';
import 'package:presensync/views/attendance/leave_permit_screen.dart';
import 'package:presensync/widgets/attendance_card.dart';

void main() {
  group('AttendanceModel Late & On-Time Logic Tests', () {
    test('Check-in before or at 08:00 is on-time', () {
      final item1 = AttendanceModel(
        id: 1,
        attendanceDate: '2026-09-07',
        checkInTime: '07:45',
        status: 'Masuk',
      );
      expect(item1.isLate, isFalse);
      expect(item1.isOnTime, isTrue);

      final item2 = AttendanceModel(
        id: 2,
        attendanceDate: '2026-09-07',
        checkInTime: '08:00',
        status: 'Masuk',
      );
      expect(item2.isLate, isFalse);
      expect(item2.isOnTime, isTrue);

      final item3 = AttendanceModel(
        id: 3,
        attendanceDate: '2026-09-07',
        checkInTime: '08:00:00 WIB',
        status: 'Masuk',
      );
      expect(item3.isLate, isFalse);
      expect(item3.isOnTime, isTrue);
    });

    test('Check-in after 08:00 is late', () {
      final item1 = AttendanceModel(
        id: 4,
        attendanceDate: '2026-09-07',
        checkInTime: '08:01',
        status: 'Masuk',
      );
      expect(item1.isLate, isTrue);
      expect(item1.isOnTime, isFalse);

      final item2 = AttendanceModel(
        id: 5,
        attendanceDate: '2026-09-07',
        checkInTime: '10:59 WIB',
        status: 'Masuk',
      );
      expect(item2.isLate, isTrue);
      expect(item2.isOnTime, isFalse);

      final item3 = AttendanceModel(
        id: 6,
        attendanceDate: '2026-09-07',
        checkInTime: '10:59:00',
        status: 'Masuk',
      );
      expect(item3.isLate, isTrue);
      expect(item3.isOnTime, isFalse);
    });

    test('Izin status is not late or on-time', () {
      final izin = AttendanceModel(
        id: 7,
        attendanceDate: '2026-09-07',
        status: 'Izin',
        alasanIzin: 'Sakit flu',
      );
      expect(izin.isIzin, isTrue);
      expect(izin.isLate, isFalse);
      expect(izin.isOnTime, isFalse);
    });
  });

  group('AttendanceCard UI Widget Tests', () {
    testWidgets('Renders TERLAMBAT badge and TELAT pill for late attendance',
        (tester) async {
      final lateItem = AttendanceModel(
        id: 10,
        attendanceDate: '2026-09-07',
        checkInTime: '10:59',
        status: 'Masuk',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360, // Standard mobile width
              child: AttendanceCard(attendance: lateItem),
            ),
          ),
        ),
      );

      // Verify TERLAMBAT badge is rendered
        expect(find.text('TERLAMBAT'), findsOneWidget);
        expect(find.text('TELAT'), findsOneWidget);
        expect(find.text('10:59 WIB'), findsOneWidget);
        expect(find.text('MASUK'), findsNothing);
      },
    );
  });

  group('LeavePermitScreen UI & Conflict Prevention Tests', () {
    testWidgets('Renders LeavePermitScreen with back buttons and cancel option',
        (tester) async {
      final provider = AttendanceProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<AttendanceProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: LeavePermitScreen(),
          ),
        ),
      );

      // Verify Screen Title & Form
      expect(find.text('Pengajuan Izin'), findsOneWidget);
      expect(find.text('Ketentuan Izin PPKD'), findsOneWidget);
      expect(find.text('Tanggal Izin'), findsOneWidget);
      expect(find.text('Batal & Kembali ke Beranda'), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
