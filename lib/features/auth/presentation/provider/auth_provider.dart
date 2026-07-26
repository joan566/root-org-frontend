import 'package:flutter/cupertino.dart';
import '../../domain/entities/login_sesion.dart';
import '../../domain/entities/user.dart';

class AuthProvider extends ChangeNotifier {
  LoginSesion? _session;

  LoginSesion? get session => _session;

  bool get isLogged => _session != null;

  void login(LoginSesion session) {
    _session = session;
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }

  void refreshSession() {
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    if (_session == null) return;

    _session = LoginSesion(
      token: _session!.token,
      hasTenant: _session!.hasTenant,
      user: updatedUser,
    );

    notifyListeners();
  }
}