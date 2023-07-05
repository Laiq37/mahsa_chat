import 'package:flutter/material.dart';
// import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/models/user.dart';
import '../repositories/select_receiver_contact_repository.dart';

final selectReceiverContactsControllerProvider =
    FutureProvider.family<List<User>, BuildContext>(
  (ref, context) {
    final selectReceiverContactsRepository =
        ref.watch(selectReceiverContactsRepositoryProvider);
    return selectReceiverContactsRepository.getReceiverContacts(context, ref);
  },
);

final selectReceiverContactControllerProvider = Provider(
  (ref) {
    final selectReceiverContactsRepository =
        ref.watch(selectReceiverContactsRepositoryProvider);
    return SelectReceiverContactController(
        repository: selectReceiverContactsRepository);
  },
);

class SelectReceiverContactController {
  SelectReceiverContactController({
    required SelectReceiverContactsRepository repository,
  }) : _selectContactsRepository = repository;

  final SelectReceiverContactsRepository _selectContactsRepository;

  /// invoke to select specific user if it exists
  // Future<void> selectReceiverContact(
  //   bool mounted,
  //   BuildContext context, {
  //   required User contact,
  // }) async {
  //   String username = contact.username;
  //   return await _selectContactsRepository.selectReceiverContact(
  //     mounted,
  //     context,
  //     username: username,
  //   );
  // }
}
