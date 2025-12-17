// product_model.dart
import 'package:shop/constants.dart';

class ProductModel {
  final int id;
  final String title;
  final String brandName;
  final String image;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;

  ProductModel({
    required this.id,
    required this.title,
    required this.brandName,
    required this.image,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = double.tryParse(json['price'].toString()) ?? 0;
    final discountPrice =
        json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null;
    final discountPercent =
        (discountPrice != null) ? ((1 - discountPrice / price) * 100).round() : null;

    // Xử lý main_image
    String imageUrl = json['main_image'] ?? '';

// Bỏ dấu / đầu nếu có
    if (imageUrl.startsWith('/')) {
      imageUrl = imageUrl.substring(1);
    }

// Decode URL
    imageUrl = Uri.decodeFull(imageUrl);

// Sửa URL thiếu dấu / sau https:
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://${imageUrl.replaceFirst(RegExp(r'^https?://?'), '')}';
    } else if (imageUrl.startsWith('https:/') && !imageUrl.startsWith('https://')) {
      imageUrl = imageUrl.replaceFirst('https:/', 'https://');
    }
    return ProductModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      brandName: json['brand']?['name'] ?? '',
      image: imageUrl,
      price: price,
      priceAfterDiscount: discountPrice,
      discountPercent: discountPercent,
    );
  }
}

// Demo data
List<ProductModel> demoPopularProducts = [
  ProductModel(
    id: 1,
    image: productDemoImg1,
    title: "Mountain Warehouse for Women",
    brandName: "Lipsy London",
    price: 540,
    priceAfterDiscount: 420,
    discountPercent: 20,
  ),
  ProductModel(
    id: 2,
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy London",
    price: 800,
  ),
  ProductModel(
    id: 3,
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy London",
    price: 650.62,
    priceAfterDiscount: 420,
    discountPercent: 20,
  ),
  ProductModel(
    id: 4,
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy London",
    price: 1264,
    priceAfterDiscount: 420,
    discountPercent: 20,
  ),
  ProductModel(
    id: 5,
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy London",
    price: 650.62,
    priceAfterDiscount: 390.36,
    discountPercent: 40,
  ),
  ProductModel(
    id: 6,
    image: "https://i.imgur.com/h2LqppX.png",
    title: "White Satin Corset Top",
    brandName: "Lipsy London",
    price: 1264,
    priceAfterDiscount: 1200.8,
    discountPercent: 5,
  ),
];

List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    id: 7,
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy London",
    price: 650.62,
    priceAfterDiscount: 390.36,
    discountPercent: 40,
  ),
  ProductModel(
    id: 8,
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy London",
    price: 1264,
    priceAfterDiscount: 1200.8,
    discountPercent: 5,
  ),
  ProductModel(
    id: 9,
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy London",
    price: 800,
    priceAfterDiscount: 680,
    discountPercent: 15,
  ),
];

List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    id: 10,
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy London",
    price: 650.62,
    priceAfterDiscount: 390.36,
    discountPercent: 40,
  ),
  ProductModel(
    id: 11,
    image: "https://i.imgur.com/h2LqppX.png",
    title: "White Satin Corset Top",
    brandName: "Lipsy London",
    price: 1264,
    priceAfterDiscount: 1200.8,
    discountPercent: 5,
  ),
  ProductModel(
    id: 12,
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy London",
    price: 800,
    priceAfterDiscount: 680,
    discountPercent: 15,
  ),
];

List<ProductModel> kidsProducts = [
  ProductModel(
    id: 13,
    image: "https://i.imgur.com/dbbT6PA.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy London",
    price: 650.62,
    priceAfterDiscount: 590.36,
    discountPercent: 24,
  ),
  ProductModel(
    id: 14,
    image: "https://i.imgur.com/7fSxC7k.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy London",
    price: 650.62,
  ),
  ProductModel(
    id: 15,
    image: "https://i.imgur.com/pXnYE9Q.png",
    title: "Ruffle-Sleeve Ponte-Knit Sheath",
    brandName: "Lipsy London",
    price: 400,
  ),
  ProductModel(
    id: 16,
    image: "https://i.imgur.com/V1MXgfa.png",
    title: "Green Mountain Beta Warehouse",
    brandName: "Lipsy London",
    price: 400,
    priceAfterDiscount: 360,
    discountPercent: 20,
  ),
  ProductModel(
    id: 17,
    image: "https://i.imgur.com/8gvE5Ss.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy London",
    price: 654,
  ),
  ProductModel(
    id: 18,
    image: "https://i.imgur.com/cBvB5YB.png",
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy London",
    price: 250,
  ),
];

class ProductDetailModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final double rating;
  final int numReviews;
  final bool isAvailable;
  final BrandModel brand;
  final List<ProductVariantModel> variants;
  final List<ReviewModel> reviews;
  final List<ShippingInfoModel> shippingInfo;
  final List<ReturnPolicyModel> returnPolicy;
  final String mainImage;
  final List<String> otherImages;

  ProductDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.rating,
    required this.numReviews,
    required this.isAvailable,
    required this.brand,
    required this.variants,
    required this.reviews,
    required this.shippingInfo,
    required this.returnPolicy,
    required this.mainImage,
    required this.otherImages,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: double.tryParse(json['discount_price'].toString()) ?? 0.0,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      numReviews: json['num_reviews'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      brand: BrandModel.fromJson(json['brand']),
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) => ProductVariantModel.fromJson(v))
              .toList() ??
          [],
      reviews:
          (json['reviews'] as List<dynamic>?)?.map((r) => ReviewModel.fromJson(r)).toList() ?? [],
      shippingInfo: (json['shipping_info'] as List<dynamic>?)
              ?.map((s) => ShippingInfoModel.fromJson(s))
              .toList() ??
          [],
      returnPolicy: (json['return_policy'] as List<dynamic>?)
              ?.map((p) => ReturnPolicyModel.fromJson(p))
              .toList() ??
          [],
      mainImage: json['main_image'] ?? '',
      otherImages:
          (json['other_images'] as List<dynamic>?)?.map((i) => i.toString()).toList() ?? [],
    );
  }
}

class BrandModel {
  final int id;
  final String name;
  final String? logoUrl;

  BrandModel({required this.id, required this.name, this.logoUrl});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
    );
  }
}

class ProductVariantModel {
  final int id;
  final String name;
  final String color;
  final String size;
  final int stock;
  final double price;
  final double discountPrice;

  ProductVariantModel({
    required this.id,
    required this.name,
    required this.color,
    required this.size,
    required this.stock,
    required this.price,
    required this.discountPrice,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      size: json['size'],
      stock: json['stock'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: double.tryParse(json['discount_price'].toString()) ?? 0.0,
    );
  }
}

class ReviewModel {
  final int id;
  final String user;
  final int rating;
  final String comment;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      user: json['user'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }
}

class ShippingInfoModel {
  final int id;
  final String info;

  ShippingInfoModel({required this.id, required this.info});

  factory ShippingInfoModel.fromJson(Map<String, dynamic> json) {
    return ShippingInfoModel(
      id: json['id'],
      info: json['info'],
    );
  }
}

class ReturnPolicyModel {
  final int id;
  final String policyText;

  ReturnPolicyModel({required this.id, required this.policyText});

  factory ReturnPolicyModel.fromJson(Map<String, dynamic> json) {
    return ReturnPolicyModel(
      id: json['id'],
      policyText: json['policy_text'],
    );
  }
}
