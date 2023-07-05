import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/common/helper_methods/util_methods.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/colors_constants.dart';
import '../../../utils/constants/routes_constants.dart';

class HomeFAB extends StatefulWidget {
  const HomeFAB({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  @override
  State<HomeFAB> createState() => _HomeFABState();
}

class _HomeFABState extends State<HomeFAB> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(
      () {
        setState(() {
          widget.tabController.indexIsChanging;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.tabController.index !=0 ? const SizedBox() : FloatingActionButton(
      onPressed: () {
        switch (widget.tabController.index) {
          //if needed chat feature then uncomment commented cases, and comment uncommented cases
          // case 0:
          //   Navigator.pushNamed(context, AppRoutes.selectContactScreen);
          //   break;
          // case 1:
          //   Navigator.pushNamed(context, AppRoutes.createGroupScreen);
          //   break;
          case 0:
            Navigator.pushNamed(context, AppRoutes.createGroupScreen);
            break;
          // case 2:
          //   break;
          case 1:
            break;
          default:
            Navigator.pushNamed(context, AppRoutes.errorScreen);
        }
      },
      child: const Icon(
        // widget.tabController.index == 0
        //     ? Icons.chat
        //     : widget.tabController.index == 1
        //         ? Icons.group_add
        //         : Icons.call,
        Icons.group_add,
      ),
    );
  }

  // void _selectAndConfirmImage() async {
  //   File? imageFile = await pickImageFromGallery(context);
  //   if (imageFile != null) {
  //     if (!mounted) return;
  //     Navigator.pushNamed(
  //       context,
  //       AppRoutes.confirmStatusScreen,
  //       arguments: imageFile,
  //     );
  //   } else {
  //     if (!mounted) return;
  //     showSnackBar(context, content: 'Image not selected');
  //   }
  // }
}
