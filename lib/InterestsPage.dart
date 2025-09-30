import 'package:flutter/material.dart';
import 'services/socket_service.dart';

class InterestsPage extends StatefulWidget {
  final String userEmail;
  const InterestsPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  List<String> pendingLikes = [];

  @override
  void initState() {
    super.initState();
    SocketService.instance.onLikeReceived = (data) {
      if (!pendingLikes.contains(data['from'])) {
        setState(() => pendingLikes.add(data['from']));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interests'),
        actions: [
          if (pendingLikes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Stack(
                children: [
                  Icon(Icons.notifications),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        pendingLikes.length.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
      body: pendingLikes.isNotEmpty
          ? ListView(
        children: pendingLikes
            .map((from) => ListTile(
          leading: Icon(Icons.person),
          title: Text('$from liked you!'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  SocketService.instance.rejectLike(from);
                  setState(() => pendingLikes.remove(from));
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  SocketService.instance.acceptLike(from);
                  setState(() => pendingLikes.remove(from));
                },
              )
            ],
          ),
        ))
            .toList(),
      )
          : Center(child: Text('No new likes')),
    );
  }
}
