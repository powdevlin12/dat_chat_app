import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/features/create_group/create_group_controller.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

final searchUserProvider = FutureProvider.family<UserModel?, String>(
  (ref, phoneNumber) async {
    final controller = ref.watch(createGroupControllerProvider);
    return await controller.getUserByPhone(phoneNumber);
  },
);

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchByPhoneController =
      TextEditingController();
  List<UserModel> listMember = [];
  String? _searchPhone;

  void _addMember(UserModel user) {
    if (listMember.contains(user)) {
      showSnackbar(context: context, content: 'User already in group');
      setState(() {
        _searchPhone = null;
        _searchByPhoneController.text = '';
      });
      return;
    }
    setState(() {
      listMember.add(user);
      _searchPhone = null;
      _searchByPhoneController.text = '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchByPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create new group',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint(_searchByPhoneController.text);
        },
        foregroundColor: Coloors.textColor,
        backgroundColor: Coloors.tabColor,
        shape: CircleBorder(),
        child: const Icon(Icons.send),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name group',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              Gap(8),
              SizedBox(
                height: 46,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter name group...',
                    hintStyle: TextStyle(fontSize: 14),
                    filled: true,
                    fillColor: Coloors.bgMessageReply,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Gap(8),
              Text(
                'Search by phone',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              Gap(8),
              SizedBox(
                height: 46,
                child: TextField(
                  controller: _searchByPhoneController,
                  keyboardType: TextInputType.phone,
                  onSubmitted: (value) {
                    final phone = value.trim();
                    debugPrint("------- debug phone: $phone");
                    if (phone.isNotEmpty) {
                      setState(() {
                        _searchPhone = phone;
                      });
                      ref.invalidate(searchUserProvider(phone));
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Phone...',
                    hintStyle: TextStyle(fontSize: 14),
                    filled: true,
                    fillColor: Coloors.bgMessageReply,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Iconsax.user_search,
                      color: Coloors.textColor,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Gap(8),
              if (_searchPhone != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Consumer(builder: (context, ref, child) {
                    final userAsync =
                        ref.watch(searchUserProvider(_searchPhone!));
                    return userAsync.when(
                      data: (user) {
                        if (user != null) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Coloors.bgMessageReply,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                width: 80,
                                height: 38,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      _addMember(user);
                                    },
                                    child: Text(
                                      'Add',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Coloors.textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text('Không tìm thấy người dùng');
                        }
                      },
                      error: (error, _) => Text('Error'),
                      loading: () => const CircularProgressIndicator(),
                    );
                  }),
                ),
              Gap(8),
              Container(
                decoration: BoxDecoration(
                  color: Coloors.bgMessageReply,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'List members',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Gap(12),
                    if (listMember.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: listMember.length,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                listMember[index].name,
                                style: TextStyle(fontSize: 14),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Coloors.bgMessageReply,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                width: 80,
                                height: 36,
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        listMember.removeAt(index);
                                      });
                                    },
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Coloors.redColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
