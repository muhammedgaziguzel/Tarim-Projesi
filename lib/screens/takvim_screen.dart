import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Color(0xFFEAE1C8),
      appBarTheme: AppBarTheme(
        color: Colors.teal,
        elevation: 0,
      ),
    ),
    home: TakvimScreen(),
  ));
}

// Model class to store day-specific data
class DayEntry {
  String note;
  List<Offset?> drawingPoints;

  DayEntry({this.note = '', this.drawingPoints = const []});
}

class TakvimScreen extends StatefulWidget {
  const TakvimScreen({Key? key}) : super(key: key);

  @override
  State<TakvimScreen> createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  // Map to store entries for each day
  final Map<DateTime, DayEntry> _dayEntries = {};

  // Get the current day's entry, creating a new one if it doesn't exist
  DayEntry _getSelectedDayEntry() {
    final day = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!_dayEntries.containsKey(day)) {
      _dayEntries[day] = DayEntry();
    }
    return _dayEntries[day]!;
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDay = day;
      this.focusedDay = focusedDay;
    });
  }

  void _openDayDetailsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailsScreen(
          date: selectedDay,
          dayEntry: _getSelectedDayEntry(),
          onSave: (note, points) {
            setState(() {
              final day = DateTime(
                  selectedDay.year, selectedDay.month, selectedDay.day);
              _dayEntries[day] =
                  DayEntry(note: note, drawingPoints: List.from(points));
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused variable 'dayEntrys'
    return Scaffold(
      appBar: AppBar(
        title: Text('Takvim', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bildirim Ayarları Henüz Yapılmadı')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Seçilen Gün: ${DateFormat('EEEE, MMMM d, yyyy').format(selectedDay)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TableCalendar(
            locale: 'en_US',
            rowHeight: 45,
            focusedDay: focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            availableGestures: AvailableGestures.all,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            eventLoader: (day) {
              // Show markers for days with entries
              final normalizedDay = DateTime(day.year, day.month, day.day);
              if (_dayEntries.containsKey(normalizedDay) &&
                  (_dayEntries[normalizedDay]!.note.isNotEmpty ||
                      _dayEntries[normalizedDay]!.drawingPoints.isNotEmpty)) {
                return [''];
              }
              return [];
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDayPreview(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openDayDetailsScreen,
        child: Icon(Icons.edit),
        tooltip: 'Edit Day Details',
      ),
    );
  }

  Widget _buildDayPreview() {
    final dayEntry = _getSelectedDayEntry();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Günlük Notlar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dayEntry.note.isEmpty && dayEntry.drawingPoints.isEmpty)
                    Text(
                      'Bu gün için not veya çizim yok. Düzenlemek için "Düzenle" butonuna basın.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  if (dayEntry.note.isNotEmpty) ...[
                    Text(
                      dayEntry.note,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 15),
                  ],
                  if (dayEntry.drawingPoints.isNotEmpty) ...[
                    Text(
                      "Çizim:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(
                        painter: DrawingPainter(dayEntry.drawingPoints),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayDetailsScreen extends StatefulWidget {
  final DateTime date;
  final DayEntry dayEntry;
  final Function(String, List<Offset?>) onSave;

  const DayDetailsScreen({
    Key? key,
    required this.date,
    required this.dayEntry,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  late TextEditingController _noteController;
  late List<Offset?> _points;
  late DrawingController _drawingController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.dayEntry.note);
    _points = List.from(widget.dayEntry.drawingPoints);
    _drawingController = DrawingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  void _clearDrawing() {
    setState(() {
      _points = [];
    });
  }

  void _saveAndPop() {
    widget.onSave(_noteController.text, _points);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${DateFormat('MMMM d, yyyy').format(widget.date)} Detayları'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAndPop,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notlar:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Bu gün için notunuzu girin...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Çizim Alanı:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _clearDrawing,
                  icon: Icon(Icons.delete),
                  label: Text('Temizle'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _points.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    _points.add(null);
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(_points),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 2.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
