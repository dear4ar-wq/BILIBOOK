import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageUtils {
  static Future<File?> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = p.basename(file.path);
    final targetPath = p.join(tempDir.path, "compressed_$fileName");

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );

    if (result == null) return null;
    return File(result.path);
  }
}
