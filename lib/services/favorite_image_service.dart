import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteImageService {
  static const _storageKey = 'favorite_image_files_v1';

  static Future<Directory> _directory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(documents.path, 'favorite_images'));
    await directory.create(recursive: true);
    return directory;
  }

  static Future<List<File>> list() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getStringList(_storageKey) ?? const [];
    final directory = await _directory();
    final files = <File>[];
    final validNames = <String>[];
    for (final name in encoded) {
      final file = File(path.join(directory.path, name));
      if (await file.exists()) {
        files.add(file);
        validNames.add(name);
      }
    }
    if (validNames.length != encoded.length) {
      await preferences.setStringList(_storageKey, validNames);
    }
    return files;
  }

  static Future<void> add(File source) async {
    if (!await source.exists()) return;
    final directory = await _directory();
    final extension = path.extension(source.path).toLowerCase();
    final fileName =
        'favorite_${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    await source.copy(path.join(directory.path, fileName));
    final preferences = await SharedPreferences.getInstance();
    final files = preferences.getStringList(_storageKey) ?? <String>[];
    files.insert(0, fileName);
    await preferences.setStringList(_storageKey, files);
  }

  static Future<void> remove(File file) async {
    final directory = await _directory();
    final name = path.basename(file.path);
    if (path.dirname(file.path) == directory.path && await file.exists()) {
      await file.delete();
    }
    final preferences = await SharedPreferences.getInstance();
    final files = preferences.getStringList(_storageKey) ?? <String>[];
    files.remove(name);
    await preferences.setStringList(_storageKey, files);
  }
}
