import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_item.dart';
import '../models/inventory_section.dart';
import '../providers/inventory_provider.dart';
import '../widgets/item_condition_selector.dart';

class InventoryDetailPage extends StatefulWidget {
  const InventoryDetailPage({
    super.key,
    required this.apartmentId,
  });

  final String apartmentId;

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  final Map<String, TextEditingController> _notesControllers = {};

  @override
  void dispose() {
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerForItem(InventoryItem item) {
    final existing = _notesControllers[item.id];
    if (existing != null) {
      final updatedText = item.notes ?? '';
      if (existing.text != updatedText) {
        existing.value = existing.value.copyWith(
          text: updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );
      }
      return existing;
    }
    final controller = TextEditingController(text: item.notes ?? '');
    _notesControllers[item.id] = controller;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final apartment = provider.getApartment(widget.apartmentId);
        if (apartment == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Inventario'),
            ),
            body: const Center(
              child: Text('No se encontró el apartamento solicitado.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(apartment.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Exportar a PDF',
                onPressed: () => _exportPdf(context, provider),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apartment.sections.length,
            itemBuilder: (context, index) {
              final section = apartment.sections[index];
              return _SectionCard(
                section: section,
                buildItem: (item) => _InventoryItemEditor(
                  apartmentId: apartment.id,
                  item: item,
                  controller: _controllerForItem(item),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    InventoryProvider provider,
  ) async {
    final path = await provider.exportApartmentPdf(widget.apartmentId);
    if (!context.mounted) {
      return;
    }
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible generar el PDF'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte guardado en: $path'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.buildItem,
  });

  final InventorySection section;
  final Widget Function(InventoryItem item) buildItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (section.description != null &&
                section.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(section.description!),
              ),
            const SizedBox(height: 12),
            ...section.items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildItem(item),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _InventoryItemEditor extends StatelessWidget {
  const _InventoryItemEditor({
    required this.apartmentId,
    required this.item,
    required this.controller,
  });

  final String apartmentId;
  final InventoryItem item;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InventoryProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: ItemConditionSelector(
                value: item.condition,
                onChanged: (condition) {
                  provider.updateItemValues(
                    apartmentId: apartmentId,
                    itemId: item.id,
                    condition: condition,
                    notes: controller.text.trim().isEmpty
                        ? null
                        : controller.text.trim(),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Observaciones',
          ),
          minLines: 1,
          maxLines: 3,
          onChanged: (value) {
            final normalized = value.trim().isEmpty ? null : value.trim();
            if (normalized == item.notes) {
              return;
            }
            provider.updateItemValues(
              apartmentId: apartmentId,
              itemId: item.id,
              condition: item.condition,
              notes: normalized,
            );
          },
        ),
      ],
    );
  }
}
