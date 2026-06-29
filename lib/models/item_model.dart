import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_kuy/utils/helpers.dart';

class ItemModel {
  final String itemId;
  final String name;
  final String unit;
  final double price;
  final String note;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    required this.itemId,
    required this.name,
    required this.unit,
    required this.price,
    required this.note,
    required this.category,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: json['itemId'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      note: json['note'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'unit': unit,
      'price': price,
      'note': note,
      'category': category,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ItemModel copyWith({
    String? name,
    String? unit,
    double? price,
    String? note,
    String? category,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      itemId: itemId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      note: note ?? this.note,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}