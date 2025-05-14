import 'package:dat_chat/features/select_contacts/controller/select_contact_controller.dart';
import 'package:dat_chat/screens/error_screen.dart';
import 'package:dat_chat/screens/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectContactScreen extends ConsumerStatefulWidget {
  static const String routeName = 'select-contact';
  const SelectContactScreen({super.key});

  @override
  _SelectContactScreenState createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends ConsumerState<SelectContactScreen> {
  void selectContact(String phoneNumber, BuildContext context) {
    SelectContactController selectContactController =
        ref.read(selectContactControllerProvder);
    selectContactController.selectContact(phoneNumber, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select contact',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      body: ref.watch(getContactProvider).when(
            data: (contactsList) => ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, index) {
                final contact = contactsList[index];
                return InkWell(
                  onTap: () {
                    selectContact(contact.phones[0].number, context);
                  },
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
            error: (err, trace) => ErrorScreen(error: err.toString()),
            loading: () => Loader(),
          ),
    );
  }
}
