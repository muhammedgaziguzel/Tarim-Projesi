import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  static late Interpreter _interpreter;

  // Modeli yükleme
  static Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      print("Model başarıyla yüklendi!");
    } catch (e) {
      print("Model yükleme hatası: $e");
    }
  }

  // Bitki hastalığını tahmin etme
  static Future<void> predictPlantDisease() async {
    try {
      // Modeli yükle
      await loadModel();

      // Model girişi ve çıktısı
      var input = [/* Görüntü verisi burada olacak */];
      var output = List.filled(1, 0);

      // Tahmin işlemi
      _interpreter.run(input, output);

      print("Tahmin sonucu: $output");
    } catch (e) {
      print("Tahmin yapma hatası: $e");
    }
  }
}
