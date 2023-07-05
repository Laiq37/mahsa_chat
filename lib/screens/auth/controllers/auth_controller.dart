import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../../models/user.dart' as app;

final authControllerProvider = Provider<AuthController>(
  (ref) {
    final authRepository = ref.watch<AuthRepository>(authRepositoryProvider);
    return AuthController(authRepository);
  },
);

class AuthController {
  AuthController(AuthRepository authRepository)
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  /// Invoke to signIn user with phone number.
  // Future<void> signInWithPhone(
  //   BuildContext context, {
  //   required String phoneNumber,
  // }) async =>
  //     await _authRepository.signInWithPhone(
  //       context,
  //       phoneNumber: phoneNumber,
  //     );


  Future<app.User> signinWithUsernamePassword( {
    required String username,
    required String password,
  }) async =>
      await _authRepository.signinWithUsernamePassword(
        username: username.trim(),
        password: password.trim(),
      );

  Future<void> signupWithUsernamePassword( {
    required String username,
    required String password,
    required String secondaryPassword,
  }) async =>
      await _authRepository.signupWithUsernamePassword(
          username: username.trim(),
          password: password.trim(),
          secondaryPassword: secondaryPassword.trim());

  /// Invoke to signIn user with phone number.
  // Future<void> verifyOTP(
  //   BuildContext context,
  //   bool mounted, {
  //   required String verificationId,
  //   required String smsCode,
  // }) async =>
  //     await _authRepository.verifyOTP(
  //       context,
  //       mounted,
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );

  /// invoke to get user data form firestore.
  Stream<app.User> getReceiverUserData(String receiverUserId) {
    return _authRepository.getReceiverUserData(receiverUserId);
  }
}
