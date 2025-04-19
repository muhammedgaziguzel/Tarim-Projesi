import 'package:flutter/material.dart';
import '../services/todo_service.dart';

class YapilacaklarScreen extends StatefulWidget {
  const YapilacaklarScreen({super.key});

  @override
  _YapilacaklarScreenState createState() => _YapilacaklarScreenState();
}

class _YapilacaklarScreenState extends State<YapilacaklarScreen> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  final TodoService _todoService = TodoService();
  final int _userId = 1; // Geçici olarak sabit bir kullanıcı ID

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final todos = await _todoService.fetchTodos(_userId);
      setState(() {
        _tasks.clear();
        _tasks.addAll(todos.map<String>((e) => e['title']));
      });
    } catch (e) {
      print('Görevler alınırken hata oluştu: $e');
    }
  }

  void _addTask() async {
    if (_controller.text.isNotEmpty) {
      final newTask = _controller.text;
      try {
        await _todoService.addTodo(newTask, _userId);
        _controller.clear();
        _loadTasks(); // Yeni görevden sonra listeyi yeniden yükle
      } catch (e) {
        print('Görev eklenirken hata oluştu: $e');
      }
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    // API'de silme endpoint'i yok. Eklemek istersen haber ver 😊
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yapılacaklar Listesi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Yeni Görev Ekle",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_tasks[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
