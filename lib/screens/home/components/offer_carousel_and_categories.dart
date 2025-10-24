import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/components/skleton/others/categories_skelton.dart';
import 'package:shop/screens/home/components/offers_carousel.dart';
import 'package:shop/services/products/category_service.dart';

import '../../../../constants.dart';
import 'categories.dart';

final storage = FlutterSecureStorage();

class OffersCarouselAndCategories extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onCategorySelected;

  const OffersCarouselAndCategories({
    super.key,
    this.onCategorySelected,
  });

  @override
  State<OffersCarouselAndCategories> createState() => _OffersCarouselAndCategoriesState();
}

class _OffersCarouselAndCategoriesState extends State<OffersCarouselAndCategories> {
  bool isLoading = true;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  final categoryService = CategoryService(storage: FlutterSecureStorage());

  Future<void> loadCategories() async {
    setState(() => isLoading = true);
    final data = await categoryService.fetchCategories();

    final allCategory = {
      'id': 0,
      'name': 'All Categories',
      'svgSrc': null,
      'slug': 'all-categories',
      'subCategories': [],
    };
    final updatedData = [allCategory, ...data];

    setState(() {
      categories = updatedData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OffersCarousel(),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Categories",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        isLoading
            ? const CategoriesSkelton()
            : Categories(
                categoriesData: categories,
                onCategorySelected: widget.onCategorySelected, // truyền callback xuống
              ),
      ],
    );
  }
}
