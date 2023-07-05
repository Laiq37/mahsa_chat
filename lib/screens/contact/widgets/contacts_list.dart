import 'package:flutter/material.dart';
// import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';
import '../controllers/select_receiver_contacts_controller.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({
    super.key,
    required this.contactsList,
  });

  final List<User> contactsList;

  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.contactsList.length,
      itemBuilder: (context, index) => getListItem(
        widget.contactsList[index],
      ),
    );
  }

  Widget getListItem(User receiverContact) {
    String name = receiverContact.username;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: () => _selectContact(receiverContact),
          title: Text(name),
          leading: const  CircleAvatar(
                  backgroundImage: NetworkImage('https://images.pexels.com/photos/13728847/pexels-photo-13728847.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                ),
        ),
        const Divider(
          indent: 50.0,
          endIndent: 50.0,
          height: 1.0,
        ),
      ],
    );
  }

  void _selectContact(User receiverContact)  {
    Navigator.pushReplacementNamed(
          context,
          AppRoutes.chatScreen,
          arguments: <String, Object>{
            StringsConsts.username: receiverContact.username,
            // StringsConsts.userId: receiverUser.uid,
            // StringsConsts.profilePic: receiverUser.profilePic,
            StringsConsts.isGroupChat: false,
          },
        );
    // await ref
    //     .read(selectReceiverContactControllerProvider)
    //     .selectReceiverContact(
    //       mounted,
    //       context,
    //       contact: contact,
    //     );
  }
}
