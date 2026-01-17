// lib/data/models/supplier_model.dart
class Supplier {
  int? id;
  String name;
  String? contactPerson;
  String? phone;
  String? email;
  String? address;
  String? gstNumber;
  String? paymentTerms;
  double? creditLimit;
  DateTime? lastOrderDate;
  String? notes;
  DateTime createdAt;

  Supplier({
    this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.paymentTerms,
    this.creditLimit,
    this.lastOrderDate,
    this.notes,
    required this.createdAt,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      name: map['name'] as String,
      contactPerson: map['contact_person'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      gstNumber: map['gst_number'] as String?,
      paymentTerms: map['payment_terms'] as String?,
      creditLimit: (map['credit_limit'] as num?)?.toDouble(),
      lastOrderDate: map['last_order_date'] != null
          ? DateTime.parse(map['last_order_date'] as String)
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (gstNumber != null) 'gst_number': gstNumber,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (lastOrderDate != null) 'last_order_date': lastOrderDate!.toIso8601String(),
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, contact: $contactPerson)';
  }
}