import 'dart:convert';
import 'dart:io';

class LocalJsonStore {
  LocalJsonStore({required this.file});

  factory LocalJsonStore.defaultStore() {
    return LocalJsonStore(
      file: File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'healtrack_daily_local_store.json',
      ),
    );
  }

  final File file;

  Future<List<Map<String, dynamic>>?> readList(String key) async {
    final data = await _readAll();
    final value = data[key];
    if (value is! List) {
      return null;
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    final data = await _readAll();
    data[key] = value;
    await _writeAll(data);
  }

  Future<Map<String, dynamic>?> readMap(String key) async {
    final data = await _readAll();
    final value = data[key];
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }

  Future<void> writeMap(String key, Map<String, dynamic>? value) async {
    final data = await _readAll();
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
    await _writeAll(data);
  }

  Future<Map<String, dynamic>> _readAll() async {
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(content);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Future<void> _writeAll(Map<String, dynamic> data) async {
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(jsonEncode(data));
  }
}
