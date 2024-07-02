// import 'package:dodoc/models/chat_model.dart';
// import 'package:dodoc/repository/auth_repository.dart';
// import 'package:dodoc/repository/chat_repository.dart';
// import 'package:dodoc/repository/socket_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class NewMessages extends ConsumerStatefulWidget {
//   final String roomId;
//   const NewMessages({super.key, required this.roomId});

//   @override
//   ConsumerState<NewMessages> createState() => _NewMessagesState();
// }

// class _NewMessagesState extends ConsumerState<NewMessages> {
//   final _messageController = TextEditingController();
//   SocketRepository socketRepository = SocketRepository();
//   var loading = false;
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   void sendMessage() async {
//     //todo: implement send message
//     final message = _messageController.text;
//     if (message.trim().isEmpty) {
//       return;
//     }
//     setState(() {
//       loading = true;
//     });
//     FocusScope.of(context).unfocus();
//     _messageController.clear();
//     final user = ref.read(userProvider)!;
//     final errorModel = await ref.read(chatRepositoryProvider).saveChat(
//           token: user.token,
//           profilePic: user.profilePic,
//           roomId: widget.roomId,
//           content: message,
//           username: user.name,
//         );
//     if (errorModel.data != null) {
//       socketRepository.sendMessage(<String, dynamic>{
//         'room': widget.roomId,
//         'chat-details': (errorModel.data as ChatModel).toJson(),
//       });
//     }
//     setState(() {
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15, bottom: 15, right: 1),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               controller: _messageController,
//               decoration: const InputDecoration(
//                 label: Text('Send message...'),
//               ),
//               autocorrect: true,
//               enableSuggestions: true,
//               textCapitalization: TextCapitalization.sentences,
//             ),
//           ),
//           IconButton(
//             onPressed: loading ? null : sendMessage,
//             icon: Icon(
//               Icons.send,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
