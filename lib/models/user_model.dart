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
    this.userId,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.ward,
    required this.district,
    required this.city,
    required this.isDefault,
  });

  /// 🔁 COPY WITH (bắt buộc cho immutable model)
  UserAddress copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? phone,
    String? addressLine,
    String? ward,
    String? district,
    String? city,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      phone: json['phone'],
      addressLine: json['address_line'],
      ward: json['ward'],
      district: json['district'],
      city: json['city'],
      isDefault: json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id,
        if (userId != null) "user_id": userId,
        "full_name": fullName,
        "phone": phone,
        "address_line": addressLine,
        "ward": ward,
        "district": district,
        "city": city,
        "is_default": isDefault,
      };
}
