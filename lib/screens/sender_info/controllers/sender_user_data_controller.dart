import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/sender_user_data_repository.dart';
import '../../../models/user.dart' as app;

/// provider to provide UserDataController instance
final senderUserDataControllerProvider =
    Provider.family<SenderUserDataController,String?>((ref,username) {
  final senderUserDataRepository = ref.watch(senderUserDataRepositoryProvider);
  return SenderUserDataController(senderUserDataRepository, username);
});

/// future provider to provide User? instance
final senderUserDataAuthProvider = FutureProvider<app.User?>(
  (ref,) {
    final senderUserDataController = ref.watch(senderUserDataControllerProvider(null));
    return senderUserDataController.getSenderUserData();
  },
);

final removeSenderUserDataAuthProvider = Provider(
  (ref,) {
    final senderUserDataController = ref.watch(senderUserDataControllerProvider(null));
    return senderUserDataController;
  },
);


class SenderUserDataController {
  SenderUserDataController(SenderUserDataRepository senderUserDataRepository,String? username)
      : _senderUserDataRepository = senderUserDataRepository, _username = username;

  final SenderUserDataRepository _senderUserDataRepository;
  final String? _username;

  /// Invoke method to get current user data
  Future<app.User?> getSenderUserData() async {
    return await _senderUserDataRepository.getSenderUserData(_username);
  }

  Future<void> saveSenderUserData() async {
    await _senderUserDataRepository.saveSenderUserData(_username);
  }

  Future<void> removeSenderUserData() async {
     await _senderUserDataRepository.removeSenderUserData();
  }

  // Future<void> saveSenderUserDataToSharePrefernces(){
  //   await 
  // }

  /// invoke to save user data to Firebase.
  // Future<void> saveSenderUserDataToFirebase(
  //   BuildContext context,
  //   bool mounted, {
  //   required String userName,
  //   File? imageFile,
  // }) async =>
  //     await _senderUserDataRepository.saveSenderUserDataToFirebase(
  //       context,
  //       mounted,
  //       userName: userName,
  //       imageFile: imageFile,
  //     );

  Future<void> setSenderUserState(bool isOnline,) async {
    _senderUserDataRepository.setSenderUserState(isOnline,_username);
  }
}
