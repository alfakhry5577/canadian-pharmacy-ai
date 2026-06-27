import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scaffold_notice_banner.dart';

/// OTP-ready forgot-password flow: email -> OTP -> new password.
/// NOTE: the backend does not yet expose
///   POST /api/auth/forgot-password   (send OTP)
///   POST /api/auth/reset-password    (verify OTP + set new password)
/// This screen is fully built so wiring it up later is a pure backend task —
/// see mobile/README.md "Known Gaps".
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Step { email, otp, newPassword, done }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  _Step _step = _Step.email;
  bool _isSubmitting = false;

  Future<void> _advance() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600)); // simulated request
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _step = switch (_step) {
        _Step.email => _Step.otp,
        _Step.otp => _Step.newPassword,
        _Step.newPassword => _Step.done,
        _Step.done => _Step.done,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScaffoldNoticeBanner(feature: 'POST /api/auth/forgot-password و /api/auth/reset-password'),
              const SizedBox(height: 24),
              Form(key: _formKey, child: _buildStepContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _Step.email:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق (OTP).', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(label: 'البريد الإلكتروني', controller: _emailController, validator: Validators.email),
            const SizedBox(height: 24),
            PrimaryButton(label: 'إرسال رمز التحقق', onPressed: _advance, isLoading: _isSubmitting),
          ],
        );
      case _Step.otp:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أدخل رمز التحقق المرسل إلى ${_emailController.text}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(
              label: 'رمز التحقق (OTP)',
              controller: _otpController,
              keyboardType: TextInputType.number,
              validator: Validators.required,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'تأكيد الرمز', onPressed: _advance, isLoading: _isSubmitting),
          ],
        );
      case _Step.newPassword:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أدخل كلمة المرور الجديدة', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(label: 'كلمة المرور الجديدة', controller: _passwordController, obscureText: true, validator: Validators.password),
            const SizedBox(height: 24),
            PrimaryButton(label: 'حفظ كلمة المرور', onPressed: _advance, isLoading: _isSubmitting),
          ],
        );
      case _Step.done:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF1F9D6A), size: 48),
            const SizedBox(height: 12),
            Text('تم تحديث كلمة المرور بنجاح', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            PrimaryButton(label: 'العودة لتسجيل الدخول', onPressed: () => Navigator.of(context).pop()),
          ],
        );
    }
  }
}
