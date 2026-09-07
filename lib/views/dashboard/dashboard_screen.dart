import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/attendance_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/live_clock_card.dart';
import '../attendance/attendance_detail_screen.dart';
import '../attendance/check_in_screen.dart';
import '../attendance/check_out_screen.dart';
import '../attendance/leave_permit_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToHistory;

  const DashboardScreen({
    super.key,
    this.onNavigateToStats,
    this.onNavigateToHistory,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isManualRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final attendanceProv =
        Provider.of<AttendanceProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isManualRefreshing = true);
    try {
      await Future.wait([
        attendanceProv.loadDashboard(),
        attendanceProv.loadHistory(),
        authProv.refreshProfile(),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isManualRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = Provider.of<AuthProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);

    final user = authProv.user;
    final userName = user?.name ?? 'Peserta PPKD';
    final today = attProv.todayAttendance;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Custom App Bar / Header Bar
                _buildTopHeader(user, isDark),
                const SizedBox(height: 18),

                // 2. Executive Live Digital Clock Card
                LiveClockCard(
                  userName: userName,
                  subtitle: (user?.displayTraining != null &&
                          user!.displayTraining != '-')
                      ? user.displayTraining
                      : (user?.role != null
                          ? 'Role: ${user!.role}'
                          : 'PPKD Jakarta'),
                ),
                const SizedBox(height: 20),

                // 3. Smart Presence Journey Card
                _buildSmartPresenceCard(today, attProv, isDark),
                const SizedBox(height: 26),

                // 4. Bento Action Grid
                _buildSectionTitle(
                  title: 'Menu Presensi',
                  subtitle: 'Pilih aksi kehadiran harian Anda',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildBentoActionButtons(attProv, isDark),
                const SizedBox(height: 28),

                // 5. Performance Quick Snapshot Banner
                _buildSectionTitle(
                  title: 'Performa Kehadiran',
                  subtitle: 'Ringkasan kedisiplinan belajar di PPKD',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildPerformanceBanner(attProv, isDark),
                const SizedBox(height: 28),

                // 6. Recent Activity Feed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(
                      title: 'Riwayat Terbaru',
                      subtitle: 'Catatan presensi terakhir Anda',
                      isDark: isDark,
                    ),
                    if (widget.onNavigateToHistory != null)
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onNavigateToHistory!();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.accent
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color:
                                  isDark ? AppColors.accent : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Recent List
                if (attProv.isLoadingHistory && attProv.historyList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  )
                else if (attProv.historyList.isEmpty)
                  _buildEmptyHistory(isDark)
                else ...[
                  ...attProv.historyList.take(3).map((item) {
                    return AttendanceCard(
                      attendance: item,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AttendanceDetailScreen(attendance: item),
                          ),
                        );
                      },
                      onDelete: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await attProv.deleteAttendance(item.id);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Absen berhasil dihapus'
                                : (attProv.errorMessage ?? 'Gagal menghapus')),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      },
                    );
                  }),
                  if (widget.onNavigateToHistory != null && attProv.historyList.length > 2) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onNavigateToHistory!();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Semua Riwayat (${attProv.historyList.length} Catatan)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isDark ? AppColors.accent : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top Custom Header Bar
  Widget _buildTopHeader(dynamic user, bool isDark) {
    final photoUrl = user?.fullProfilePhotoUrl;
    final initial = (user?.name != null && user!.name.isNotEmpty)
        ? user.name[0].toUpperCase()
        : 'P';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarFallback(initial),
                      )
                    : _buildAvatarFallback(initial),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF034A36),
                        ),
                        children: const [
                          TextSpan(text: 'Presen'),
                          TextSpan(
                            text: 'Sync',
                            style: TextStyle(color: Color(0xFF00B377)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PPKD',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Terhubung • GPS Aktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: _isManualRefreshing ? null : _refreshData,
          tooltip: 'Segarkan',
          style: IconButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: _isManualRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: isDark ? AppColors.accent : AppColors.primary,
                ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      color: AppColors.primaryDeep,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // Section Title Helper
  Widget _buildSectionTitle({
    required String title,
    String? subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Smart Presence Journey Hero Card
  Widget _buildSmartPresenceCard(
    dynamic today,
    AttendanceProvider attProv,
    bool isDark,
  ) {
    final hasCheckedIn = attProv.hasCheckedInToday;
    final hasCheckedOut = attProv.hasCheckedOutToday;
    final isIzin = today != null && today.isIzin;

    String statusBadge;
    String statusTitle;
    String statusSubtitle;
    Color statusColor;
    IconData statusIcon;
    String? ctaLabel;
    VoidCallback? ctaAction;

    if (isIzin) {
      statusBadge = 'Izin Terverifikasi';
      statusTitle = 'Pengajuan Izin Aktif';
      statusSubtitle = today.alasanIzin ?? 'Pengajuan izin telah tercatat.';
      statusColor = AppColors.warning;
      statusIcon = Icons.medical_services_rounded;
      ctaLabel = null;
      ctaAction = null;
    } else if (hasCheckedOut) {
      final isLate = today?.isLate ?? false;
      statusBadge = isLate ? 'Selesai (Terlambat)' : 'Selesai Hari Ini';
      statusTitle = isLate ? 'Presensi Lengkap (Telat)' : 'Presensi Lengkap';
      statusSubtitle =
          'Masuk: ${today.checkInTime} WIB • Pulang: ${today.checkOutTime} WIB';
      statusColor = isLate ? const Color(0xFFEA580C) : AppColors.info;
      statusIcon = isLate ? Icons.alarm_off_rounded : Icons.verified_rounded;
      ctaLabel = 'Lihat Detail Presensi';
      ctaAction = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceDetailScreen(attendance: today),
          ),
        );
      };
    } else if (hasCheckedIn) {
      final isLate = today?.isLate ?? false;
      statusBadge = isLate ? 'Masuk Terlambat' : 'Sedang Hadir';
      statusTitle = isLate ? 'Presensi Masuk (Terlambat)' : 'Presensi Masuk Berhasil';
      statusSubtitle = isLate
          ? 'Masuk pukul ${today.checkInTime} WIB (Lewat batas 08:00 WIB). Tetap semangat mengikuti pelatihan.'
          : 'Masuk pukul ${today.checkInTime} WIB tepat waktu. Siap absen pulang saat jam berakhir.';
      statusColor = isLate ? const Color(0xFFEA580C) : AppColors.success;
      statusIcon = isLate ? Icons.alarm_off_rounded : Icons.how_to_reg_rounded;
      ctaLabel = 'Absen Pulang Sekarang →';
      ctaAction = () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckOutScreen()),
        );
        _refreshData();
      };
    } else {
      statusBadge = 'Belum Presensi';
      statusTitle = 'Yuk, Catat Kehadiran!';
      statusSubtitle =
          'Presensi masuk sudah dibuka. Lakukan verifikasi lokasi sebelum masuk kelas.';
      statusColor = AppColors.primary;
      statusIcon = Icons.fingerprint_rounded;
      ctaLabel = 'Absen Masuk Sekarang →';
      ctaAction = () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckInScreen()),
        );
        _refreshData();
      };
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusBadge.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statusSubtitle,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: ctaAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  ctaLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Bento Quick Action Buttons
  Widget _buildBentoActionButtons(AttendanceProvider attProv, bool isDark) {
    final hasCheckedIn = attProv.hasCheckedInToday;
    final hasCheckedOut = attProv.hasCheckedOutToday;

    return Row(
      children: [
        // 1. Absen Masuk
        Expanded(
          child: _buildBentoActionItem(
            title: hasCheckedIn ? 'Sudah Masuk' : 'Absen Masuk',
            subtitle: hasCheckedIn
                ? (attProv.todayAttendance?.checkInTime ?? 'Tercatat')
                : 'Mulai Hadir',
            icon: Icons.login_rounded,
            color: AppColors.primary,
            isDark: isDark,
            isHeroPrimary: !hasCheckedIn,
            isDone: hasCheckedIn,
            onTap: () async {
              if (hasCheckedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda sudah melakukan absen masuk hari ini.'),
                  ),
                );
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckInScreen()),
              );
              _refreshData();
            },
          ),
        ),
        const SizedBox(width: 10),

        // 2. Absen Pulang
        Expanded(
          child: _buildBentoActionItem(
            title: hasCheckedOut ? 'Sudah Pulang' : 'Absen Pulang',
            subtitle: hasCheckedOut
                ? (attProv.todayAttendance?.checkOutTime ?? 'Tercatat')
                : (hasCheckedIn ? 'Selesaikan' : 'Terkunci'),
            icon: Icons.logout_rounded,
            color: AppColors.info,
            isDark: isDark,
            isHeroPrimary: hasCheckedIn && !hasCheckedOut,
            isDone: hasCheckedOut,
            isLocked: !hasCheckedIn,
            onTap: () async {
              if (!hasCheckedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Silakan absen masuk terlebih dahulu sebelum absen pulang.'),
                  ),
                );
                return;
              }
              if (hasCheckedOut) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda sudah melakukan absen pulang hari ini.'),
                  ),
                );
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckOutScreen()),
              );
              _refreshData();
            },
          ),
        ),
        const SizedBox(width: 10),

        // 3. Ajukan Izin
        Expanded(
          child: _buildBentoActionItem(
            title: 'Ajukan Izin',
            subtitle: 'Sakit / Kendala',
            icon: Icons.note_alt_outlined,
            color: AppColors.warning,
            isDark: isDark,
            isHeroPrimary: false,
            isDone: false,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeavePermitScreen()),
              );
              _refreshData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBentoActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isHeroPrimary = false,
    bool isDone = false,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    final BoxDecoration decoration;
    final Color textColor;
    final Color subtextColor;
    final Color iconColor;
    final Color iconContainerBg;

    if (isHeroPrimary) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      );
      textColor = Colors.white;
      subtextColor = Colors.white.withValues(alpha: 0.85);
      iconColor = Colors.white;
      iconContainerBg = Colors.white.withValues(alpha: 0.22);
    } else {
      decoration = BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? color.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );
      textColor = isLocked
          ? (isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
              : AppColors.lightTextSecondary.withValues(alpha: 0.7))
          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
      subtextColor = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      iconColor = isLocked
          ? (isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
              : AppColors.lightTextSecondary.withValues(alpha: 0.6))
          : color;
      iconContainerBg = isLocked
          ? Colors.grey.withValues(alpha: 0.1)
          : color.withValues(alpha: isDark ? 0.2 : 0.1);
    }

    return Opacity(
      opacity: isLocked ? 0.65 : 1.0,
      child: Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconContainerBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : (isLocked ? Icons.lock_outline_rounded : icon),
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: subtextColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Quick Performance Banner
  Widget _buildPerformanceBanner(AttendanceProvider attProv, bool isDark) {
    final percentage = attProv.attendancePercentage;
    final grade = attProv.attendanceGrade;
    final isGood = attProv.isPerformanceGood;
    final accentColor = isGood ? AppColors.primary : const Color(0xFFEA580C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : accentColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    isGood ? Icons.insights_rounded : Icons.schedule_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tingkat Kehadiran',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: accentColor
                                  .withValues(alpha: isDark ? 0.22 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(0)}% • $grade',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attProv.totalIzin > 0
                          ? '${attProv.totalMasuk} Hadir • ${attProv.totalIzin} Izin • ${attProv.lateCount} Telat'
                          : '${attProv.totalMasuk} Hadir • ${attProv.onTimeCount} Tepat • ${attProv.lateCount} Telat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onNavigateToStats?.call();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 18,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Buka Analisis Statistik Lengkap',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 32,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada riwayat absensi',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
