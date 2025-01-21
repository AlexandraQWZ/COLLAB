import '../database/fbhelper.dart';
import '../widgets/text_form_field.dart';
import 'package:localization/localization.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  FirebaseHelper firebase = FirebaseHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cPasswordController = TextEditingController();

  Future<void> _showMyDialogSignUp(String teks1, String teks2) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(teks2),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(teks1)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JAYA MART"),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(40.0),
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Text("daftar".i18n(), style: const TextStyle(fontSize: 30)),
            const SizedBox(
              height: 40,
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: TextFormField1(
                        controller: _usernameController,
                        label: "email".i18n(),
                        obscure: false,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return "email_eror".i18n();
                          }
                          return null;
                        }),
                  ),
                  SizedBox(
                    height: 100,
                    child: TextFormField1(
                        controller: _passwordController,
                        label: "kata_sandi".i18n(),
                        obscure: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "password_eror".i18n();
                          }
                          return null;
                        }),
                  ),
                  SizedBox(
                    height: 100,
                    child: TextFormField1(
                        controller: _cPasswordController,
                        label: 'konfirmasi'.i18n(),
                        obscure: true,
                        validator: (value) {
                          if (value == null ||
                              value != _passwordController.text) {
                            return "konfirmasi_eror".i18n();
                          }
                          return null;
                        }),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // _formKey.currentState!.save();
                          String uid = await firebase.signUp(
                              _usernameController.text, _passwordController.text);
                          if (uid ==
                              'Email sudah digunakan. Silakan gunakan email lain.') {
                            _showMyDialogSignUp(
                                "email_sudah_ada".i18n(), "judul2".i18n());
                            return;
                          }
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      child: Text('daftar2'.i18n()),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('kalimat2'.i18n(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
