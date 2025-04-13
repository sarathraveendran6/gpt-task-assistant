import 'package:flutter/material.dart';
import 'api_service.dart'; // Import the ApiService
import 'edit_task_page.dart';

class TaskPage extends StatefulWidget {
  final String? project;
  final String? tag;

  TaskPage({this.project, this.tag});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void didUpdateWidget(TaskPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if project or tag has changed
    if (oldWidget.project != widget.project || oldWidget.tag != widget.tag) {
      // Re-fetch tasks with new filter
      _fetchTasks();
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await ApiService.fetchTasks();
      
      // Filter tasks based on selected project or tag
      var filteredTasks = tasks;
      
      if (widget.project != null) {
        filteredTasks = tasks.where((task) => 
          task.project == widget.project
        ).toList();
      } else if (widget.tag != null) {
        filteredTasks = tasks.where((task) => 
          task.tags != null && task.tags!.contains(widget.tag)
        ).toList();
      }
      
      setState(() {
        _tasks = filteredTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching tasks: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return Center(child: Text("No tasks available"));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          title: Text(task.text),
          subtitle: Text("Project: ${task.project ?? "None"}"),
          onTap: () {
            // Navigate to the EditTaskPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskPage(task: task.toJson()),
              ),
            ).then((value) {
              if (value == true) {
                _fetchTasks(); // Refresh tasks after editing
              }
            });
          },
        );
      },
    );
  }
}
