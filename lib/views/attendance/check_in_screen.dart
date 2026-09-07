import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_helper.dart';
import '../../services/dio_client.dart';
import '../../viewmodels/attendance_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/map_preview_card.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  LocationResult? _locationResult;
  bool _isLoadingLocation = true;
  bool _isProcessing = false;
  late Timer _clockTimer;
  DateTime _currentTime = ServerTimeSync.accurateNow;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _currentTime = ServerTimeSync.accurateNow;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = ServerTimeSync.accurateNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    final result = await LocationHelper.getCurrentLocationWithAddress();
    if (mounted) {
      setState(() {
        _locationResult = result;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submitCheckIn() async {
    if (_isProcessing) return;

    if (_locationResult == null || !_locationResult!.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_locationResult?.errorMessage ?? 'Lokasi belum didapatkan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_locationResult!.isMocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Absensi Ditolak! Terdeteksi penggunaan Fake GPS / Mock Location.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final distanceMeters = _locationResult?.distanceToOfficeMeters;
    final campusName = _locationResult?.nearestCampusName ?? 'kampus PPKD';
    if (distanceMeters != null &&
        distanceMeters > LocationHelper.defaultMaxRadiusMeters) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Di Luar Radius'),
            ],
          ),
          content: Text(
            'Lokasi Anda berjarak ${distanceMeters.toStringAsFixed(0)} meter dari $campusName (Batas aman: ${LocationHelper.defaultMaxRadiusMeters.toInt()}m).\n\nTetap ajukan absen masuk?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tetap Lanjutkan'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    if (!mounted) return;

    final attProv = Provider.of<AttendanceProvider>(context, listen: false);

    if (attProv.todayAttendance?.isIzin == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Anda memiliki status izin hari ini. Tidak dapat absen masuk.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (attProv.hasCheckedInToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda sudah melakukan absen masuk hari ini.'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await attProv.checkIn(
        lat: _locationResult!.latitude!,
        lng: _locationResult!.longitude!,
        address: _locationResult!.address,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absen masuk berhasil tercatat!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(attProv.errorMessage ?? 'Gagal melakukan absen masuk'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attProv = Provider.of<AttendanceProvider>(context);

    final dateStr = DateFormatter.formatFullDate(_currentTime);
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);

    final distanceMeters = _locationResult?.distanceToOfficeMeters;
    final isWithinOffice = distanceMeters != null &&
        distanceMeters <= LocationHelper.defaultMaxRadiusMeters;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Presensi Masuk'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Accurate Server Time Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'WAKTU SERVER RESMI',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$timeStr WIB',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mock GPS Alert
              if (_locationResult != null && _locationResult!.isMocked) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security_update_warning_rounded,
                          color: AppColors.error, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Terdeteksi Fake GPS / Mock Location! Matikan aplikasi lokasi tiruan untuk melanjutkan absensi.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Section Header
              Text(
                'Verifikasi Radar Lokasi',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Map Preview Box
              if (_isLoadingLocation)
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Mendeteksi sinyal GPS & geofencing PPKD...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_locationResult != null &&
                  _locationResult!.isSuccess) ...[
                MapPreviewCard(
                  latitude: _locationResult!.latitude!,
                  longitude: _locationResult!.longitude!,
                  address: _locationResult!.address,
                  onRefresh: _getLocation,
                ),
                const SizedBox(height: 12),

                // Geofence Distance Chip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isWithinOffice
                        ? AppColors.success
                            .withValues(alpha: isDark ? 0.2 : 0.1)
                        : AppColors.warning
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isWithinOffice
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isWithinOffice
                            ? Icons.verified_rounded
                            : Icons.near_me_outlined,
                        size: 20,
                        color: isWithinOffice
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          distanceMeters != null
                              ? '${_locationResult?.nearestCampusName ?? "PPKD"}: ${distanceMeters.toStringAsFixed(0)}m (${isWithinOffice ? 'Dalam Radius Presensi' : 'Di Luar Radius'})'
                              : 'Lokasi GPS terverifikasi',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isWithinOffice
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Container(
                  height: 240,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off_rounded,
                          size: 44, color: AppColors.error),
                      const SizedBox(height: 10),
                      Text(
                        _locationResult?.errorMessage ??
                            'Gagal mengambil koordinat GPS',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _getLocation,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              if (attProv.hasCheckedInToday) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.info, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Anda sudah melakukan presensi masuk hari ini (${attProv.todayAttendance?.checkInTime ?? "--:--"} WIB).',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Kembali ke Beranda'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Action Confirmation Button
                CustomButton(
                  text: 'Konfirmasi Presensi Masuk',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: attProv.isSubmitting || _isProcessing,
                  onPressed: (_isLoadingLocation ||
                          _isProcessing ||
                          _locationResult == null ||
                          !_locationResult!.isSuccess ||
                          _locationResult!.isMocked ||
                          attProv.hasCheckedInToday)
                      ? null
                      : _submitCheckIn,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
