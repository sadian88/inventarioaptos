import 'dart:convert';

import 'inventory_item.dart';

class InventorySection {
  const InventorySection({
    required this.id,
    required this.name,
    required this.items,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final List<InventoryItem> items;

  InventorySection copyWith({
    String? id,
    String? name,
    String? description,
    List<InventoryItem>? items,
  }) {
    return InventorySection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory InventorySection.fromMap(Map<String, dynamic> map) {
    return InventorySection(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      items: (map['items'] as List<dynamic>)
          .map((dynamic item) =>
              InventoryItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory InventorySection.fromJson(String source) =>
      InventorySection.fromMap(json.decode(source) as Map<String, dynamic>);
}
