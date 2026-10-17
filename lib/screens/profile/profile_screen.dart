import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/property_card.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../property/add_property_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 72, color: AppColors.textGrey),
                const SizedBox(height: 12),
                const Text('سجّل دخولك للوصول إلى حسابك، وإضافة عقاراتك، وحفظ المفضلة',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('تسجيل الدخول'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = auth.currentUser!;
    final myProperties = context.watch<PropertyProvider>().byOwner(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(user.name.isNotEmpty ? user.name[0] : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    Text(user.email, style: const TextStyle(color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    _roleBadge(user.role),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (user.role == UserRole.owner)
            _menuTile(
              context,
              icon: Icons.admin_panel_settings_outlined,
              title: 'لوحة تحكم المالك',
              subtitle: 'إدارة الإداريين والصلاحيات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
            ),
          _menuTile(
            context,
            icon: Icons.add_home_work_outlined,
            title: 'إضافة عقار جديد',
            subtitle: 'اعرض عقارك للبيع أو الإيجار',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(title: 'عقاراتي (${myProperties.length})'),
          if (myProperties.isEmpty)
            const EmptyState(icon: Icons.home_outlined, message: 'لم تقم بإضافة أي عقار بعد')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              itemCount: myProperties.length,
              itemBuilder: (_, i) => PropertyCard(property: myProperties[i]),
            ),
        ],
      ),
    );
  }

  Widget _roleBadge(UserRole role) {
    final map = {
      UserRole.owner: ('مالك المنصة', AppColors.secondary),
      UserRole.admin: ('إداري', AppColors.rentColor),
      UserRole.user: ('مستخدم', AppColors.textGrey),
    };
    final (label, color) = map[role]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _menuTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
