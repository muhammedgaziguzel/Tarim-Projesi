import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TakvimScreen extends StatefulWidget {
  const TakvimScreen({super.key});

  @override
  _TakvimScreenState createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final user = _auth.currentUser;
    if (user == null) return;

    final dateStr = '${date.year}-${date.month}-${date.day}';
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('takvim')
        .doc(dateStr)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _dayEntries[date] = DayEntry(
          note: data['note'] ?? '',
          drawingPoints: List<Offset?>.from(
            (data['drawingPoints'] as List).map((point) {
              if (point == null) return null;
              return Offset(point['x'] as double, point['y'] as double);
            }),
          ),
        );
        _noteController.text = data['note'] ?? '';
        _drawingPoints = _dayEntries[date]!.drawingPoints;
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

    final user = _auth.currentUser;
    if (user == null) return;

    final dateStr =
        '${selectedDay!.year}-${selectedDay!.month}-${selectedDay!.day}';
    final entry = DayEntry(
      note: _noteController.text,
      drawingPoints: _drawingPoints,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('takvim')
        .doc(dateStr)
        .set({
      'note': entry.note,
      'drawingPoints': entry.drawingPoints.map((point) {
        if (point == null) return null;
        return {'x': point.dx, 'y': point.dy};
      }).toList(),
      'date': Timestamp.fromDate(selectedDay!),
    });

    setState(() {
      _dayEntries[selectedDay!] = entry;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayEntry = _dayEntries[selectedDay];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
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
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF2C6E49),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF2C6E49),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Not ekle',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2C6E49)),
                ),
              ),
              maxLines: null,
            ),
          ),
          Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  _drawingPoints
                      .add(renderBox.globalToLocal(details.globalPosition));
                });
              },
              onPanEnd: (details) => _drawingPoints.add(null),
              child: CustomPaint(
                painter: DrawingPainter(_drawingPoints),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveDayEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C6E49),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.white),
            ),
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
      ..color = const Color(0xFF2C6E49)
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
