import 'package:dodoc/colors.dart';
import 'package:dodoc/widgets/chat_messages.dart';
import 'package:dodoc/widgets/new_messages.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String id;
  final Function closeChat;
  const ChatScreen({super.key, required this.id, required this.closeChat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kGreyColor2,
        borderRadius:
            BorderRadius.circular(10), // Adjust the radius to your preference
        // Add other decoration properties if needed, like color, border, etc.
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.closeChat();
                  },
                ),
                const Expanded(
                  child: Text(
                    'Chat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.call))
              ],
            ),
          ),
          Expanded(
            child: ChatMessages(roomId: widget.id),
          ),
          NewMessages(roomId: widget.id)
        ],
      ),
    );
  }
}
