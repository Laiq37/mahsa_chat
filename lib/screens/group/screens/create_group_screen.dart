import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/models/group.dart';
import 'package:lets_chat/models/user.dart';
import 'package:lets_chat/utils/common/providers/current_user_provider.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/common/helper_methods/util_methods.dart';
import '../../../utils/common/widgets/loader.dart';
import '../../../utils/constants/assets_constants.dart';
import '../../../utils/constants/colors_constants.dart';
import '../controllers/group_controller.dart';
import '../state/group_list_state.dart';
import '../widgets/group_contacts_list.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  late TextEditingController _groupNameController;
  Size? _size;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size ??= MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme.copyWith(
            color: AppColors.onPrimary,
          ),
      title: Text(
        'Create Group',
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: AppColors.onPrimary,
              fontSize: 18.0,
            ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Center(
        child: SizedBox(
          width: _size!.width * 0.90,
          height: _size!.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              addVerticalSpace(_size!.width * 0.03),
              _buildProfileImage(),
              addVerticalSpace(_size!.width * 0.03),
              _buildNameTF(),
              addVerticalSpace(_size!.width * 0.04),
              _buildSelectContactHeading(),
              _buildGroups()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectContactHeading() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Find Group',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 18.0,
            ),
      ),
    );
  }

  Widget _buildNameTF() {
    return TextField(
      controller: _groupNameController,
      // onChanged: _onChangedText,
      minLines: 1,
      maxLines: 1,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.group),
        hintText: 'Enter Group Name',
        hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.grey,
              fontSize: _size!.width * 0.04,
              fontWeight: FontWeight.normal,
            ),
        isDense: true,
      ),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.black,
            fontSize: _size!.width * 0.05,
          ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _imageFile != null
            ? CircleAvatar(
                backgroundImage: FileImage(_imageFile!),
                radius: _size!.width * 0.15,
                backgroundColor: AppColors.white,
              )
            : CircleAvatar(
                backgroundImage:
                    const AssetImage(ImagesConsts.icUserNotSelected),
                radius: _size!.width * 0.15,
                backgroundColor: AppColors.white,
              ),
        Positioned(
          top: (_size!.width * 0.35) * 0.55,
          left: (_size!.width * 0.35) * 0.55,
          child: IconButton(
            onPressed: _selectImage,
            icon: Icon(
              Icons.add_a_photo,
              size: _size!.width * 0.075,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroups() {
    return Expanded(
      child: Consumer(
        builder: (consumerContext, ref, child) {
          GroupListState state = ref.watch(groupListStateProvider(context));
          if (state is LoadingGroupListState) {
            return const Loader();
          } else
          // if (state is GetAllGroupListState) {
          //   return ListView.builder(
          //     itemCount: state.groupList.length,
          //     itemBuilder: (context, index) =>
          //         getListItem(state.groupList[index], index, state),
          //   );
          // } else
          if (state is SearchedGroupListState) {
            return state.searchedQueryList.isEmpty
                ? _buildNotFound()
                : ListView.builder(
                    itemCount: state.searchedQueryList.length,
                    itemBuilder: (context, index) => getListItem(
                        state.searchedQueryList[index], index, state),
                  );
          } else if (state is ErrorGroupListState) {
            return Text(state.errorMessage);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildNotFound() {
    return const Center(
      child: Icon(
        Icons.search_off,
        size: 160,
        color: AppColors.grey,
      ),
    );
  }

  Widget getListItem(Group group, int index, state) {
    String name = group.groupName;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
            title: Text(name),
            leading: CircleAvatar(
              backgroundImage: group.groupProfilePic == null
                  ? null
                  : NetworkImage(
                      group.groupProfilePic!,
                    ),
              backgroundColor: AppColors.primary,
              child: group.groupProfilePic != null
                  ? null
                  : const Icon(
                      Icons.group,
                      color: AppColors.white,
                      size: 24,
                    ),
            ),
            trailing: group.isGroupJoined
                ? const Text('Joined')
                : group.isJoinRequested
                    ? const Text('Request sent')
                    : TextButton(
                        onPressed: () {
                          String username =
                              ref.read(currentUserProvider!).username;
                          ref
                              .read(groupControllerProvider)
                              .groupJoinReq(name, group.memberRequests!);
                          ref
                              .read(groupListStateProvider(context).notifier)
                              .updateMemberReq(
                                  name,
                                  state,
                                  username,
                                  state is SearchedGroupListState
                                      ? _groupNameController.text
                                      : null);
                        },
                        child: const Text('Join'))
            // selectedContactsIndexList.contains(index)
            //     ? const Icon(
            //         Icons.done,
            //         color: AppColors.black,
            //       )
            //     : null,
            ),
        const Divider(
          indent: 50.0,
          endIndent: 50.0,
          height: 1.0,
        ),
      ],
    );
  }

  void _selectImage() async {
    _imageFile = await pickImageFromGallery(context);
    setState(() {});
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => _onSearchText(_groupNameController.text),
          heroTag: null,
          child: const Icon(Icons.search),
        ),
        SizedBox(
          height: _size!.height * 0.01,
        ),
        FloatingActionButton(
          onPressed: createGroup,
          heroTag: null,
          child: const Icon(Icons.done),
        ),
      ],
    );
  }

  void createGroup() async {
    if (_groupNameController.text.trim().isNotEmpty
        // && _imageFile != null
        ) {
      try {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Loader(),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Creating group',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: AppColors.primary,
                              ))
                    ],
                  ),
                ),
              );
            });
        await ref.read(groupControllerProvider).createGroup(
              context,
              mounted,
              groupName: _groupNameController.text.trim(),
              groupProfilePic: _imageFile,
              // selectedContacts:
              //     ref.read<List<User>>(selectedContactsGroupProvider),
            );

        ref.read(selectedContactsGroupProvider.state).state = [];
      } catch (err) {
        showSnackBar(context, content: err.toString());
      } finally {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

//_onChangedText to _onSearchText
  void _onSearchText(String value) {
    ref
        .read(groupListStateProvider(context).notifier)
        .getSearchedgroupsList(value);
  }
}
