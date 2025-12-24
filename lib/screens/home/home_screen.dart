import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/components/skleton/product/products_skelton.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/home/components/offer_carousel_and_categories.dart';
import 'package:shop/services/products/product_service.dart';
import 'package:shop/services/recommendation/recommend_service.dart';
import 'components/popular_products.dart';
import 'package:shop/models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Products from regular API
  List<ProductModel> popularProducts = [];
  List<ProductModel> saleProducts = [];
  List<ProductModel> bestSaleProducts = [];

  // Products from Recommendation API
  List<ProductModel> recommendedProducts = [];

  // Loading states
  bool isLoadingPopular = false;
  bool isLoadingSale = false;
  bool isLoadingBestSale = false;
  bool isLoadingRecommended = false;

  @override
  void initState() {
    super.initState();
    // Fetch regular products
    fetchProductsByType(parentId: 0, type: 'popular');
    fetchProductsByType(parentId: 0, type: 'sale');
    fetchProductsByType(parentId: 0, type: 'best_sale');

    // ✅ Fetch recommended products
    fetchRecommendedProducts();
  }

  /// ✅ NEW: Fetch products from Recommendation API
  Future<void> fetchRecommendedProducts() async {
    setState(() => isLoadingRecommended = true);

    try {
      final fetchedProducts = await RecommendationService.getPopularProducts(
        limit: 10,
      );

      setState(() {
        recommendedProducts = fetchedProducts;
        isLoadingRecommended = false;
      });
    } catch (e) {
      setState(() {
        recommendedProducts = [];
        isLoadingRecommended = false;
      });
      print('Lỗi khi fetch recommended products: $e');
    }
  }

  Future<void> fetchProductsByType({required int parentId, required String type}) async {
    switch (type) {
      case 'popular':
        setState(() => isLoadingPopular = true);
        break;
      case 'sale':
        setState(() => isLoadingSale = true);
        break;
      case 'best_sale':
        setState(() => isLoadingBestSale = true);
        break;
    }

    try {
      final fetchedProducts = await ProductService.fetchProducts(
        parentCategoryId: parentId,
        type: type,
      );

      setState(() {
        switch (type) {
          case 'popular':
            popularProducts = fetchedProducts;
            isLoadingPopular = false;
            break;
          case 'sale':
            saleProducts = fetchedProducts;
            isLoadingSale = false;
            break;
          case 'best_sale':
            bestSaleProducts = fetchedProducts;
            isLoadingBestSale = false;
            break;
        }
      });
    } catch (e) {
      setState(() {
        switch (type) {
          case 'popular':
            popularProducts = [];
            isLoadingPopular = false;
            break;
          case 'sale':
            saleProducts = [];
            isLoadingSale = false;
            break;
          case 'best_sale':
            bestSaleProducts = [];
            isLoadingBestSale = false;
            break;
        }
      });
      print('Lỗi khi fetch $type: $e');
    }
  }

  void onCategorySelected(Map<String, dynamic> category) {
    final parentId = category['id'] as int;

    if (parentId == 0) {
      fetchRecommendedProducts();
    }

    fetchProductsByType(parentId: parentId, type: 'popular');
    fetchProductsByType(parentId: parentId, type: 'sale');
    fetchProductsByType(parentId: parentId, type: 'best_sale');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Categories Carousel
            SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                onCategorySelected: onCategorySelected,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                      child: Row(
                        children: [
                          Text(
                            "Recommended For You",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "AI",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    isLoadingRecommended
                        ? const ProductsSkelton()
                        : ProductListSection(
                            title: "",
                            products: recommendedProducts,
                          ),
                  ],
                ),
              ),
            ),

            // Popular products (Regular API)
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: isLoadingPopular
                    ? const ProductsSkelton()
                    : ProductListSection(
                        title: "Popular Products",
                        products: popularProducts,
                      ),
              ),
            ),

            // Banner 1
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    discountParcent: 50,
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),

            // Best Sale Products
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: isLoadingBestSale
                    ? const ProductsSkelton()
                    : ProductListSection(
                        title: "Best Sale Products",
                        products: bestSaleProducts,
                      ),
              ),
            ),

            // Banner 2
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Black \nfriday",
                    subtitle: "50% Off",
                    bottomText: "Collection".toUpperCase(),
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),

            // Sale Products
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: isLoadingSale
                    ? const ProductsSkelton()
                    : ProductListSection(
                        title: "Sale Products",
                        products: saleProducts,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
