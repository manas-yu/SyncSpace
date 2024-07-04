import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/models/file_model.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileScreen extends ConsumerStatefulWidget {
  final String roomId;
  const FileScreen({super.key, required this.roomId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FileScreenState();
}

class _FileScreenState extends ConsumerState<FileScreen> {
  ErrorModel? errorModel;
  final List<FileModel> _loadedFiles = [];
  void fetchFiles(String token, String roomId) async {
    errorModel = await ref
        .read(filesRepositoryProvider)
        .getFiles(token: token, id: roomId);
    if (errorModel != null) {
      setState(() {
        _loadedFiles.addAll(errorModel!.data as List<FileModel>);
      });
    }
  }

  String getUserId() {
    return ref.read(userProvider)!.uid;
  }

  @override
  void initState() {
    super.initState();
    fetchFiles(ref.read(userProvider)!.token, widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Share Files'),
            bottom: const TabBar(tabs: [
              Tab(
                text: 'My Files',
                icon: Icon(Icons.person),
              ),
              Tab(
                text: 'Shared Files',
                icon: Icon(Icons.people),
              ),
            ]),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: () {
                  // Add your onPressed code here!
                },
              ),
            ],
          ),
          body: TabBarView(children: [
            Container(
              color: Colors.purple,
              child: const Center(
                child: Text('My Files'),
              ),
            ),
            Container(
              color: Colors.green,
              child: const Center(
                child: Text('Shared Files'),
              ),
            ),
          ]),
        ));
  }
}
