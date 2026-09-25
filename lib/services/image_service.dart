import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum ImageFormat { jpg, png, webp }

mixin Loader_Decoder {
  Future<Uint8List> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    return file.readAsBytes();
  }

  img.Image decode(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }
    return image;
  }
}

mixin Export {
  Future<void> export(
    String path,
    img.Image image, {
    ImageFormat format = ImageFormat.jpg,
    int quality = 85,
  }) async {
    final bytes = encode(image, format: format, quality: quality);
    await File(path).writeAsBytes(bytes);
  }

  Uint8List encode(
    img.Image image, {
    ImageFormat format = ImageFormat.jpg,
    int quality = 85,
  }) {
    final q = quality.clamp(1, 100);

    switch (format) {
      case ImageFormat.jpg:
        return Uint8List.fromList(img.encodeJpg(image, quality: q));
      case ImageFormat.png:
        return Uint8List.fromList(img.encodePng(image));
      case ImageFormat.webp:
        return Uint8List.fromList(img.encodeWebP(image, quality: q));
    }
  }
}

mixin Transform {
  img.Image resize(
    img.Image source, {
    int? width,
    int? height,
    bool maintainAspect = true,
  }) {
    if (width == null && height == null) {
      throw ArgumentError('Either width or height must be provided');
    }

    return img.copyResize(
      source,
      width: width,
      height: height,
      maintainAspect: maintainAspect,
      interpolation: img.Interpolation.linear,
    );
  }

  img.Image crop(
    img.Image source, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    final safeX = x.clamp(0, source.width - 1);
    final safeY = y.clamp(0, source.height - 1);
    final safeWidth = width.clamp(1, source.width - safeX);
    final safeHeight = height.clamp(1, source.height - safeY);

    return img.copyCrop(
      source,
      x: safeX,
      y: safeY,
      width: safeWidth,
      height: safeHeight,
    );
  }

  img.Image rotate(img.Image source, {required double angle}) {
    return img.copyRotate(source, angle: angle);
  }

  img.Image blur(img.Image source, {int radius = 5}) {
    return img.gaussianBlur(source, radius: radius.clamp(1, 50));
  }

  img.Image grayscale(img.Image source) {
    return img.grayscale(source);
  }

  img.Image clean(img.Image source) {
    return img.copyResize(
      source,
      width: source.width,
      height: source.height,
    );
  }
}

mixin Watermark {
  img.Image addTextWatermark(
    img.Image source, {
    required String text,
    int fontSize = 24,
    img.Color? color,
    int x = 20,
    int y = 20,
    bool bottomRight = false,
  }) {
    final result =
        img.copyResize(source, width: source.width, height: source.height);
    final paintColor = color ?? img.ColorRgba8(255, 255, 255, 180);

    int drawX = x;
    int drawY = y;

    if (bottomRight) {
      drawX = source.width - (text.length * fontSize * 0.6).toInt() - 20;
      drawY = source.height - fontSize - 20;
    }

    img.drawString(
      result,
      text,
      font: img.arial24,
      x: drawX,
      y: drawY,
      color: paintColor,
    );

    return result;
  }

  img.Image addImageWatermark(
    img.Image source,
    img.Image watermark, {
    int x = 20,
    int y = 20,
    double opacity = 0.5,
    bool bottomRight = false,
  }) {
    final result =
        img.copyResize(source, width: source.width, height: source.height);

    int drawX = x;
    int drawY = y;

    if (bottomRight) {
      drawX = source.width - watermark.width - 20;
      drawY = source.height - watermark.height - 20;
    }

    img.compositeImage(
      result,
      watermark,
      dstX: drawX,
      dstY: drawY,
    );

    return result;
  }
}

class ImageService with Loader_Decoder, Export, Transform, Watermark {}
