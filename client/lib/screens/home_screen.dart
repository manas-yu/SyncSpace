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

  String getUserId(WidgetRef ref) {
    return ref.read(userProvider)!.uid;
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    final navigator = Routemaster.of(context);
    final token = ref.read(userProvider)!.token;
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

  void onRemoveDocument(String id, WidgetRef ref) async {
    final token = ref.watch(userProvider)!.token;
    await ref
        .read(documentRepositoryProvider)
        .unshareDocument(ref.read(userProvider)!.token, id);
    ref.refresh(documentRepositoryProvider).getDocuments(token);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(tabs: [
            Tab(
              text: 'My WorkSpaces',
              icon: Icon(Icons.person),
            ),
            Tab(
              text: 'Shared WorkSpaces',
              icon: Icon(Icons.people),
            ),
          ]),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: FutureBuilder<ErrorModel?>(
              future: ref
                  .watch(documentRepositoryProvider)
                  .getDocuments(ref.watch(userProvider)!.token),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                return TabBarView(children: [
                  Center(
                      child: snapshot.data!.data
                                  .where((document) =>
                                      document.uid == getUserId(ref))
                                  .toList()
                                  .length ==
                              0
                          ? const Text(
                              'No Documents To Show!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 35),
                            )
                          : DocumentGrid(
                              onRemoveDocument: null,
                              navigateToDocument: navigateToDocument,
                              documents: snapshot.data!.data
                                  .where((document) =>
                                      document.uid == getUserId(ref))
                                  .toList(),
                              onDeleteFile: deleteDocument)),
                  Center(
                      child: snapshot.data!.data
                                  .where((document) =>
                                      document.uid != getUserId(ref))
                                  .toList()
                                  .length ==
                              0
                          ? const Text(
                              'No Shared Documents',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 35),
                            )
                          : DocumentGrid(
                              onRemoveDocument: onRemoveDocument,
                              navigateToDocument: navigateToDocument,
                              documents: snapshot.data!.data
                                  .where((document) =>
                                      document.uid != getUserId(ref))
                                  .toList(),
                              onDeleteFile: null)),
                ]);
              }),
        ),
      ),
    );
  }
}
