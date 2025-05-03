import 'package:flutter/material.dart';
import '../services/todo_service.dart';

class YapilacaklarScreen extends StatefulWidget {
  const YapilacaklarScreen({super.key});
  
  @override
  YapilacaklarScreenState createState() => YapilacaklarScreenState();
}

class YapilacaklarScreenState extends State<YapilacaklarScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final TodoService _todoService = TodoService();
  final int _userId = 1; // Geçici olarak sabit bir kullanıcı ID
  
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final todos = await _todoService.fetchTodos(_userId);
      setState(() {
        _tasks.clear();
        _tasks.addAll(todos as Iterable<Map<String, dynamic>>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Görevler alınırken hata oluştu: $e');
    }
  }

  void _addTask() async {
    if (_controller.text.isEmpty) return;
    
    final newTask = _controller.text;
    _controller.clear();
    
    setState(() {
      _isAdding = true;
    });
    
    try {
      await _todoService.addTodo(newTask, _userId);
      await _loadTasks();
      _showSuccessSnackBar('Görev başarıyla eklendi');
    } catch (e) {
      _showErrorSnackBar('Görev eklenirken hata oluştu: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  Future<void> _removeTask(int index) async {
    final taskToRemove = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    
    // Kullanıcıya bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${taskToRemove['title']} silindi'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _tasks.insert(index, taskToRemove);
            });
          },
        ),
      ),
    );
    
    // API'de silme endpoint'i yok olduğu için burada yalnızca UI güncellemesi yapıyoruz
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8), // İstediğiniz arka plan rengi
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          children: [
            // Yeni görev ekleme alanı
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Yeni görev ekle...",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isAdding ? null : _addTask,
                      icon: _isAdding 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                      label: Text(_isAdding ? "Ekleniyor..." : "Ekle"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F), // Zeytin yeşili renk
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Liste başlığı - yenileme butonu ile birlikte
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Görevlerim (${_tasks.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black54),
                  onPressed: _loadTasks,
                  tooltip: 'Listeyi Yenile',
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Görev listesi
            Expanded(
              child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 70,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Henüz görev eklenmemiş",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Dismissible(
                              key: Key(index.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                _removeTask(index);
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.assignment_outlined,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                title: Text(
                                  task['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: task['completed'] != null
                                  ? Text(
                                      task['completed'] ? "Tamamlandı" : "Devam ediyor",
                                      style: TextStyle(
                                        color: task['completed'] ? Colors.green : Colors.orange,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeTask(index),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Yapılacaklar Listesi İstatistikleri",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        "Toplam",
                        _tasks.length.toString(),
                        Icons.list,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        "Tamamlanan",
                        _tasks.where((task) => task['completed'] == true).length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        "Bekleyen",
                        _tasks.where((task) => task['completed'] != true).length.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF556B2F), // Zeytin yeşili renk
        child: const Icon(Icons.analytics),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}