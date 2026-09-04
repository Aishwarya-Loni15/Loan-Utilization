import 'dart:io';

class FileUtils {
  static String getFileName(File file) {
    return file.path.split('/').last;
  }

  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
}
