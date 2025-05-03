import 'package:flutter/material.dart';
import '../services/todo_service.dart';

class YapilacaklarScreen extends StatefulWidget {
  const YapilacaklarScreen({super.key});

  @override
  _YapilacaklarScreenState createState() => _YapilacaklarScreenState();
}

class _YapilacaklarScreenState extends State<YapilacaklarScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isEditing = false;
  int _editingIndex = -1;

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }


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

  void _editTask(int index) {
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _controller.text = _tasks[index].text;
      _inputFocusNode.requestFocus();
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].completed = !_tasks[index].completed;
      if (_tasks[index].completed) {
        final task = _tasks.removeAt(index);
        _tasks.add(task);
      }
    });
  }

  void _removeTask(int index) {
    final removedTask = _tasks[index];

    setState(() {
      _tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedTask.text} silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
            });
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F2E8), // Arka plan rengi burada
        appBar: AppBar(
          title: const Text('Yapılacaklar Listesi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Tamamlananları Temizle',
              onPressed: _tasks.any((task) => task.completed)
                  ? () {
                      setState(() {
                        _tasks.removeWhere((task) => task.completed);
                      });
                      _showSnackBar('Tamamlanan görevler silindi');
                    }
                  : null,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: _isEditing ? 'Görevi düzenle' : 'Yeni görev ekle',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(
                      _isEditing ? Icons.save : Icons.add,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz görev eklenmedi',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Dismissible(
                          key: ValueKey(task.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _removeTask(index),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.completed,
                                onChanged: (_) => _toggleTask(index),
                              ),
                              title: Text(
                                task.text,
                                style: TextStyle(
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: task.completed ? Colors.grey : Colors.black,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: task.completed ? null : () => _editTask(index),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeTask(index),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: _tasks.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  _inputFocusNode.requestFocus();
                },
                tooltip: 'Yeni Görev',
                child: const Icon(Icons.add_task),
              )
            : null,
      ),
    );
  }
}

class Task {
  final String id;
  String text;
  bool completed;

  Task({
    required this.text,
    this.completed = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}
