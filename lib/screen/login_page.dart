import '../database/fbhelper.dart';
import '../database/provider.dart';
import '../widgets/dashboard_mitra.dart';
import '../widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localization/localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // username = calvins, password = 123456
  // calvin@gmail.com, 12345678
  // adb shell setprop debug.firebase.analytics.app com.example.collab_mitra
  FirebaseHelper firebase = FirebaseHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      firebase.testEventLog('masuk');
    });
  }

  Future<void> _showMyDialogLogin(String teks1, String teks2) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button
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
    final provider = Provider.of<ProviderHelper>(context, listen: true);
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
              Text('masuk'.i18n(), style: const TextStyle(fontSize: 30)),
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
                          label: 'email'.i18n(),
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
                          label: 'kata_sandi'.i18n(),
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "password_eror".i18n();
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
                            String uid = await provider.login(
                                _usernameController.text,
                                _passwordController.text);
                            print('print $uid');
                            if (uid == 'GAGAL') {
                              _showMyDialogLogin(
                                  'akun_tidak_ada'.i18n(), 'judul1'.i18n());
                              return;
                            }
                            await provider.getData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DashboardMitra()),
                            );
                          }
                        },
                        child: Text('masuk2'.i18n()),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text('kalimat1'.i18n(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
