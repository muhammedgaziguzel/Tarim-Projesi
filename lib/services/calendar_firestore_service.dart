import 'dart:ui'; // Offset sınıfı için
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDayEntry(DateTime date, String note, List<Offset?> drawingPoints) async {
    final dayKey = '${date.year}-${date.month}-${date.day}';

    await _firestore.collection('calendar_entries').doc(dayKey).set({
      'note': note,
      'drawingPoints': drawingPoints.map((point) =>
          point == null ? null : {'dx': point.dx, 'dy': point.dy}).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getDayEntry(DateTime date) async {
    final dayKey = '${date.year}-${date.month}-${date.day}';
    final doc = await _firestore.collection('calendar_entries').doc(dayKey).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return {
      'note': data['note'] ?? '',
      'drawingPoints': (data['drawingPoints'] as List?)?.map((point) =>
          point == null ? null : Offset(point['dx'], point['dy'])).toList() ?? [],
    };
  }
}
