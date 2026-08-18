class Session {
  Session._();

  static String? userId;
  static String? role;
  static String? storeId;
  static String? token;

  static bool get isLoggedIn => userId != null;

  static bool get isCustomer => role == 'customer';

  static void set({
    String? userId,
    String? role,
    String? storeId,
    String? token,
  }) {
    Session.userId = userId;
    Session.role = role;
    Session.storeId = storeId;
    Session.token = token;
  }

  static void clear() {
    userId = null;
    role = null;
    storeId = null;
    token = null;
  }
}
