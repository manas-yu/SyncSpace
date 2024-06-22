import 'package:dodoc/colors.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.errorMessage == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator
          .push(MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      sMessenger.showSnackBar(SnackBar(
        content: Text(errorModel.errorMessage!),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 50),
              backgroundColor: Colors.white,
            ),
            onPressed: () {
              signInWithGoogle(ref, context);
            },
            icon: Image.asset(
              'assets/images/g-logo-2.png',
              height: 20,
            ),
            label: const Text(
              'Sign in with Google',
              style: TextStyle(color: kBlackColor),
            )),
      ),
    );
  }
}
