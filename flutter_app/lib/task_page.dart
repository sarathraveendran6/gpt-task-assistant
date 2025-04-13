import 'package:flutter/material.dart';
import 'api_service.dart';

class TaskPage extends StatefulWidget {
  final String? project;
  final String? tag;

  TaskPage({this.project, this.tag});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant TaskPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project || oldWidget.tag != widget.tag) {
      _loadTasks();
    }
  }

  void _loadTasks() async {
    try {
      final fetched = await ApiService.fetchTasks();
      setState(() {
        tasks = _applyFilter(fetched);
      });
    } catch (e) {
      print("Failed to fetch tasks: $e");
    }
  }

  List<Task> _applyFilter(List<Task> input) {
    if (widget.project != null) {
      return input.where((task) => task.project == widget.project).toList();
    } else if (widget.tag != null) {
      return input.where((task) => task.tags?.contains(widget.tag) ?? false).toList();
    } else {
      return input;
    }
  }

  void _addTask() async {
    String text = _taskController.text.trim();
    if (text.isEmpty) return;

    _taskController.clear();

    try {
      final result = await ApiService.sendTask(
        text,
        project: widget.project,
        tags: widget.tag != null ? [widget.tag!] : [],
      );
      if (result.toLowerCase().contains("added")) {
        setState(() {
          tasks.add(Task(
            text: text,
            project: widget.project,
            tags: widget.tag != null ? [widget.tag!] : [],
          ));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } catch (e) {
      print("Failed to add task: $e");
    }
  }

  void _toggleTask(int index) {
    final task = tasks[index];
    setState(() {
      tasks[index] = Task(
        text: task.text,
        done: !task.done,
        project: task.project,
        tags: task.tags,
      );
    });
  }

  void _deleteTask(String text) async {
    setState(() {
      tasks.removeWhere((task) => task.text == text);
    });

    try {
      await ApiService.deleteTask(text);
    } catch (e) {
      print("Failed to delete task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterText = widget.project != null
        ? "Project: ${widget.project}"
        : widget.tag != null
            ? "Tag: ${widget.tag}"
            : "All Tasks";

    return Scaffold(
      appBar: AppBar(title: Text(filterText)),
      body: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text("No tasks available"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final task = tasks[i];
                      return ListTile(
                        leading: Icon(
                          task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.done ? Colors.green : null,
                        ),
                        title: Text(
                          task.text,
                          style: TextStyle(
                            decoration: task.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (task.project != null)
                              Expanded(
                                child: Text(
                                  "📂 ${task.project}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (task.tags != null && task.tags!.isNotEmpty)
                              Expanded(
                                child: Wrap(
                                  spacing: 6.0,
                                  children: task.tags!.map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(task.text),
                            ),
                            IconButton(
                              icon: Icon(
                                task.done ? Icons.undo : Icons.check,
                                color: task.done ? Colors.grey : Colors.green,
                              ),
                              onPressed: () => _toggleTask(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: "Add a new task...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text("Add"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
