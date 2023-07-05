import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptology/cryptology.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/user.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';

/// provider to get AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
      // FirebaseAuth.instance,
      FirebaseFirestore.instance),
);

class AuthRepository {
  AuthRepository(
      // FirebaseAuth auth,
      FirebaseFirestore firestore)
      :
        // _auth = auth,
        _firestore = firestore;

  // final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Invoke to signIn user with phone number.
  // Future<void> signInWithPhone(
  //   BuildContext context, {
  //   required String phoneNumber,
  // }) async {
  //   try {
  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       verificationCompleted: (_) {},
  //       verificationFailed: (FirebaseAuthException error) {
  //         throw Exception(error.message);
  //       },
  //       codeSent: (String verificationId, int? forceResendingToken) {
  //         Navigator.pushNamed(
  //           context,
  //           AppRoutes.otpScreen,
  //           arguments: verificationId,
  //         );
  //       },
  //       codeAutoRetrievalTimeout: (_) {},
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, content: e.message!);
  //   }
  // }

  Future<String> _ecryptPassword(password) async {
    final passwordEncryption =
        PasswordEncryption.initial(difficulty: HashDifficulty.strong);
    final hashedPwd = await passwordEncryption.hashB64(password);
    return hashedPwd;
  }

  bool _isPasswordMatch(password, decryptPwd) {
    return password == decryptPwd;
  }

  Future<app.User> signinWithUsernamePassword({
    required String username,
    required String password,
  }) async {
    try {
      var userSnapshot = await _firestore
          .collection(StringsConsts.usersCollection)
          .doc(username)
          .get();
      if (userSnapshot.data() == null) throw 'username or password is invalid!';
      var userData = userSnapshot.data();
      password = await _ecryptPassword(password);
      bool isPrimary = _isPasswordMatch(password, userData!["password"]);
      bool isSecondary =
          _isPasswordMatch(password, userData!["secondary_password"]);
      if (!isPrimary && !isSecondary)  throw 'username or password is invalid!';
      app.User  user = app.User.fromMap(userData);
      user.isSecondaryLogin = isSecondary;
      return user;
      
    } on FirebaseException catch (_) {
      rethrow;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> signupWithUsernamePassword({
    required String username,
    required String password,
    required String secondaryPassword,
  }) async {
    try {
      var userSnapshot = await _firestore
          .collection(StringsConsts.usersCollection)
          .doc(username)
          .get();
      if (userSnapshot.data() != null) throw 'user already exist!';
      password = await _ecryptPassword(password);
      secondaryPassword = await _ecryptPassword(secondaryPassword);
      await _firestore
          .collection(StringsConsts.usersCollection)
          .doc(username)
          .set({
        'username': username,
        'password': password,
        'secondary_password': secondaryPassword,
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (err) {
      rethrow;
    }
  }

  /// Invoke to verify otp.
  // Future<void> verifyOTP(
  //   BuildContext context,
  //   bool mounted, {
  //   required String verificationId,
  //   required String smsCode,
  // }) async {
  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );

  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);

  //     if (userCredential.user != null) {
  //       if (!mounted) return;
  //       Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         AppRoutes.userInformationScreen,
  //         (route) => false,
  //       );
  //     } else {
  //       throw Exception('Something went wrong');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, content: e.message!);
  //   }
  // }

  /// invoke to get user data form firestore.
  Stream<app.User> getReceiverUserData(String receiverUserId) {
    return _firestore
        .collection(StringsConsts.usersCollection)
        .doc(receiverUserId)
        .snapshots()
        .map(
          (snapshot) => app.User.fromMap(snapshot.data()!),
        );
  }
}
