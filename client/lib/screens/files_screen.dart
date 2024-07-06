import 'package:dodoc/common/widgets/loader.dart';
import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/models/file_model.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/repository/files_repository.dart';
import 'package:dodoc/repository/socket_repository.dart';
import 'package:dodoc/widgets/files_tab.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileScreen extends ConsumerStatefulWidget {
  final String roomId;
  const FileScreen({super.key, required this.roomId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FileScreenState();
}

class _FileScreenState extends ConsumerState<FileScreen> {
  SocketRepository socketRepository = SocketRepository();
  ErrorModel? errorModelFetchingFiles;
  var uploading = false;
  final List<FileModel> _loadedFiles = [];
  void setFileListener() {
    socketRepository.receiveFileListener((data) {
      final file = FileModel.fromJson(data['sharedFile']);
      if (mounted) {
        setState(() {
          _loadedFiles.add(file);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFiles();
      setFileListener();
    });
  }

  void fetchFiles() async {
    errorModelFetchingFiles = await ref
        .read(filesRepositoryProvider)
        .getFiles(token: ref.read(userProvider)!.token, id: widget.roomId);
    if (errorModelFetchingFiles != null) {
      setState(() {
        _loadedFiles.addAll(errorModelFetchingFiles!.data as List<FileModel>);
      });
    }
  }

  void uploadFile() async {
    final sMessenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    setState(() {
      uploading = true;
    });
    if (result == null) return;
    final file = result.files.first;
    final uploadErrorModel = await ref.read(filesRepositoryProvider).uploadFile(
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        token: ref.read(userProvider)!.token,
        roomId: widget.roomId,
        fileBytes: file.bytes!,
        fileName: file.name);
    if (uploadErrorModel.errorMessage != null) {
      sMessenger.showSnackBar(
          SnackBar(content: Text(uploadErrorModel.errorMessage!)));
      return;
    }
    socketRepository.shareFile({
      'room': widget.roomId,
      'sharedFile': (uploadErrorModel.data as FileModel).toJson()
    });
    setState(() {
      uploading = false;
    });
    sMessenger.showSnackBar(const SnackBar(content: Text('File uploaded')));
  }

  String getUserId() {
    return ref.read(userProvider)!.uid;
  }

  void onOpenedFile(FileModel file) async {
    // Open file
    final sMessenger = ScaffoldMessenger.of(context);

    final downloadErrorModel =
        await ref.read(filesRepositoryProvider).downloadFile(
              token: ref.read(userProvider)!.token,
              filename: file.filename,
            );

    if (downloadErrorModel.errorMessage != null) {
      sMessenger.showSnackBar(
          SnackBar(content: Text(downloadErrorModel.errorMessage!)));
    }
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
              uploading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: uploadFile,
                      ),
                    ),
            ],
          ),
          body: TabBarView(children: [
            errorModelFetchingFiles == null
                ? const Loader()
                : FilesTab(
                    files: _loadedFiles
                        .where((file) => getUserId() == file.uid)
                        .toList(),
                    onOpenedFile: onOpenedFile),
            errorModelFetchingFiles == null
                ? const Loader()
                : FilesTab(
                    files: _loadedFiles
                        .where((file) => getUserId() != file.uid)
                        .toList(),
                    onOpenedFile: onOpenedFile),
          ]),
        ));
  }
}
