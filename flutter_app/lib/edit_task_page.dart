import 'package:flutter/material.dart';
import 'api_service.dart';

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;

  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _textController;
  late TextEditingController _projectController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task["text"]);
    _projectController = TextEditingController(text: widget.task["project"] ?? "");
    
    // Safely handle tags that might be null
    final tags = widget.task["tags"] ?? [];
    _tagsController = TextEditingController(text: (tags as List<dynamic>).join(", "));
  }

  void _saveTask() async {
    try {
      print("Saving task: ${widget.task["text"]}");
      print("New text: ${_textController.text}");
      print("Project: ${_projectController.text}");
      print("Tags: ${_tagsController.text}");
      
      await ApiService.editTask(
        widget.task["text"],
        newText: _textController.text,
        project: _projectController.text.isEmpty ? null : _projectController.text,
        tags: _tagsController.text.isEmpty 
            ? [] 
            : _tagsController.text.split(",").map((tag) => tag.trim()).toList(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task updated successfully!")),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      print("Error updating task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating task: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: "Task Text"),
            ),
            TextField(
              controller: _projectController,
              decoration: InputDecoration(labelText: "Project"),
            ),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(labelText: "Tags (comma-separated)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}