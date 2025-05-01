import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class DayDetailsScreen extends StatefulWidget {
  final DateTime date;
  final String note;
  final List<Offset?> drawingPoints;
  final Function(String, Uint8List?) onSave;

  const DayDetailsScreen({
    Key? key,
    required this.date,
    required this.note,
    required this.drawingPoints,
    required this.onSave,
  }) : super(key: key);

  @override
  _DayDetailsScreenState createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  late TextEditingController _noteController;
  DrawingController _drawingController = DrawingController();
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final updatedNote = _noteController.text;
    final imageBytes = await _capturePng();
    widget.onSave(updatedNote, imageBytes);
    Navigator.pop(context);
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print(e);
    }
    return null;
  }

  void _clearDrawing() {
    _drawingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${widget.date.year}-${widget.date.month}-${widget.date.day}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detay - $formattedDate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _handleSave,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Not',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RepaintBoundary(
                key: _repaintKey,
                child: Stack(
                  children: [
                    DrawingBoard(
                      controller: _drawingController,
                      background: Container(color: Colors.grey[100]),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: FloatingActionButton.small(
                        onPressed: _clearDrawing,
                        child: const Icon(Icons.delete),
                        tooltip: 'Çizimi Temizle',
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
