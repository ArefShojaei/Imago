import 'package:imago/app.dart';
import 'package:river/river.dart';

class ImageController {
  final ImageService imageService;
  final ExifService exifService;

  ImageController({required this.imageService, required this.exifService});

  void info(Request req, Response res) {
    res.json({
      'name': 'Imago',
      'description':
          'Image inspection and processing toolkit with HTTP API and CLI support.',
      'version': '1.0.0',
      'endpoints': [
        {"method": "GET", "path": "/health", "description": "Health check"},
        {"method": "POST", "path": "/exif", "description": "Read EXIF data"},
        {
          "method": "POST",
          "path": "/secure",
          "description": "Remove sensitive metadata"
        },
        {
          "method": "POST",
          "path": "/fake",
          "description": "Inject fake EXIF data"
        },
        {
          "method": "POST",
          "path": "/clean",
          "description": "Clean / normalize image"
        }
      ],
      "supportedFormats": ["jpeg", "jpg", "png", "webp"],
    });
  }

  void health(Request req, Response res) {
    res.json({
      'success': true,
      'status': 'ok',
      'time': DateTime.now().toIso8601String(),
    });
  }

  Future<void> exif(Request req, Response res) async {
    try {
      final body = await req.body;

      final path = body['image'] as String;

      final bytes = await imageService.load(path);

      final exif = await exifService.extract(bytes);

      res.status(200).json({
        "success": true,
        "message": "EXIF data extracted successfully",
        "data": {
          "exif": exif,
        }
      });
    } catch (e) {
      res.status(400).json({
        'success': false,
        'error': {
          'code': 'EXIF_ERROR',
          'message': e.toString(),
        },
      });
    }
  }

  Future<void> clean(Request req, Response res) async {
    try {
      final body = await req.body;

      final path = body['image'] as String;

      final bytes = await imageService.load(path);

      final image = await imageService.decode(bytes);

      final cleanedImage = imageService.clean(image);

      final exif = await exifService.extract(cleanedImage.getBytes());

      res.status(200).json({
        "success": true,
        "message": "Image cleaned and normalized",
        "data": {
          "exif": exif,
        }
      });
    } catch (e) {
      res.status(400).json({
        'success': false,
        'error': {
          'code': 'CLEAN_ERROR',
          'message': e.toString(),
        },
      });
    }
  }

  Future<void> secure(Request req, Response res) async {
    try {
      final body = await req.body;

      final path = body['image'] as String;

      final bytes = await imageService.load(path);

      final securedImageBytes = exifService.secure(bytes);

      final exif = await exifService.extract(securedImageBytes);

      res.status(200).json({
        "success": true,
        "message": "Sensitive metadata removed successfully",
        "data": {
          "exif": exif,
        }
      });
    } catch (e) {
      res.status(400).json({
        'success': false,
        'error': {
          'code': 'SECURE_ERROR',
          'message': e.toString(),
        },
      });
    }
  }
}
