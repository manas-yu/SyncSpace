import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/screens/home_screen.dart';
import 'package:dodoc/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel;
  @override
  void initState() {
    super.initState();
    print("User Data");
    getUserData();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();
    print("getting User Data: ${errorModel!.data}");
    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
      print("User Data");
      print(errorModel!.data!.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
