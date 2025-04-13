import 'dart:convert';
import 'package:http/http.dart' as http;

class Task {
  final String text;
  final bool done;
  final String? project;
  final List<String>? tags;

  Task({
    required this.text,
    this.done = false,
    this.project,
    this.tags,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      text: json['text'],
      done: json['done'] ?? false,
      project: json['project'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'done': done,
      'project': project,
      'tags': tags,
    };
  }
}


class ApiService {
  // static const String baseUrl = "http://10.0.2.2:8000";
  static const String baseUrl = "https://gpt-task-assistant.onrender.com";


  static Future<List<Task>> fetchTasks() async {
    final url = Uri.parse("$baseUrl/get_tasks");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tasks = (data['tasks'] as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList();
      return tasks;
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  static Future<String> sendTask(String message, {String? project, List<String>? tags}) async {
    final url = Uri.parse("$baseUrl/add_task");

    final body = {
      "message": message,
      "project": project,
      "tags": tags ?? [],
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == "duplicate"
          ? "Duplicate: ${data["message"]}"
          : "Task added!";
    } else {
      return "Error: ${response.statusCode}";
    }
  }


  static Future<void> deleteTask(String text) async {
      final url = Uri.parse("$baseUrl/delete_task/$text");
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to delete task");
      }
    }

  static Future<String> editTask(String oldText, {String? newText, String? project, List<String>? tags}) async {
    final url = Uri.parse("$baseUrl/edit_task");

    final body = {
      "old_message": oldText,
      "new_message": newText,
      "project": project,
      "tags": tags,
    };

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return "Task updated!";
    } else {
      throw Exception("Failed to update task: ${response.statusCode}");
    }
  }

}
