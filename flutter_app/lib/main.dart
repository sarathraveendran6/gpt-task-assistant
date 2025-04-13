import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'task_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPT Task Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = ["Chat", "Tasks"];

  String? _selectedProject;
  String? _selectedTag;

  List<String> _projects = ["Personal", "Work", "Travel"];
  List<String> _tags = ["urgent", "idea", "someday"];

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _selectProject(String project) {
    setState(() {
      _selectedProject = project;
      _selectedTag = null;
      _selectedIndex = 1;
    });
    Navigator.of(context).pop();
  }

  void _selectTag(String tag) {
    setState(() {
      _selectedTag = tag;
      _selectedProject = null;
      _selectedIndex = 1;
    });
    Navigator.of(context).pop();
  }

  void _addNewItem(String title, Function(String) onAdd) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $title name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) onAdd(text);
              Navigator.of(context).pop();
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text("GPT Assistant", style: TextStyle(fontSize: 20, color: Colors.white)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.chat_bubble),
              title: Text('Chat'),
              selected: _selectedIndex == 0,
              onTap: () => _navigateTo(0),
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Tasks'),
              selected: _selectedIndex == 1 && _selectedProject == null && _selectedTag == null,
              onTap: () {
                setState(() {
                  _selectedProject = null;
                  _selectedTag = null;
                  _selectedIndex = 1;
                });
                Navigator.of(context).pop();
              },
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Projects", style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add, size: 20),
                    onPressed: () => _addNewItem("Project", (text) => setState(() => _projects.add(text))),
                  ),
                ],
              ),
            ),
            ..._projects.map((p) => ListTile(
              title: Text(p),
              onTap: () => _selectProject(p),
            )),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tags", style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add, size: 20),
                    onPressed: () => _addNewItem("Tag", (text) => setState(() => _tags.add(text))),
                  ),
                ],
              ),
            ),
            ..._tags.map((t) => ListTile(
              title: Text(t),
              onTap: () => _selectTag(t),
            )),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? ChatPage()
          : TaskPage(project: _selectedProject, tag: _selectedTag),
    );
  }
}
