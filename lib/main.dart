import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/inventory_provider.dart';
import 'repository/inventory_repository.dart';
import 'services/pdf_exporter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = InventoryRepository();
  final pdfExporter = PdfExporter();
  final provider = InventoryProvider(
    repository: repository,
    pdfExporter: pdfExporter,
  );

  await provider.initialize();

  runApp(
    ChangeNotifierProvider<InventoryProvider>.value(
      value: provider,
      child: const InventoryApp(),
    ),
  );
}
