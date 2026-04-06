import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/helper/api/api_service.dart';
import 'package:marken/helper/shared_pref/app_pref.dart';
import 'package:marken/screens/home_screen/home_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/media_query.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please enter username and password');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.login(
      username: username,
      password: password,
    );

    setState(() => isLoading = false);

    if (response != null && response.data.isNotEmpty) {
      final user = response.data.first;

      /// SAVE LOGIN DATA
      await AppPref.saveLogin(
        userSrNo: user.usersrno,
        employeeType: user.employeeType,
        name: user.name,
        employeeSrNo: user.employeesrno,
      );

      /// NAVIGATE
      Navigator.pushReplacement(
        context,
        AnimatedPageRoute(page: const HomeScreen()),
      );
    } else {
      setState(() => errorMessage = "Invalid username or password");
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MQ.width(context) * 0.08;
    final logoWidth = MQ.width(context) * 0.3;

    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: MQ.height(context) * 0.08),
                Image.asset(
                  "assets/images/marken-app-logo.png",
                  width: logoWidth,
                ),
                // Text(
                //   "Marken",
                //   style: TextStyle(
                //     fontSize: 24.sp,
                //     fontWeight: FontWeight.w600,
                //     color: AppColor.primaryBlue,
                //   ),
                // ),
                SizedBox(height: MQ.height(context) * 0.04),

                // Username field
                _buildTextField(usernameController, "Username", false),
                SizedBox(height: 16.h),

                // Password field
                _buildTextField(passwordController, "Password", true),
                SizedBox(height: 20.h),

                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(color: AppColor.errorColor, fontSize: 13),
                  ),
                SizedBox(height: 18.h),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: isLoading ? null : _onLogin,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isPassword,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.textFieldBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => isPasswordVisible = !isPasswordVisible),
                )
              : null,
        ),
      ),
    );
  }
}
