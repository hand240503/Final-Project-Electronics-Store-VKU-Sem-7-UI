import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/components/skleton/product/products_skelton.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/home/components/offer_carousel_and_categories.dart';
import 'package:shop/services/products/product_service.dart';
import 'components/popular_products.dart';
import 'package:shop/models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductModel> popularProducts = [];
  List<ProductModel> saleProducts = [];
  List<ProductModel> bestSaleProducts = [];
  bool isLoadingPopular = false;
  bool isLoadingSale = false;
  bool isLoadingBestSale = false;

  @override
  void initState() {
    super.initState();
    fetchProductsByType(parentId: 0, type: 'popular');
    fetchProductsByType(parentId: 0, type: 'sale');
    fetchProductsByType(parentId: 0, type: 'best_sale');
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
    print('Đã chọn category parent: $parentId');

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
            SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                onCategorySelected: onCategorySelected,
              ),
            ),
            // Popular products
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: isLoadingPopular
                    ? const ProductsSkelton()
                    : ProductListSection(title: "Popular Products", products: popularProducts),
              ),
            ),
            // Sale products

            // Best sale products

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
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: isLoadingBestSale
                    ? const ProductsSkelton()
                    : ProductListSection(title: "Best SaleProducts", products: bestSaleProducts),
              ),
            ),
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: isLoadingSale
                    ? const ProductsSkelton()
                    : ProductListSection(title: "Sale Products", products: saleProducts),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
