import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/auth_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../dashboard/main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _jenisKelamin; // Wajib dipilih eksplisit oleh peserta (tidak default L)
  int? _selectedBatchId;
  int? _selectedTrainingId;

  List<Batch> _batches = [];
  List<Training> _trainings = [];
  bool _isLoadingMeta = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final authService = AuthService();
    try {
      final batches = await authService.getBatches();
      final trainings = await authService.getTrainings();

      if (mounted) {
        setState(() {
          _batches = batches;
          _trainings = trainings;
          if (_batches.isNotEmpty) _selectedBatchId = _batches.first.id;
          if (_trainings.isNotEmpty) _selectedTrainingId = _trainings.first.id;
          _isLoadingMeta = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMeta = false;
          _selectedBatchId = 1;
          _selectedTrainingId = 16;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_jenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih jenis kelamin Anda terlebih dahulu (Laki-laki / Perempuan).'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = RegisterRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      jenisKelamin: _jenisKelamin!,
      batchId: _selectedBatchId ?? 1,
      trainingId: _selectedTrainingId ?? 16,
    );

    final success = await authProvider.register(request);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Selamat datang.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registrasi gagal. Coba lagi.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrasi Peserta PPKD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi formulir di bawah untuk mendaftarkan akun absensi Anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Lengkap
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'contoh: Budi Santoso',
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Alamat Email',
                  hint: 'contoh: peserta@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!val.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Jenis Kelamin
                Text(
                  'Jenis Kelamin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _jenisKelamin = 'L'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _jenisKelamin == 'L'
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : (isDark ? AppColors.darkCard : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _jenisKelamin == 'L'
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: _jenisKelamin == 'L' ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.male_rounded,
                                size: 20,
                                color: _jenisKelamin == 'L'
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Laki-laki',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _jenisKelamin == 'L'
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _jenisKelamin = 'P'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _jenisKelamin == 'P'
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : (isDark ? AppColors.darkCard : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _jenisKelamin == 'P'
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: _jenisKelamin == 'P' ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.female_rounded,
                                size: 20,
                                color: _jenisKelamin == 'P'
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Perempuan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _jenisKelamin == 'P'
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Batch Dropdown
                Text(
                  'Batch / Angkatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                _isLoadingMeta
                    ? const LinearProgressIndicator(minHeight: 3)
                    : DropdownButtonFormField<int>(
                        initialValue: _selectedBatchId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.group_work_outlined, size: 20),
                        ),
                        items: _batches.map((b) {
                          return DropdownMenuItem<int>(
                            value: b.id,
                            child: Text(
                              b.batchName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedBatchId = val);
                        },
                      ),
                const SizedBox(height: 14),

                // Training Dropdown
                Text(
                  'Kejuruan / Pelatihan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                _isLoadingMeta
                    ? const LinearProgressIndicator(minHeight: 3)
                    : DropdownButtonFormField<int>(
                        initialValue: _selectedTrainingId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.school_outlined, size: 20),
                        ),
                        isExpanded: true,
                        items: _trainings.map((t) {
                          return DropdownMenuItem<int>(
                            value: t.id,
                            child: Text(
                              t.title,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedTrainingId = val);
                        },
                      ),
                const SizedBox(height: 14),

                // Kata Sandi
                CustomTextField(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  hint: 'Minimal 6 karakter',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    if (val.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Konfirmasi Kata Sandi
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ketik ulang kata sandi',
                  prefixIcon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (val != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Tombol Register
                CustomButton(
                  text: 'Daftar Sekarang',
                  icon: Icons.person_add_alt_1_rounded,
                  isLoading: authProvider.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
