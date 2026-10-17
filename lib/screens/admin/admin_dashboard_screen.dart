import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

/// شاشة تحكم مالك المشروع: إضافة إداريين ومنح/سحب الصلاحيات المختلفة،
/// بالإضافة لنظرة عامة سريعة على إحصائيات المنصة.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final properties = context.watch<PropertyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المالك')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildStats(auth, properties),
          const SizedBox(height: 22),
          const SectionTitle(title: 'إضافة إداري جديد'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'البريد الإلكتروني للإداري',
                    prefixIcon: Icon(Icons.person_add_alt_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addAdmin,
                style: ElevatedButton.styleFrom(minimumSize: const Size(56, 52)),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'إذا لم يكن البريد مسجلاً، سيتم إنشاء حساب إداري تلقائياً بكلمة مرور مؤقتة (admin1234).',
            style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
          ),
          const SizedBox(height: 22),
          SectionTitle(title: 'الإداريون (${auth.admins.length})'),
          if (auth.admins.isEmpty)
            const EmptyState(icon: Icons.admin_panel_settings_outlined, message: 'لا يوجد إداريون بعد')
          else
            ...auth.admins.map((admin) => _AdminTile(admin: admin)),
        ],
      ),
    );
  }

  Widget _buildStats(AuthProvider auth, PropertyProvider properties) {
    Widget stat(String value, String label, IconData icon, Color color) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        stat('${properties.all.length}', 'عقار', Icons.apartment, AppColors.primary),
        const SizedBox(width: 10),
        stat('${auth.allUsers.length}', 'مستخدم', Icons.people_outline, AppColors.rentColor),
        const SizedBox(width: 10),
        stat('${auth.admins.length}', 'إداري', Icons.shield_outlined, AppColors.secondary),
      ],
    );
  }

  void _addAdmin() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل بريداً إلكترونياً صحيحاً'), backgroundColor: AppColors.danger),
      );
      return;
    }
    final error = context.read<AuthProvider>().addAdminByEmail(email);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.danger));
    } else {
      _emailController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تمت إضافة الإداري بنجاح')));
    }
  }
}

class _AdminTile extends StatelessWidget {
  final UserModel admin;
  const _AdminTile({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(admin.email,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_remove_outlined, color: AppColors.danger),
                tooltip: 'إزالة الصلاحيات الإدارية',
                onPressed: () => context.read<AuthProvider>().removeAdmin(admin.id),
              ),
            ],
          ),
          const Divider(height: 20),
          const Text('الصلاحيات', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: AppPermission.all.map((perm) {
              final has = admin.permissions.contains(perm);
              return FilterChip(
                label: Text(AppPermission.label(perm), style: const TextStyle(fontSize: 12)),
                selected: has,
                onSelected: (val) {
                  final updated = List<String>.from(admin.permissions);
                  val ? updated.add(perm) : updated.remove(perm);
                  context.read<AuthProvider>().updatePermissions(admin.id, updated);
                },
                selectedColor: AppColors.primaryLight.withOpacity(0.25),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
