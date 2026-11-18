import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void initializeDatabaseFactoryForPlatform() {
  // SQLite läuft direkt in der Seite. Damit hängt das Öffnen der kleinen
  // Datenbank nicht von einer zur Paketversion passenden sqflite_sw.js ab.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
