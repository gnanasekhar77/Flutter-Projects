import 'package:APaints_QGen/src/presentation/blocs/auth/auth_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_user.dart';

class AuthImpl implements AuthProvider {
  @override
  Future<void> initialize() async {}

  @override
  AuthUser? get currentUser {}

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    final user = currentUser;
    return user!;
  }

  @override
  Future<void> logOut() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {}
}
