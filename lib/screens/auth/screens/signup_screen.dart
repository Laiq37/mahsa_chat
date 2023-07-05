import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/utils/constants/colors_constants.dart';

import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/common/widgets/round_button.dart';
import '../../../utils/constants/assets_constants.dart';
import '../../../utils/constants/routes_constants.dart';
import '../controllers/auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late Size _size;
  late final TextEditingController _usernameTFController;
  late final TextEditingController _passwordTFController;
  late final TextEditingController _secondaryPasswordTFController;
  bool _isLoading = false;
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameTFController = TextEditingController();
    _passwordTFController = TextEditingController();
    _secondaryPasswordTFController = TextEditingController();
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
        ? "enter a valid username"
        : null;
  }

  String? _isPasswordValid(String? password) {
    return password == null || password.trim() == ""
        ? "password is required"
        : password.length < 4
            ? 'password must contain 4 characters'
            : null;
  }

  String? _isSecondayPasswordValid(sPass) {
    return sPass == null || sPass.trim() == ""
        ? "seconday password is required"
        : sPass.length < 4
            ? 'password must contain 4 characters'
            : sPass.trim() == _passwordTFController.text.trim()
                ? 'passwords should not match'
                : null;
  }

  void _login() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.loginScreen,
    );
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authController = ref.read<AuthController>(authControllerProvider);
    try {
      await authController
          .signupWithUsernamePassword(
        username: _usernameTFController.text,
        password: _passwordTFController.text,
        secondaryPassword: _secondaryPasswordTFController.text,
      )
          .then((_) {
        showSnackBar(context, content: 'Account has been created successfully');
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.loginScreen,
        );
      });
    } on FirebaseException catch (err) {
      showSnackBar(context, content: err.message!);
    } catch (err) {
      showSnackBar(context, content: err.toString());
    } finally {
      if (!mounted) setState(() => _isLoading = false);
    }
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
        'Create Account',
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
                addVerticalSpace(_size.width * 0.1),
                RoundButton(
                  text: 'Signup',
                  onPressed: _signup,
                ),
                RoundButton(
                  text: 'Already have an account?',
                  onPressed: _login,
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
      'Connect and chat. Sign up today.',
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
        ImagesConsts.icLanding1,
        width: _size.width * 0.8,
        height: _size.width * 0.75,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildUsernameTF(),
          addVerticalSpace(_size.width * 0.05),
          _buildPasswordTF(),
          addVerticalSpace(_size.width * 0.05),
          _buildPasswordTF(true),
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

  Widget _buildPasswordTF([
    bool isSecondary = false,
  ]) {
    return SizedBox(
      width: _size.width * 0.7,
      child: TextFormField(
        controller: isSecondary
            ? _secondaryPasswordTFController
            : _passwordTFController,
        maxLines: 1,
        minLines: 1,
        obscureText:_isObscure,
        keyboardType: TextInputType.text,
        validator: isSecondary ? _isSecondayPasswordValid : _isPasswordValid,
        decoration: InputDecoration(
            hintText: isSecondary ? 'seconday password' : 'password',
            hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.grey,
                  fontSize: _size.width * 0.04,
                  fontWeight: FontWeight.normal,
                ),
            suffixIcon: GestureDetector(
              onTap: !isSecondary ? _togglePasswordView : null,
              child: isSecondary
                  ? const Icon(Icons.help)
                  :  Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
            )),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.black,
              fontSize: _size.width * 0.05,
            ),
      ),
    );
  }
}
