import 'package:shop/models/product_model.dart';

class OrderItem {
  final ProductDetailModel? productDetailModel;
  final int productId;
  final String name;
  final String image;
  final int price;
  final int quantity;
  final int? selectedVariantId;
  final String? variantName;
  final String? brandName;

  OrderItem({
    this.productDetailModel,
    int? productId,
    String? name,
    String? image,
    int? price,
    required this.quantity,
    this.selectedVariantId,
    this.variantName,
    this.brandName,
  })  : productId = productId ?? productDetailModel?.id ?? 0,
        name = name ?? productDetailModel?.name ?? '',
        image = image ?? productDetailModel?.mainImage ?? '',
        price = price ?? (productDetailModel?.discountPrice ?? 0).toInt();

  // Factory constructor để tạo từ ProductDetailModel (từ ProductDetail screen)
  factory OrderItem.fromProductDetail({
    required ProductDetailModel productDetailModel,
    required int quantity,
    int? selectedVariantId,
  }) {
    return OrderItem(
      productDetailModel: productDetailModel,
      productId: productDetailModel.id ?? 0,
      name: productDetailModel.name,
      image: productDetailModel.mainImage,
      price: (productDetailModel.discountPrice ?? 0).toInt(),
      quantity: quantity,
      selectedVariantId: selectedVariantId,
      brandName: productDetailModel.brand.name,
    );
  }

  // Factory constructor để tạo từ cart item
  factory OrderItem.fromCartItem(Map<String, dynamic> cartItem) {
    return OrderItem(
      productId: cartItem['product_id'] as int,
      name: cartItem['name'] as String,
      image: cartItem['image'] as String,
      price: cartItem['price'] as int,
      quantity: cartItem['quantity'] as int,
      selectedVariantId: cartItem['variant_id'] as int?,
      variantName: cartItem['variant'] as String?,
      brandName: null,
    );
  }
}
