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
    print(imageUrl);
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
