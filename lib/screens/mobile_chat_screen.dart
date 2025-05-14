import 'package:flutter/material.dart';

class MobileChatScreen extends StatefulWidget {
  static const routeName = 'mobile-chat';
  const MobileChatScreen({super.key});

  @override
  _MobileChatScreenState createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends State<MobileChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat app"),
      ),
    );
  }
}
