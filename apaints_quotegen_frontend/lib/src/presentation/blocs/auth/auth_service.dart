import 'package:APaints_QGen/src/presentation/blocs/auth/auth_provider.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_user.dart';
import 'package:APaints_QGen/src/presentation/blocs/auth/auth_impl.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  // factory AuthService.firebase() => AuthService(AuthImpl());

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
