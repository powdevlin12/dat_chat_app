import 'package:dat_chat/colors.dart';
import 'package:dat_chat/features/create_group/create_group_screen.dart';
import 'package:dat_chat/features/list_chat/widgets/list_chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dat_chat/l10n/app_localizations.dart';

class ListChatScreen extends ConsumerStatefulWidget {
  static const routeName = 'list-chat-screen';
  const ListChatScreen({super.key});

  @override
  _ListChatScreenState createState() => _ListChatScreenState();
}

class _ListChatScreenState extends ConsumerState<ListChatScreen>
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

  void _handleNavigateCreategroup() {
    Navigator.pushNamed(context, CreateGroupScreen.routeName);
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
                fontWeight: FontWeight.w600, fontSize: 22, color: Colors.grey),
          ),
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: Coloors.tabColor,
            indicatorWeight: 4,
            labelColor: Coloors.tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.chat),
              Tab(text: 'STATUS'),
              Tab(text: 'CONTACT'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _handleNavigateCreategroup,
          foregroundColor: Coloors.textColor,
          backgroundColor: Coloors.tabColor,
          shape: CircleBorder(),
          child: const Icon(Icons.message),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: [
            ListChatWidget(),
            Center(child: Text('Status')),
            Center(child: Text('Contact')),
          ],
        ),
      ),
    );
  }
}
