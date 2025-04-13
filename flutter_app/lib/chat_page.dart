import 'package:flutter/material.dart';
import 'api_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    try {
      final fetchedTasks = await ApiService.fetchTasks();
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      print("Failed to load tasks: $e");
    }
  }

  void sendMessage() async {
    String input = _controller.text.trim();
    if (input.isEmpty) return;

    _controller.clear();
    setState(() {
      messages.add("You: $input");
    });

    String response = await ApiService.sendTask(input);

    setState(() {
      messages.add("Bot: $response");
    });

    _loadTasks(); // refresh task list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Assistant")),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(messages[i]),
              ),
            ),
          ),

          Divider(thickness: 1),

          // Task list
          Expanded(
            flex: 1,
            child: tasks.isEmpty
                ? Center(child: Text("No tasks yet"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final task = tasks[i];
                      return ListTile(
                        leading: Icon(Icons.task),
                        title: Text(task.text),
                        trailing: task.done ? Icon(Icons.check, color: Colors.green) : null,
                      );
                    },
                  ),
          ),

          Divider(thickness: 1),

          // Input box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
