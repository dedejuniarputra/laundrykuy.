import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_kuy/utils/helpers.dart';

class OrderModel {
  final String orderId;
  final String customerName;
  final String customerGender;
  final String customerPhone;
  final String category;
  final String serviceType;
  final String serviceSpeed;
  final double weight;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;
  final int uniqueCode;
  final String notes;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime estimatedDone;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerGender,
    required this.customerPhone,
    required this.category,
    required this.serviceType,
    required this.serviceSpeed,
    required this.weight,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.uniqueCode,
    required this.notes,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.estimatedDone,
  });

  /// Get display unit (kg / pcs)
  String get unitLabel => Helpers.getUnitLabel(category);

  /// Get display amount
  String get displayAmount {
    if (category == 'Kiloan') {
      return '${weight.toStringAsFixed(1)} kg';
    }
    return '$quantity pcs';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerGender: json['customerGender'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      category: json['category'] ?? '',
      serviceType: json['serviceType'] ?? '',
      serviceSpeed: json['serviceSpeed'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      uniqueCode: (json['uniqueCode'] ?? 0).toInt(),
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'Menunggu',
      createdBy: json['createdBy'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDone: (json['estimatedDone'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'customerGender': customerGender,
      'customerPhone': customerPhone,
      'category': category,
      'serviceType': serviceType,
      'serviceSpeed': serviceSpeed,
      'weight': weight,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'uniqueCode': uniqueCode,
      'notes': notes,
      'status': status,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'estimatedDone': Timestamp.fromDate(estimatedDone),
    };
  }

  OrderModel copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId,
      customerName: customerName,
      customerGender: customerGender,
      customerPhone: customerPhone,
      category: category,
      serviceType: serviceType,
      serviceSpeed: serviceSpeed,
      weight: weight,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      totalPrice: totalPrice,
      uniqueCode: uniqueCode,
      notes: notes,
      status: status ?? this.status,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDone: estimatedDone,
    );
  }
}
