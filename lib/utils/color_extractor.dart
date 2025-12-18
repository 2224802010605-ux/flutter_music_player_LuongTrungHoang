import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color?> dominantColorFromFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(file),
        size: const Size(200, 200),
        maximumColorCount: 16,
      );
      return palette.dominantColor?.color;
    } catch (_) {
      return null;
    }
  }
}
