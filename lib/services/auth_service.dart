import 'package:shared_preferences/shared_preferences.dart';
import 'package:safepath/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    // Mock authentication - in real app, this would call an API
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate login validation
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      final userId = email.hashCode.toString();
      
      _currentUser = UserModel(
        id: userId,
        name: email.split('@')[0],
        email: email,
        joinDate: DateTime.now(),
      );
      
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUserName, _currentUser!.name);
      await prefs.setString(_keyUserEmail, email);
      
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    // Mock signup - in real app, this would call an API
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate signup validation
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      final userId = email.hashCode.toString();
      
      _currentUser = UserModel(
        id: userId,
        name: name,
        email: email,
        joinDate: DateTime.now(),
      );
      
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUserName, name);
      await prefs.setString(_keyUserEmail, email);
      
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    _currentUser = null;
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      
      if (isLoggedIn) {
        final userId = prefs.getString(_keyUserId) ?? '';
        final userName = prefs.getString(_keyUserName) ?? '';
        final userEmail = prefs.getString(_keyUserEmail) ?? '';
        
        if (userId.isNotEmpty) {
          _currentUser = UserModel(
            id: userId,
            name: userName,
            email: userEmail,
            joinDate: DateTime.now(),
          );
        }
      }
    } catch (e) {
      // Failed to load user, start fresh
      _currentUser = null;
    }
  }
}

