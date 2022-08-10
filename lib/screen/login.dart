import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:two_factor/screen/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String verificationCode = "", countryCode = "";

  @override
  void initState() {
    super.initState();
  }

  TextEditingController textEditingController = TextEditingController();
  TextEditingController codeTextEditingController = TextEditingController();

  login() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //  await auth.setSettings(appVerificationDisabledForTesting: true);
    await auth.verifyPhoneNumber(
      phoneNumber: "+$countryCode${textEditingController.text}",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        showMessage(e.message.toString(), false);
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationCode = verificationId;
        showMessage('Code Sent', true);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                verificationCode: verificationCode,
              ),
            ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showMessage('Code Auto Retrieval Timeout', false);
      },
    );
  }

  void showMessage(String message, bool status) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_LEFT,
        backgroundColor: status ? Colors.green : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Factor Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              child: TextField(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode:
                        true, // optional. Shows phone code before the country name.
                    onSelect: (Country country) {
                      setState(() {
                        codeTextEditingController.text = country.displayName;
                        countryCode = country.phoneCode;
                      });
                    },
                  );
                },
                controller: codeTextEditingController,
                readOnly: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Country Code',
                  contentPadding: EdgeInsets.only(left: 8, right: 8),
                  label: Text('Country Code'),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0,
                    ),
                  ),
                ),
                autofocus: false,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              child: TextFormField(
                controller: textEditingController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  contentPadding: EdgeInsets.only(left: 8, right: 8),
                  label: Text('Phone Number'),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0,
                    ),
                  ),
                ),
                autofocus: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {
                  login();
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
