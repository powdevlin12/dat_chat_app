import 'package:country_picker/country_picker.dart';
import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/common/widgets/custom_button.dart';
import 'package:dat_chat/constant/size.dart';
import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country c) {
        debugPrint(c.phoneCode);
        setState(() {
          country = c;
        });
      },
    );
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    debugPrint('+${country!.phoneCode}$phoneNumber');
    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
      // = Provider.of(context, listen : true) = context.watch<>()
      // Provider ref -> interact provider with provider
      // widget ref -> make widget interact with provider
    } else {
      showSnackbar(context: context, content: 'Please fill all the field');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = getSize(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter your phone number',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('WhatsApp will need to verify your phone number.'),
                Gap(12),
                TextButton(
                  onPressed: pickCountry,
                  child: Text(
                    'Pick country',
                    style: TextStyle(color: tabColor, fontSize: 18),
                  ),
                ),
                Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(country?.phoneCode != null
                        ? '+${country!.phoneCode}'
                        : '+'),
                    Gap(12),
                    SizedBox(
                      width: size.width * 0.75,
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(hintText: 'Phone number'),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                )
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: size.width / 3,
                  child: CustomButton(
                    text: 'NEXT',
                    onPress: sendPhoneNumber,
                  ),
                ),
                Gap(size.height / 16),
              ],
            )
          ],
        ),
      ),
    );
  }
}
