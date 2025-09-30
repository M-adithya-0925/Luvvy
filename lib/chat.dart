import 'package:flutter/material.dart';
import 'services/socket_service.dart';

class ChatPage extends StatefulWidget {
  final String userEmail;
  final String otherUserEmail;

  const ChatPage({super.key, required this.userEmail, required this.otherUserEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  late SocketService _socket;

  @override
  void initState() {
    super.initState();
    _socket = SocketService.instance;
    _socket.onNewMessage = (data) {
      setState(() {
        messages.add({
          "from": data['from'],
          "message": data['message'],
        });
      });
    };
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    _socket.sendMessage(widget.otherUserEmail, _controller.text.trim());
    setState(() {
      messages.add({
        "from": widget.userEmail,
        "message": _controller.text.trim()
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.otherUserEmail}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages
                  .map((m) => ListTile(
                title: Text(
                  m['from'] == widget.userEmail ? "You" : widget.otherUserEmail,
                ),
                subtitle: Text(m['message']!),
                trailing: m['from'] == widget.userEmail
                    ? Icon(Icons.person, color: Colors.purple) : null,
              ))
                  .toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.purple),
                onPressed: _sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}
