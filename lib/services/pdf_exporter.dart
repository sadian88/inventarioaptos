import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/apartment_inventory.dart';
import '../models/inventory_item.dart';
import '../models/inventory_section.dart';

class PdfExporter {
  Future<File> generate(ApartmentInventory apartment) async {
    final document = pw.Document();
    final dateFormatter = DateFormat.yMMMMd('es');
    final now = DateTime.now();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return <pw.Widget>[
            _buildHeader(apartment, now, dateFormatter),
            ...apartment.sections
                .map<pw.Widget>((section) => _buildSection(section))
                .toList(),
          ];
        },
      ),
    );

    final bytes = await document.save();
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedName = _sanitizeFileName(apartment.name);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = 'inventario_${sanitizedName}_$timestamp.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  pw.Widget _buildHeader(
    ApartmentInventory apartment,
    DateTime now,
    DateFormat dateFormatter,
  ) {
    final createdAt = dateFormatter.format(apartment.createdAt);
    final updatedAt = dateFormatter.format(apartment.updatedAt);
    final generatedAt = dateFormatter.format(now);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Inventario de ${apartment.name}',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (apartment.address != null && apartment.address!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text('Dirección: ${apartment.address!}'),
          ),
        if (apartment.notes != null && apartment.notes!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text('Notas: ${apartment.notes!}'),
          ),
        pw.SizedBox(height: 12),
        pw.Text('Creado: $createdAt'),
        pw.Text('Actualizado: $updatedAt'),
        pw.Text('Generado: $generatedAt'),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildSection(InventorySection section) {
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final baseStyle = pw.TextStyle(fontSize: 10);

    final rows = <List<String>>[
      <String>['Ítem', 'Estado', 'Observaciones'],
      ...section.items.map(
        (InventoryItem item) => <String>[
          item.label,
          item.condition.label,
          item.notes?.isNotEmpty == true ? item.notes! : '-',
        ],
      ),
    ];

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            section.name,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          if (section.description != null && section.description!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(section.description!),
            ),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            data: rows,
            headerStyle: headerStyle,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
            cellStyle: baseStyle,
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            columnWidths: <int, pw.TableColumnWidth>{
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(4),
            },
          ),
        ],
      ),
    );
  }

  String _sanitizeFileName(String value) {
    final sanitized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+', caseSensitive: false), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return sanitized.isEmpty ? 'apartamento' : sanitized;
  }
}
