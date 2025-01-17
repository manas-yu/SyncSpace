import 'package:dodoc/colors.dart';
import 'package:dodoc/common/widgets/loader.dart';
import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/repository/document_repository.dart';
import 'package:dodoc/widgets/document_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    final navigator = Routemaster.of(context);
    final token = ref.watch(userProvider)!.token;
    final sMessenger = ScaffoldMessenger.of(context);
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data!.id}');
    } else {
      sMessenger
          .showSnackBar(SnackBar(content: Text(errorModel.errorMessage!)));
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  void deleteDocument(
      WidgetRef ref, String documentId, BuildContext context) async {
    final token = ref.watch(userProvider)!.token;
    final sMessenger = ScaffoldMessenger.of(context);
    final errorModel = await ref
        .read(documentRepositoryProvider)
        .deleteDocument(token, documentId);
    if (errorModel.errorMessage != null) {
      sMessenger
          .showSnackBar(SnackBar(content: Text(errorModel.errorMessage!)));
      return;
    }
    ref.refresh(documentRepositoryProvider).getDocuments(token);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My WorkSpaces'),
        actions: [
          IconButton(
            onPressed: () => createDocument(ref, context),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(Icons.logout, color: kRedColor),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: kGreyColor,
                width: 0.1,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: FutureBuilder<ErrorModel?>(
            future: ref
                .watch(documentRepositoryProvider)
                .getDocuments(ref.watch(userProvider)!.token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Center(
                  child: snapshot.data!.data.length == 0
                      ? const Text(
                          'No Documents To Show!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35),
                        )
                      : DocumentGrid(
                          navigateToDocument: navigateToDocument,
                          documents: snapshot.data!.data,
                          onDeleteFile: deleteDocument));
            }),
      ),
    );
  }
}
