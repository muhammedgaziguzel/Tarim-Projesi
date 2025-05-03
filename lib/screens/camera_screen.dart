import 'package:camera/camera.dart';

class CameraService {
  static CameraController? _cameraController;

  // Kamerayı başlatma
  static Future<CameraController?> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], // Varsayılan kamerayı al
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    return _cameraController;
  }

  // Kamera görüntüsünü almak
  static Future<void> disposeCamera() async {
    await _cameraController?.dispose();
  }
}
