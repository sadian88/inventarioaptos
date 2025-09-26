import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/apartment_list_page.dart';
import 'providers/inventory_provider.dart';

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Inventario de Apartamentos',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          home: const ApartmentListPage(),
        );
      },
    );
  }
}
