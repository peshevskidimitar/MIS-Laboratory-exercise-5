import 'package:exam_schedule/widgets/login_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/register_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedRegister: toggle)
      : RegisterWidget(onClickedLogin: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}
