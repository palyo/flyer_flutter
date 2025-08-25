import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

Future<String> downloadAndUnzipInvitation(String url,String categoryPath) async {
  // Extract category path from URL

  final dir = await getApplicationDocumentsDirectory();
  final downloadDir = Directory("${dir.path}/$categoryPath");

  await downloadDir.create(recursive: true);

  final zipFile = File("${downloadDir.path}/source.zip");

  final dio = Dio();
  await dio.download(url, zipFile.path);

  // unzip
  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {
    final outFile = File("${downloadDir.path}/${file.name}");
    if (file.isFile) {
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    } else {
      await Directory(outFile.path).create(recursive: true);
    }
  }

  return downloadDir.path;
}

String extractCategoryFromUrl(String url) {
  final uri = Uri.parse(url);
  // Split path segments
  final segments = uri.pathSegments;

  // Find index of "Cards" in path
  final index = segments.indexOf("Cards");
  if (index == -1 || index + 1 >= segments.length) {
    throw Exception("Invalid URL format");
  }

  // Take everything after "Cards" but before "source.zip"
  final categorySegments = segments.sublist(index + 1, segments.length - 1);

  // Re-join into category path
  return categorySegments.join("/");
}