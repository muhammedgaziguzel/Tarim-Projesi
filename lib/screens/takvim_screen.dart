import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/calendar_firestore_service.dart';

class TakvimScreen extends StatefulWidget {
  @override
  _TakvimScreenState createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final CalendarFirestoreService _firestoreService = CalendarFirestoreService();
  final Map<DateTime, DayEntry> _dayEntries = {};
  final TextEditingController _noteController = TextEditingController();
  List<Offset?> _drawingPoints = [];

  @override
  void initState() {
    super.initState();
    selectedDay = focusedDay;
    _loadDayEntryFromFirestore(selectedDay!);
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDay = day;
      this.focusedDay = focusedDay;
    });

    _loadDayEntryFromFirestore(day);
  }

  Future<void> _loadDayEntryFromFirestore(DateTime date) async {
    final data = await _firestoreService.getDayEntry(date);
    if (data != null) {
      setState(() {
        _dayEntries[date] = DayEntry(
          note: data['note'],
          drawingPoints: List<Offset?>.from(data['drawingPoints']),
        );
        _noteController.text = data['note'];
        _drawingPoints = List<Offset?>.from(data['drawingPoints']);
      });
    } else {
      setState(() {
        _noteController.clear();
        _drawingPoints = [];
      });
    }
  }

  Future<void> _saveDayEntry() async {
    if (selectedDay == null) return;

    final entry = DayEntry(
      note: _noteController.text,
      drawingPoints: _drawingPoints,
    );

    await _firestoreService.saveDayEntry(selectedDay!, entry.note, entry.drawingPoints);

    setState(() {
      _dayEntries[selectedDay!] = entry;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused variable 'dayEntrys'
    return Scaffold(
      appBar: AppBar(
        title: Text('Takvim'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              this.focusedDay = focusedDay;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Not ekle',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(
            width: 300,
            height: 200,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  _drawingPoints.add(renderBox.globalToLocal(details.globalPosition));
                });
              },
              onPanEnd: (details) => _drawingPoints.add(null),
              child: CustomPaint(
                painter: DrawingPainter(_drawingPoints),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _saveDayEntry,
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class DayEntry {
  final String note;
  final List<Offset?> drawingPoints;

  DayEntry({required this.note, required this.drawingPoints});
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
