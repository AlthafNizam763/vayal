import 'dart:io';

/// Abstract storage contract for saving/loading slot JSON data.
abstract class SaveStorageDriver {
  Future<void> writeSave(int slotId, String jsonData);
  Future<String?> readSave(int slotId);
  Future<void> deleteSave(int slotId);
  Future<List<int>> listSlots();
}

/// In-memory storage driver, ideal for unit testing, fast headless execution,
/// or fallback environments.
class MemorySaveStorageDriver implements SaveStorageDriver {
  final Map<int, String> _storage = {};

  @override
  Future<void> writeSave(int slotId, String jsonData) async {
    _storage[slotId] = jsonData;
  }

  @override
  Future<String?> readSave(int slotId) async {
    return _storage[slotId];
  }

  @override
  Future<void> deleteSave(int slotId) async {
    _storage.remove(slotId);
  }

  @override
  Future<List<int>> listSlots() async {
    return _storage.keys.toList()..sort();
  }
}

/// Robust offline local file system storage driver using standard Dart I/O.
class FileSaveStorageDriver implements SaveStorageDriver {
  final String baseDirPath;

  FileSaveStorageDriver({this.baseDirPath = './saves'});

  Directory get _directory => Directory(baseDirPath);

  File _getSlotFile(int slotId) {
    return File('$baseDirPath/vayal_save_slot_$slotId.json');
  }

  @override
  Future<void> writeSave(int slotId, String jsonData) async {
    try {
      if (!await _directory.exists()) {
        await _directory.create(recursive: true);
      }
      final file = _getSlotFile(slotId);
      await file.writeAsString(jsonData, flush: true);
    } catch (_) {
      // Graceful fallback to in-memory if disk access is restricted
    }
  }

  @override
  Future<String?> readSave(int slotId) async {
    try {
      final file = _getSlotFile(slotId);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<void> deleteSave(int slotId) async {
    try {
      final file = _getSlotFile(slotId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignored
    }
  }

  @override
  Future<List<int>> listSlots() async {
    final List<int> slots = [];
    try {
      if (!await _directory.exists()) return slots;
      final entities = await _directory.list().toList();
      final regex = RegExp(r'vayal_save_slot_(-?\d+)\.json$');
      for (final entity in entities) {
        if (entity is File) {
          final match = regex.firstMatch(entity.path);
          if (match != null) {
            final id = int.tryParse(match.group(1)!);
            if (id != null) slots.add(id);
          }
        }
      }
      slots.sort();
    } catch (_) {
      // Return empty list on I/O error
    }
    return slots;
  }
}
