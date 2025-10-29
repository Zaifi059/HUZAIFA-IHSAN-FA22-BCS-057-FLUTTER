import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  static Future<Directory> _ensurePatientDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'patient_files'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String> saveFileToAppDir(File source) async {
    final dir = await _ensurePatientDir();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(source.path)}';
    final destPath = p.join(dir.path, fileName);
    final dest = await source.copy(destPath);
    return dest.path;
  }
}


