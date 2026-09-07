import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/attendance_model.dart';
import '../../services/dio_client.dart';
import '../../viewmodels/attendance_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LeavePermitScreen extends StatefulWidget {
  const LeavePermitScreen({super.key});

  @override
  State<LeavePermitScreen> createState() => _LeavePermitScreenState();
}

class _LeavePermitScreenState extends State<LeavePermitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  late DateTime _selectedDate;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final attProv = Provider.of<AttendanceProvider>(context, listen: false);
    final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);
    final alreadyAttendedToday = attProv.hasCheckedInToday ||
        attProv.historyList.any((e) => e.attendanceDate == todayStr);

    // Jika hari ini sudah ada presensi masuk / izin, arahkan default ke esok hari
    if (alreadyAttendedToday) {
      _selectedDate = ServerTimeSync.accurateNow.add(const Duration(days: 1));
    } else {
      _selectedDate = ServerTimeSync.accurateNow;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = ServerTimeSync.accurateNow;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.darkCard : Colors.white,
              onSurface: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitLeave() async {
    if (_isProcessing) return;
    if (!_formKey.currentState!.validate()) return;

    final attProv = Provider.of<AttendanceProvider>(context, listen: false);
    final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);
    final dateStr = DateFormatter.formatApiDate(_selectedDate);

    // Validasi pencegahan konflik catatan presensi
    final existing = _findExistingRecord(attProv, dateStr, todayStr);
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing.isMasuk
                ? 'Anda sudah memiliki catatan presensi masuk pada tanggal ini (${existing.checkInTime ?? "--:--"} WIB).'
                : 'Pengajuan izin untuk tanggal ini sudah pernah dibuat sebelumnya.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await attProv.submitLeave(
        date: dateStr,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permohonan izin berhasil dikirimkan.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(attProv.errorMessage ?? 'Gagal mengajukan izin'),
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

  AttendanceModel? _findExistingRecord(
    AttendanceProvider attProv,
    String dateStr,
    String todayStr,
  ) {
    if (dateStr == todayStr && attProv.hasCheckedInToday) {
      return attProv.todayAttendance;
    }
    for (final item in attProv.historyList) {
      if (item.attendanceDate == dateStr ||
          item.attendanceDate.startsWith(dateStr)) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attProv = Provider.of<AttendanceProvider>(context);

    final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);
    final selectedDateStr = DateFormatter.formatApiDate(_selectedDate);
    final existingRecord =
        _findExistingRecord(attProv, selectedDateStr, todayStr);
    final hasConflict = existingRecord != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Pengajuan Izin'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            tooltip: 'Kembali',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning
                        .withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_information_outlined,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ketentuan Izin PPKD',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pengajuan izin harus menyertakan alasan yang jelas (sakit, keperluan mendesak, atau kedukaan). Pengajuan tidak dapat dibatalkan setelah disetujui instruktur.',
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.35,
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
                ),
                const SizedBox(height: 20),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Selector Field
                      Text(
                        'Tanggal Izin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hasConflict
                                  ? AppColors.error.withValues(alpha: 0.6)
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                              width: hasConflict ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 20,
                                color: hasConflict
                                    ? AppColors.error
                                    : (isDark
                                        ? AppColors.accent
                                        : AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormatter.formatFullDate(_selectedDate),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: hasConflict
                                        ? AppColors.error
                                        : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Conflict Warning Box
                      if (hasConflict) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error
                                .withValues(alpha: isDark ? 0.2 : 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      existingRecord.isMasuk
                                          ? 'Anda sudah melakukan absen masuk pada tanggal ini'
                                          : 'Pengajuan izin sudah ada untuk tanggal ini',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                existingRecord.isMasuk
                                    ? 'Presensi tercatat masuk pukul ${existingRecord.checkInTime ?? "--:--"} WIB. Pengajuan izin hanya dapat diajukan pada tanggal yang belum dihadiri.'
                                    : 'Alasan izin yang sudah tercatat: "${existingRecord.alasanIzin ?? "-"}"',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = ServerTimeSync.accurateNow
                                        .add(const Duration(days: 1));
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: isDark ? 0.25 : 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 14, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Pilih Tanggal Esok (${DateFormatter.formatShort(DateFormatter.formatApiDate(ServerTimeSync.accurateNow.add(const Duration(days: 1))))})',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.accent
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Reason Field
                      CustomTextField(
                        controller: _reasonController,
                        label: 'Alasan Izin / Keterangan',
                        hint: 'Tuliskan alasan lengkap tidak dapat hadir...',
                        prefixIcon: Icons.edit_note_rounded,
                        maxLines: 4,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Alasan izin wajib diisi';
                          }
                          if (val.trim().length < 5) {
                            return 'Berikan alasan minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Submit Button (Guarded from conflict)
                CustomButton(
                  text: hasConflict
                      ? (existingRecord.isMasuk
                          ? 'Tanggal Sudah Memiliki Presensi'
                          : 'Izin Sudah Terdaftar')
                      : 'Kirim Permohonan Izin',
                  icon: hasConflict ? Icons.block_rounded : Icons.send_rounded,
                  backgroundColor:
                      hasConflict ? Colors.grey : AppColors.warning,
                  isLoading: attProv.isSubmitting || _isProcessing,
                  onPressed: (_isProcessing || hasConflict) ? null : _submitLeave,
                ),

                const SizedBox(height: 14),

                // Explicit Cancel / Back Button (Guaranteeing zero trap state)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Batal & Kembali ke Beranda',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
