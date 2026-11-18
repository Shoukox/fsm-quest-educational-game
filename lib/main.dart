import 'package:bachelor/app/app.dart';
import 'package:bachelor/core/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initialisiert Flutter und die plattformspezifische Datenbank vor dem App-Start.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseService.initializeFactory();

  // Der gemeinsame ProviderScope stellt den Riverpod-Zustand der App bereit.
  runApp(const ProviderScope(child: FsmQuestApp()));
}
