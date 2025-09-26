import 'package:flutter/material.dart';

import '../models/inventory_item.dart';

class ItemConditionSelector extends StatelessWidget {
  const ItemConditionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ItemCondition value;
  final ValueChanged<ItemCondition> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ItemCondition>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Estado',
      ),
      items: ItemCondition.values
          .map(
            (condition) => DropdownMenuItem<ItemCondition>(
              value: condition,
              child: Text(condition.label),
            ),
          )
          .toList(),
      onChanged: (condition) {
        if (condition != null) {
          onChanged(condition);
        }
      },
    );
  }
}
