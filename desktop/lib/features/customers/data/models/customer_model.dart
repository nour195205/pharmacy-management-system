import 'package:desktop/features/customers/domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    super.phone,
    super.address,
    super.creditLimit = 0.0,
    super.isSynced = false,
  });

  // From database map (SQLite)
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      creditLimit: (map['credit_limit'] as num).toDouble(),
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  // To database map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'credit_limit': creditLimit,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // From remote JSON (Laravel REST API)
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      creditLimit: json['credit_limit'] != null 
          ? double.tryParse(json['credit_limit'].toString()) ?? 0.0
          : 0.0,
      isSynced: true,
    );
  }

  // To remote JSON (Laravel REST API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone ?? '',
      'address': address ?? '',
      'credit_limit': creditLimit,
    };
  }

  // Cast entity to model helper
  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      creditLimit: customer.creditLimit,
      isSynced: customer.isSynced,
    );
  }
}
