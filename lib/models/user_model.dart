enum UserRole { owner, admin, user }

/// صلاحيات يمكن منحها للإداريين من قبل مالك المشروع
class AppPermission {
  static const manageProperties = 'manage_properties'; // إدارة العقارات (حذف/تمييز)
  static const manageUsers = 'manage_users';            // إدارة المستخدمين
  static const manageAds = 'manage_ads';                // إدارة الإعلانات المميزة
  static const viewReports = 'view_reports';            // عرض التقارير والإحصائيات

  static const all = [manageProperties, manageUsers, manageAds, viewReports];

  static String label(String p) {
    switch (p) {
      case manageProperties:
        return 'إدارة العقارات';
      case manageUsers:
        return 'إدارة المستخدمين';
      case manageAds:
        return 'إدارة الإعلانات المميزة';
      case viewReports:
        return 'عرض التقارير';
      default:
        return p;
    }
  }
}

class UserModel {
  final String id;
  String name;
  String email;
  String password;
  String phone;
  UserRole role;
  List<String> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone = '',
    this.role = UserRole.user,
    List<String>? permissions,
  }) : permissions = permissions ?? [];

  bool has(String permission) =>
      role == UserRole.owner || permissions.contains(permission);
}
