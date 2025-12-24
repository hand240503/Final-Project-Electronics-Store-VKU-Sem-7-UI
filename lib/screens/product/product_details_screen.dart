import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/components/review_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/components/product_reviews.dart';
import 'package:shop/screens/product/custom_modal_bottom_sheet.dart';
import 'package:shop/screens/product/product_returns_screen.dart';
import 'package:shop/services/products/product_service.dart';
import 'package:shop/services/recommendation/recommend_service.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late int productId;
  ProductDetailModel? productDetail;
  bool isLoading = true;

  // Similar products
  List<ProductModel> similarProducts = [];
  bool isLoadingSimilar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is int) {
      productId = args;
      _loadProductDetail(productId);
      _loadSimilarProducts(productId);
    } else {
      debugPrint("Không nhận được productId hợp lệ từ arguments: $args");
    }
  }

  Future<void> _loadProductDetail(int id) async {
    setState(() {
      isLoading = true;
    });

    final detail = await ProductService.fetchProductDetail(id);
    setState(() {
      productDetail = detail;
      isLoading = false;
    });
  }

  Future<void> _loadSimilarProducts(int id) async {
    setState(() {
      isLoadingSimilar = true;
    });

    try {
      final response = await RecommendationService.getSimilarProducts(
        productId: id,
        limit: 10,
      );

      // response['results'] đã là List<ProductModel> từ service
      setState(() {
        similarProducts = response['results'] as List<ProductModel>;
        isLoadingSimilar = false;
      });
    } catch (e) {
      debugPrint("Error loading similar products: $e");
      setState(() {
        isLoadingSimilar = false;
      });
    }
  }

  Map<int, int> countStarRatings(List<ReviewModel> reviews) {
    final Map<int, int> starCount = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };

    for (var review in reviews) {
      final int rating = review.rating.round().clamp(1, 5);
      starCount[rating] = (starCount[rating] ?? 0) + 1;
    }

    return starCount;
  }

  double safeRating(double? rating) {
    if (rating == null || rating.isNaN || rating.isInfinite) return 0.0;
    return rating.clamp(0.0, 5.0);
  }

  @override
  Widget build(BuildContext context) {
    final starStats = countStarRatings(productDetail?.reviews ?? []);

    return Scaffold(
      bottomNavigationBar: productDetail?.isAvailable == true
          ? CartButton(
              price: productDetail?.discountPrice ?? 0.0,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(productDetailModel: productDetail),
                );
              },
            )
          : NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            ProductImages(
              images: [
                if (productDetail?.mainImage != null) productDetail!.mainImage,
                if (productDetail?.otherImages != null) ...productDetail!.otherImages,
              ],
            ),
            ProductInfo(
              productId: productId,
              brand: productDetail?.brand.name ?? '',
              title: productDetail?.name ?? '',
              isAvailable: productDetail?.isAvailable ?? false,
              description:
                  productDetail?.description ?? 'No description available for this product.',
              rating: productDetail?.rating ?? 0.0,
              numOfReviews: productDetail?.reviews.length ?? 0,
              price: productDetail?.price ?? 0.0,
              discountPrice: productDetail?.discountPrice ?? 0.0,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductReturnsScreen(
                    des: productDetail?.shippingInfo.map((info) => "- ${info.info}").join('\n'),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductReturnsScreen(
                    des: productDetail?.returnPolicy
                        .map((policy) => "- ${policy.policyText}")
                        .join('\n'),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: safeRating(productDetail?.rating),
                  numOfReviews: productDetail?.reviews.length ?? 0,
                  numOfFiveStar: starStats[5] ?? 0,
                  numOfFourStar: starStats[4] ?? 0,
                  numOfThreeStar: starStats[3] ?? 0,
                  numOfTwoStar: starStats[2] ?? 0,
                  numOfOneStar: starStats[1] ?? 0,
                ),
              ),
            ),
            ProductReviews(reviews: productDetail?.reviews ?? []),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: isLoadingSimilar
                  ? const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : similarProducts.isEmpty
                      ? const SizedBox(
                          height: 220,
                          child: Center(
                            child: Text("No similar products found"),
                          ),
                        )
                      : SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: similarProducts.length,
                            itemBuilder: (context, index) {
                              final product = similarProducts[index];

                              return Padding(
                                padding: EdgeInsets.only(
                                    left: defaultPadding,
                                    right:
                                        index == similarProducts.length - 1 ? defaultPadding : 0),
                                child: ProductCard(
                                  image: product.image,
                                  title: product.title,
                                  brandName: product.brandName,
                                  price: product.price,
                                  // priceAfterDiscount: product.priceAfterDiscount,
                                  discountPercent: product.discountPercent,
                                  press: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/product-details',
                                      arguments: product.id,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
