class UserAddress {
  final int? id; // optional
  final int? userId;
  final String fullName;
  final String phone;
  final String addressLine;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;

  UserAddress({
    this.id,
    this.userId, // có thể không truyền
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.ward,
    required this.district,
    required this.city,
    required this.isDefault,
  });
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      addressLine: json['address_line'],
      ward: json['ward'],
      district: json['district'],
      city: json['city'],
      isDefault: json['is_default'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id, // chỉ gửi nếu có
        "full_name": fullName,
        "phone": phone,
        "address_line": addressLine,
        "ward": ward,
        "district": district,
        "city": city,
        "is_default": isDefault,
      };
}
