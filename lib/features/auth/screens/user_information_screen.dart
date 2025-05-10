import 'package:flutter/material.dart';

class UserInfomationScreen extends StatefulWidget {
  static const routeName = '/user-information';
  const UserInfomationScreen({super.key});

  @override
  _UserInfomationScreenState createState() => _UserInfomationScreenState();
}

class _UserInfomationScreenState extends State<UserInfomationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('User infomation screen'),
    );
  }
}
