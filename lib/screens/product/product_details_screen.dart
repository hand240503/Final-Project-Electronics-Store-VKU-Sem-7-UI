import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/buy_full_ui_kit.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/components/review_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/custom_modal_bottom_sheet.dart';
import 'package:shop/screens/product/product_returns_screen.dart';
import 'package:shop/services/products/product_service.dart';

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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is int) {
      productId = args;
      _loadProductDetail(productId);
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
              price: productDetail?.price ?? 0.0,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(productDetailModel: productDetail),
                );
              },
            )
          :

          /// If product is not available then show [NotifyMeCard]
          NotifyMeCard(
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
              brand: productDetail?.brand.name ?? '',
              title: productDetail?.name ?? '',
              isAvailable: productDetail?.isAvailable ?? false,
              description:
                  productDetail?.description ?? 'No description available for this product.',
              rating: productDetail?.rating ?? 0.0,
              numOfReviews: productDetail?.reviews.length ?? 0,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              press: () {},
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
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
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                // Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
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
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding, right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      image: productDemoImg2,
                      title: "Sleeveless Tiered Dobby Swing Dress",
                      brandName: "LIPSY LONDON",
                      price: 24.65,
                      priceAfterDiscount: index.isEven ? 20.99 : null,
                      discountPercent: index.isEven ? 25 : null,
                      press: () {},
                    ),
                  ),
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
