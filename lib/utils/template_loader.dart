import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../flyer.dart';

Future<TemplateData> loadTemplate(String path, double newPosterWidth, double newPosterHeight) async {
  final String jsonString = await rootBundle.loadString(path);
  final Map<String, dynamic> jsonData = jsonDecode(jsonString);
  final template = TemplateData.fromJson(jsonData, newPosterWidth ?? 1000, newPosterHeight ?? 1400);
  return template;
}
