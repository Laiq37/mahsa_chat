import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/screens/sender_info/controllers/sender_user_data_controller.dart';
import 'package:lets_chat/utils/common/providers/current_user_provider.dart';
import 'package:lets_chat/utils/constants/colors_constants.dart';
import '../../../models/user.dart' as app;
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/common/widgets/round_button.dart';
import '../../../utils/constants/assets_constants.dart';
import '../../../utils/constants/routes_constants.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late Size _size;
  late final TextEditingController _usernameTFController;
  late final TextEditingController _passwordTFController;
  bool _isLoading = false;
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameTFController = TextEditingController();
    _passwordTFController = TextEditingController();
    // currentUserProvider = null;
  }

  @override
  void dispose() {
    _usernameTFController.dispose();
    super.dispose();
  }

  void _togglePasswordView(){
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  String? _isUsernameValid(username) {
    return username == null || username.trim() == ""
        ? "username is required"
        : null;
  }

  String? _isPasswordValid(String? password) {
    return password == null || password.trim() == ""
        ? "password is required"
        : null;
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authController = ref.read<AuthController>(authControllerProvider);
      var  user = await authController.signinWithUsernamePassword(
        username: _usernameTFController.text,
        password: _passwordTFController.text,
      );
      if ( mounted) {
        // user.isSecondaryLogin = isSecondaryLogin;
        currentUserProvider ??= Provider((ref) => user);
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.homeScreen,
        );
      //  await ref
      //     .watch(senderUserDataControllerProvider(_usernameTFController.text.trim()))
      //     .saveSenderUserData();
      }
    } on FirebaseException catch (_) {
      showSnackBar(context, content: 'Something went wrong!');
    } catch (err) {
      showSnackBar(context, content: err.toString());
    }
    setState(() => _isLoading = false);
  }

  void _signup() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.signupScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme.copyWith(
            color: AppColors.onPrimary,
          ),
      title: Text(
        'Enter Login Credientials',
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: AppColors.onPrimary,
              fontSize: 18.0,
            ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                addVerticalSpace(_size.width * 0.05),
                _buildInfoText(),
                addVerticalSpace(_size.width * 0.05),
                _buildHeroImage(),
                _buildForm(),
                addVerticalSpace(_size.width * 0.2),
                RoundButton(
                  text: 'Login',
                  onPressed: _login,
                ),
                RoundButton(
                  text: 'Create new account',
                  onPressed: _signup,
                  color: AppColors.lightBlack,
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Positioned(
            child: Container(
              alignment: Alignment.center,
              width: _size.width,
              height: _size.height,
              color: const Color.fromRGBO(128, 128, 128, 0.6),
              child: const CircularProgressIndicator(
                color: AppColors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoText() {
    return Text(
      'Sign in to start chatting and stay connected',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.black,
            fontSize: _size.width * 0.035,
          ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      child: Image.asset(
        ImagesConsts.icLanding2,
        width: _size.width,
        height: _size.width * 0.7,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildUsernameTF(),
          addVerticalSpace(_size.width * 0.08),
          _buildPasswordTF(),
        ],
      ),
    );
  }

  Widget _buildUsernameTF() {
    return SizedBox(
      width: _size.width * 0.7,
      child: TextFormField(
        controller: _usernameTFController,
        maxLines: 1,
        minLines: 1,
        keyboardType: TextInputType.text,
        validator: _isUsernameValid,
        decoration: InputDecoration(
          hintText: 'username',
          hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.grey,
                fontSize: _size.width * 0.04,
                fontWeight: FontWeight.normal,
              ),
        ),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.black,
              fontSize: _size.width * 0.05,
            ),
      ),
    );
  }

  Widget _buildPasswordTF() {
    return SizedBox(
      width: _size.width * 0.7,
      child: TextFormField(
        controller: _passwordTFController,
        maxLines: 1,
        minLines: 1,
        obscureText: _isObscure,
        keyboardType: TextInputType.text,
        validator: _isPasswordValid,
        decoration: InputDecoration(
          hintText: 'password',
          hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.grey,
                fontSize: _size.width * 0.04,
                fontWeight: FontWeight.normal,
              ),
           suffixIcon: InkWell(
            enableFeedback: false,
                onTap: _togglePasswordView,
                child: Icon(
                        _isObscure 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                    ),
                ),
        ),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.black,
              fontSize: _size.width * 0.05,
            ),
      ),
    );
  }
}
