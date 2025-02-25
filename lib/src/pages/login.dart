import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController otpController = TextEditingController();

  bool loading = false;

  void showOTPDialog(BuildContext context) {
    // show a dialog asking the user for their OTP
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 18,
                      ),
                  children: [
                const TextSpan(
                  text: 'Enter the code sent to ',
                ),
                TextSpan(
                    text: emailController.text,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ])),
          content: TextField(
            keyboardType: TextInputType.number,
            controller: otpController,
            decoration: const InputDecoration(
              labelText: 'Your OTP Code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                debugPrint("logging in as ${emailController.text}");
                AuthResponse response = await Supabase.instance.client.auth
                    .verifyOTP(
                        email: emailController.text,
                        token: otpController.text,
                        type: OtpType.email);
                if (response.user != null) {
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/home", (Route<dynamic> route) => false);
                  }
                } else {
                  debugPrint('unable to verify OTP');
                }
                ;
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 72, width: MediaQuery.of(context).size.width),
            const Text(
              'Buzzby',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Location-based microblogging',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FilledButton(
                onPressed: loading
                    ? null
                    : () {
                        setState(() {
                          loading = true;
                        });
                        Supabase.instance.client.auth
                            .signInWithOtp(
                              email: emailController.text,
                            )
                            .then((value) => showOTPDialog(context));
                        setState(() {
                          loading = false;
                        });
                      },
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
