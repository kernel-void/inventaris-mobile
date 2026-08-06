import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _service = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password baru wajib diisi';
    }
    if (value.length < 8) {
      return 'Minimal 8 karakter';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newController.text != _confirmController.text) {
      showAppSnackBar(
        context,
        'Konfirmasi password tidak cocok',
        type: AppSnackType.error,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(
        context,
        'Password berhasil diubah',
        type: AppSnackType.success,
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, e.toString(), type: AppSnackType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password')),
      body:
          SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _currentController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password Saat Ini',
                          prefixIcon: const Icon(
                            PhosphorIcons.lockSimple,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? PhosphorIcons.eyeSlash
                                  : PhosphorIcons.eye,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Password saat ini wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newController,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: Icon(PhosphorIcons.lockSimple, size: 20),
                        ),
                        validator: _validateNew,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          prefixIcon: Icon(PhosphorIcons.lockSimple, size: 20),
                        ),
                        validator: _validateNew,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Password harus minimal 8 karakter, mengandung huruf besar, '
                        'huruf kecil, dan angka.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(PhosphorIcons.floppyDisk, size: 20),
                        label: const Text('Simpan Password'),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms)
              .moveY(begin: 8, duration: 350.ms, curve: Curves.easeOut),
    );
  }
}
