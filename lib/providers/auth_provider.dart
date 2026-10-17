import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// يدير تسجيل الدخول/التسجيل وحالة المستخدم الحالي، بالإضافة لإدارة
/// الإداريين وصلاحياتهم من قبل مالك المشروع (owner).
class AuthProvider extends ChangeNotifier {
  final List<UserModel> _users = [
    // حساب مالك المشروع الافتراضي (owner) — يملك كل الصلاحيات تلقائياً
    UserModel(
      id: 'owner_main',
      name: 'مالك المنصة',
      email: 'owner@aqar.com',
      password: '123456',
      phone: '+966500000000',
      role: UserRole.owner,
    ),
  ];

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isOwner => _currentUser?.role == UserRole.owner;
  bool get isAdminOrOwner =>
      _currentUser?.role == UserRole.admin || _currentUser?.role == UserRole.owner;

  List<UserModel> get allUsers => List.unmodifiable(_users);
  List<UserModel> get admins =>
      _users.where((u) => u.role == UserRole.admin).toList();

  String? login(String email, String password) {
    final match = _users.where(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (match.isEmpty) return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
    final user = match.first;
    if (user.password != password) return 'كلمة المرور غير صحيحة';
    _currentUser = user;
    notifyListeners();
    return null; // null = نجاح
  }

  /// تسجيل حساب جديد فورياً بدون الحاجة لتأكيد البريد الإلكتروني
  String? signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) return 'هذا البريد الإلكتروني مستخدم بالفعل';

    final newUser = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      password: password,
      phone: phone.trim(),
      role: UserRole.user,
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ---------- إدارة الإداريين والصلاحيات (لمالك المشروع فقط) ----------

  /// ترقية مستخدم موجود إلى "إداري" مع صلاحيات مبدئية، أو إن لم يكن
  /// مسجلاً بعد يتم إنشاء حساب إداري جاهز له بكلمة مرور مؤقتة.
  String? addAdminByEmail(String email, {List<String>? permissions}) {
    final idx = _users.indexWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (idx == -1) {
      _users.add(UserModel(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email.trim(),
        password: 'admin1234',
        role: UserRole.admin,
        permissions: permissions ?? [AppPermission.manageProperties],
      ));
    } else {
      final u = _users[idx];
      if (u.role == UserRole.owner) return 'لا يمكن تعديل صلاحيات مالك المشروع';
      u.role = UserRole.admin;
      u.permissions = permissions ?? [AppPermission.manageProperties];
    }
    notifyListeners();
    return null;
  }

  void updatePermissions(String userId, List<String> permissions) {
    final u = _users.firstWhere((u) => u.id == userId);
    u.permissions = permissions;
    notifyListeners();
  }

  void removeAdmin(String userId) {
    final u = _users.firstWhere((u) => u.id == userId);
    u.role = UserRole.user;
    u.permissions = [];
    notifyListeners();
  }
}
