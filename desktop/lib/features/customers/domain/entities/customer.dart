class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final double creditLimit;
  final bool isSynced;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.creditLimit = 0.0,
    this.isSynced = false,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    double? creditLimit,
    bool? isSynced,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      creditLimit: creditLimit ?? this.creditLimit,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
