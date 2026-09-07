import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/attendance_model.dart';
import '../../widgets/map_preview_card.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceDetailScreen({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lat = attendance.checkInLat ?? -6.200000;
    final lng = attendance.checkInLng ?? 106.816666;
    final address = attendance.checkInAddress ?? 'Alamat tidak tersedia';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Presensi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available, color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatFriendly(attendance.attendanceDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Status: ${attendance.status.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Map Section (if coordinates exist)
            if (attendance.checkInLat != null && attendance.checkInLng != null) ...[
              Text(
                'Lokasi pada Peta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              MapPreviewCard(
                latitude: lat,
                longitude: lng,
                address: address,
                height: 250,
              ),
              const SizedBox(height: 24),
            ],

            // Details Information Card
            Text(
              'Rincian Kehadiran',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'ID Presensi',
                    value: '#${attendance.id}',
                    icon: Icons.tag,
                    isDark: isDark,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    label: 'Jam Masuk',
                    value: attendance.checkInTime != null
                        ? '${attendance.checkInTime} WIB'
                        : '-',
                    icon: Icons.login_rounded,
                    isDark: isDark,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    label: 'Jam Pulang',
                    value: attendance.checkOutTime != null
                        ? '${attendance.checkOutTime} WIB'
                        : 'Belum absen pulang',
                    icon: Icons.logout_rounded,
                    isDark: isDark,
                  ),
                  if (attendance.isIzin) ...[
                    const Divider(),
                    _buildDetailRow(
                      label: 'Alasan Izin',
                      value: attendance.alasanIzin ?? '-',
                      icon: Icons.note_outlined,
                      isDark: isDark,
                    ),
                  ],
                  const Divider(),
                  _buildDetailRow(
                    label: 'Alamat Lokasi',
                    value: address,
                    icon: Icons.location_on_outlined,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.accent : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
