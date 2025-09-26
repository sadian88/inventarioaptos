import 'dart:convert';

enum ItemCondition {
  excellent,
  good,
  needsMaintenance,
  damaged,
  missing,
}

extension ItemConditionExtension on ItemCondition {
  String get label {
    switch (this) {
      case ItemCondition.excellent:
        return 'Excelente';
      case ItemCondition.good:
        return 'Bueno';
      case ItemCondition.needsMaintenance:
        return 'Requiere mantenimiento';
      case ItemCondition.damaged:
        return 'Dañado';
      case ItemCondition.missing:
        return 'No existe';
    }
  }

  String get storageValue => name;

  static ItemCondition fromStorage(String value) {
    return ItemCondition.values.firstWhere(
      (condition) => condition.storageValue == value,
      orElse: () => ItemCondition.good,
    );
  }
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.label,
    required this.sectionId,
    this.condition = ItemCondition.good,
    this.notes,
  });

  final String id;
  final String label;
  final String sectionId;
  final ItemCondition condition;
  final String? notes;

  InventoryItem copyWith({
    String? id,
    String? label,
    ItemCondition? condition,
    String? sectionId,
    String? notes,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      label: label ?? this.label,
      sectionId: sectionId ?? this.sectionId,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'sectionId': sectionId,
      'condition': condition.storageValue,
      'notes': notes,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      label: map['label'] as String,
      sectionId: map['sectionId'] as String,
      condition: ItemConditionExtension.fromStorage(
        map['condition'] as String,
      ),
      notes: map['notes'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryItem.fromJson(String source) =>
      InventoryItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
