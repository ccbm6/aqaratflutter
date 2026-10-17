import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

/// إنشاء حساب جديد بالبريد وكلمة المرور فقط — يتم تفعيل الحساب فوراً
/// دون الحاجة لأي تأكيد عبر البريد الإلكتروني.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _name,
                label: 'الاسم الكامل',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().length < 3) ? 'أدخل اسمك' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _email,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'أدخل بريداً إلكترونياً صحيحاً' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phone,
                label: 'رقم الجوال',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.length < 8) ? 'أدخل رقم جوال صحيح' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _password,
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                obscure: true,
                validator: (v) =>
                    (v == null || v.length < 4) ? 'كلمة المرور يجب ألا تقل عن 4 خانات' : null,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('إنشاء الحساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final error = context.read<AuthProvider>().signup(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
        );
    setState(() => _loading = false);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح، أهلاً بك 🎉')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.danger),
      );
    }
  }
}
