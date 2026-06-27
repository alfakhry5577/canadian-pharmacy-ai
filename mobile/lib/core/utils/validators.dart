class Validators {
  Validators._();

  static String? required(String? value, {String message = 'هذا الحقل مطلوب'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    final pattern = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value.trim())) return 'بريد إلكتروني غير صالح';
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value.length < minLength) return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'كلمتا المرور غير متطابقتين';
    return null;
  }
}
