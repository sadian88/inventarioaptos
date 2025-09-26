import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import 'inventory_detail_page.dart';

class ApartmentListPage extends StatelessWidget {
  const ApartmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de apartamentos'),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.apartments.isEmpty) {
            return const Center(
              child: Text(
                'No hay apartamentos registrados. Usa el botón "+" para crear uno nuevo.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemBuilder: (context, index) {
              final apartment = provider.apartments[index];
              return ListTile(
                title: Text(apartment.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (apartment.address != null &&
                        apartment.address!.isNotEmpty)
                      Text(apartment.address!),
                    Text(
                      'Actualizado: '
                      '${TimeOfDay.fromDateTime(apartment.updatedAt).format(context)}'
                      ' · ${MaterialLocalizations.of(context).formatMediumDate(apartment.updatedAt)}',
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InventoryDetailPage(
                        apartmentId: apartment.id,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showApartmentActions(context, apartment.id);
                  },
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: provider.apartments.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateApartmentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo apartamento'),
      ),
    );
  }

  Future<void> _showCreateApartmentDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo apartamento'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del apartamento',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección (opcional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (created == true) {
      await context.read<InventoryProvider>().addApartment(
            name: nameController.text.trim(),
            address: addressController.text.trim().isEmpty
                ? null
                : addressController.text.trim(),
          );
    }
  }

  Future<void> _showApartmentActions(BuildContext context, String apartmentId) {
    final provider = context.read<InventoryProvider>();
    final apartment = provider.getApartment(apartmentId);
    if (apartment == null) {
      return Future.value();
    }

    final nameController = TextEditingController(text: apartment.name);
    final addressController = TextEditingController(text: apartment.address);
    final notesController = TextEditingController(text: apartment.notes);
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar apartamento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await provider.deleteApartment(apartmentId);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        await provider.updateApartment(
                          id: apartmentId,
                          name: nameController.text.trim(),
                          address: addressController.text.trim().isEmpty
                              ? null
                              : addressController.text.trim(),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
