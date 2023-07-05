import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chat_app/utils/common/providers/current_user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user.dart' as app;
import '../../../utils/common/repositories/firebase_storage_repository.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';

final senderUserDataRepositoryProvider = Provider<SenderUserDataRepository>(
  (ref) => SenderUserDataRepository(
    firestore: FirebaseFirestore.instance,
    // ref: ref,
  ),
);

class SenderUserDataRepository {
  SenderUserDataRepository({
    required FirebaseFirestore firestore,
    // required ProviderRef ref,
  })  : _firestore = firestore;
        // _ref = ref;

  final FirebaseFirestore _firestore;
  // final ProviderRef _ref;

  /// Invoke method to get current user data
  Future<app.User?> getSenderUserData(username) async {
    app.User? user;
    if (username== null) {
      final sp = await SharedPreferences.getInstance();
      // sp.setString('user', jsonEncode(_ref.read(currentUserProvider!).toMap()));
      username = sp.getString(StringsConsts.user);
    }
    if (username == null) return user;
    final userData = await _firestore
        .collection(StringsConsts.usersCollection)
        .doc(username)
        .get();
    if (userData.data() == null) return user;
    user = app.User.fromMap(userData.data()!);
    // await saveSenderUserData(user.username);
    return user;
  }

  Future<void> saveSenderUserData(username) async {
    final sp = await SharedPreferences.getInstance();
    sp.setString(StringsConsts.user, username);
  }

  Future<void> removeSenderUserData()async{
    final sp = await SharedPreferences.getInstance();
    sp.remove(StringsConsts.user);
  }
  /// invoke to save user data to Firebase.
  // Future<void> saveSenderUserDataToFirebase(
  //   BuildContext context,
  //   bool mounted, {
  //   required String userName,
  //   File? imageFile,
  // }) async {
  //   try {
  //     String uId = _auth.currentUser!.uid;
  //     String? photoUrl;

  //     if (imageFile != null) {
  //       // uploading image file to cloud storage and get its url.
  //       photoUrl = await _ref
  //           .read(firebaseStorageRepositoryProvider)
  //           .storeFileToFirebaseStorage(
  //             context,
  //             file: imageFile,
  //             path: 'profilePic',
  //             fileName: uId,
  //           );
  //     }

  //     // creating user instance.
  //     app.User user = app.User(
  //       username: userName,
  //       // uid: uId,
  //       isOnline: true,
  //       // profilePic: photoUrl,
  //       // groupId: [],
  //       // phoneNumber: _auth.currentUser!.phoneNumber!,
  //     );

  //     // saving user to firestore.
  //     await _firestore
  //         .collection(StringsConsts.usersCollection)
  //         .doc(uId)
  //         .set(user.toMap());

  //     if (!mounted) return;
  //     // navigating to home screen if everything works well
  //     Navigator.pushNamedAndRemoveUntil(
  //       context,
  //       AppRoutes.homeScreen,
  //       (route) => false,
  //     );
  //   } catch (e) {
  //     showSnackBar(context, content: e.toString());
  //   }
  // }

  Future<void> setSenderUserState(bool isOnline, username) async {
    await _firestore
        .collection(StringsConsts.usersCollection)
        .doc(username)
        .update({
      'isOnline': isOnline,
    });
  }
}
