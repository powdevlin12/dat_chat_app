import 'package:dat_chat/colors.dart';
import 'package:flutter/material.dart';

class ListChatScreen extends StatefulWidget {
  static const routeName = 'list-chat-screen';
  const ListChatScreen({super.key});

  @override
  _ListChatScreenState createState() => _ListChatScreenState();
}

class _ListChatScreenState extends State<ListChatScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 20, color: Colors.grey),
          ),
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'CHAT'),
              Tab(text: 'STATUS'),
              Tab(text: 'CONTACT'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: [
            Center(child: Text('Chat')),
            Center(child: Text('Status')),
            Center(child: Text('Contact')),
          ],
        ),
      ),
    );
  }
}
