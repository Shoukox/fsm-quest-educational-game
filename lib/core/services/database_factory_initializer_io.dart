import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Aktiviert SQLite über FFI unter Windows und Linux; mobile Anbindungen bleiben bestehen.
void initializeDatabaseFactoryForPlatform() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
