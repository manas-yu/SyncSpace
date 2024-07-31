import 'dart:async';

import 'package:dodoc/clients/signaling.dart';
import 'package:dodoc/colors.dart';
import 'package:dodoc/common/widgets/loader.dart';
import 'package:dodoc/models/document_model.dart';
import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/repository/document_repository.dart';
import 'package:dodoc/repository/socket_repository.dart';
import 'package:dodoc/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  var chatVisible = false;
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();
  String? remoteSocketId;
  final peerService = PeerService();
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    socketRepository.disposeChangeListener();
  }

  void setSocketListeners() {
    socketRepository.incomingCall((data) async {
      // Check if 'data' has a key 'offer' and 'offer' is not null
      final rMaster = Routemaster.of(context);
      try {
        rMaster.push('video-screen');
        // Safely cast 'offer' to String, if possible
        final offerMap = data['offer'];
        final RTCSessionDescription offer =
            RTCSessionDescription(offerMap['sdp'], offerMap['type']);
        final RTCSessionDescription ans = await peerService.getAnswer(offer);
        socketRepository.sendAnswer(<String, dynamic>{
          'room': widget.id,
          'answer': {
            'sdp': ans.sdp,
            'type': ans.type,
          },
        });
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    print('Joining room ${widget.id} ');
    fetchDocumentData();
    setSocketListeners();
    socketRepository.changeListener((data) {
      _controller?.compose(
        Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.remote,
      );
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    _controller!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  void navigateToFileSharing(BuildContext context) {
    Routemaster.of(context).push('files');
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (_controller == null) {
      return const Scaffold(body: Loader());
    }
    return Scaffold(
      floatingActionButton: !chatVisible
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  chatVisible = !chatVisible;
                });
              },
              child: const Icon(Icons.chat_bubble),
            )
          : null,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              navigateToFileSharing(context);
            },
            icon: const Icon(Icons.folder),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/document/${widget.id}'))
                    .then(
                  (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Link copied!',
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.lock,
                size: 16,
                color: kWhiteColor,
              ),
              label: const Text(
                'Share',
                style: TextStyle(color: kWhiteColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
              ),
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('/');
                },
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              ),
            ],
          ),
        ),
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
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                quill.QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    controller: _controller!,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SizedBox(
                    width: screenWidth * 0.6,
                    child: Card(
                      color: kWhiteColor,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: quill.QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            controller: _controller!,
                            sharedConfigurations:
                                const QuillSharedConfigurations(
                              locale: Locale('en'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (chatVisible)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(13),
                width: screenWidth * 0.5,
                height: screenHeight * 0.8,
                child: ChatScreen(
                    onVideoCall: () async {
                      final rMaster = Routemaster.of(context);
                      final offer = await peerService.getOffer();
                      socketRepository.call(<String, dynamic>{
                        'room': widget.id,
                        'offer': {
                          'sdp': offer.sdp,
                          'type': offer.type,
                        },
                      });
                      rMaster.push('video-screen');
                    },
                    id: widget.id,
                    closeChat: () {
                      setState(() {
                        chatVisible = false;
                      });
                    }),
              ),
            ),
        ],
      ),
    );
  }
}
