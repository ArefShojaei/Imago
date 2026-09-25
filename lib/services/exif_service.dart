import 'dart:typed_data';

import 'package:exif_reader/exif_reader.dart';
import 'package:image/image.dart' as img;

class ExifService {
  Future<Map<String, String>> extract(Uint8List bytes) async {
    final data = await readExifFromBytes(bytes);

    final Map<String, String> tags = {};

    for (final entry in data.tags.entries) {
      tags[entry.key] = entry.value.printable;
    }

    return tags;
  }

  Map<String, String> summary(Map<String, String> tags) {
    return {
      'make': tags['Image Make']!,
      'model': tags['Image Model']!,
      'date': tags['EXIF DateTimeOriginal'] ?? tags['Image DateTime']!,
      'orientation': tags['Image Orientation']!,
      'gps_latitude': tags['GPS GPSLatitude']!,
      'gps_longitude': tags['GPS GPSLongitude']!,
      'software': tags['Image Software']!,
      'width': tags['EXIF ExifImageWidth'] ?? tags['Image ImageWidth']!,
      'height': tags['EXIF ExifImageHeight'] ?? tags['Image ImageLength']!,
      'all_tags_count': tags.length as String,
    };
  }

  Uint8List secure(
    Uint8List bytes, {
    int quality = 92,
  }) {
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Could not decode image');

    if (!image.hasExif)
      return Uint8List.fromList(img.encodeJpg(image, quality: quality));

    final newExif = img.ExifData();

    newExif.imageIfd.software = 'Secure Image Processor';

    image.exif = newExif;

    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}
