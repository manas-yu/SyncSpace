import 'package:dodoc/common/widgets/loader.dart';
import 'package:dodoc/models/chat_model.dart';
import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/repository/auth_repository.dart';
import 'package:dodoc/repository/chat_repository.dart';
import 'package:dodoc/repository/socket_repository.dart';
import 'package:dodoc/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessages extends ConsumerStatefulWidget {
  final String roomId;
  const ChatMessages({super.key, required this.roomId});

  @override
  ConsumerState<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends ConsumerState<ChatMessages> {
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();
  final List<ChatModel> _loadedMessages = [];
  String getUserId() {
    return ref.read(userProvider)!.uid;
  }

  void fetchChats() async {
    errorModel = await ref
        .read(chatRepositoryProvider)
        .getChats(ref.read(userProvider)!.token, widget.roomId);
    if (errorModel != null) {
      setState(() {
        _loadedMessages.addAll(errorModel!.data as List<ChatModel>);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    socketRepository.disposeReceiveMessageListener();
  }

  @override
  void initState() {
    super.initState();
    fetchChats();
    socketRepository.receiveMessageListener((data) {
      final chat = ChatModel.fromJson(data['chat-details']);
      setState(() {
        _loadedMessages.insert(0, chat);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorModel == null) {
      return const Loader();
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(
        bottom: 40,
        left: 14,
        right: 14,
      ),
      itemCount: _loadedMessages.length,
      itemBuilder: (context, index) {
        final chatMessage = _loadedMessages[index];
        final nextChatMessage = index + 1 < _loadedMessages.length
            ? _loadedMessages[index + 1]
            : null;
        final currentMessageUserId = chatMessage.uid;
        final nextMessageUserId = nextChatMessage?.uid;
        final nextUserIsSame = (nextMessageUserId == currentMessageUserId);
        if (nextUserIsSame) {
          return MessageBubble.next(
              message: chatMessage.content,
              isMe: (getUserId() == currentMessageUserId));
        } else {
          return MessageBubble.first(
              userImage: chatMessage.profilePic,
              username: chatMessage.username,
              message: chatMessage.content,
              isMe: (getUserId() == currentMessageUserId));
        }
      },
    );
  }
}
