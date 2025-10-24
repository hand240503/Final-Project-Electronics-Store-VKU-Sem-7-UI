import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/routes/route_constants.dart';
import '../../../../constants.dart';

List<CategoryModel> demoCategories = [
  CategoryModel(title: "All Categories"),
  CategoryModel(title: "On Sale", svgSrc: "assets/icons/Sale.svg", route: logInScreenRoute),
  CategoryModel(title: "Man's", svgSrc: "assets/icons/Man.svg"),
  CategoryModel(title: "Woman’s", svgSrc: "assets/icons/Woman.svg"),
  CategoryModel(title: "Kids", svgSrc: "assets/icons/Child.svg", route: logInScreenRoute),
];

class Categories extends StatefulWidget {
  final List<Map<String, dynamic>> categoriesData;
  final void Function(Map<String, dynamic>)? onCategorySelected;

  const Categories({
    super.key,
    required this.categoriesData,
    this.onCategorySelected,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.categoriesData.isNotEmpty) {
      selectedCategoryId = widget.categoriesData.first['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(widget.categoriesData.length, (index) {
            final category = widget.categoriesData[index];
            final isSelected = selectedCategoryId == category['id'];

            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? defaultPadding : defaultPadding / 2,
                right: index == widget.categoriesData.length - 1 ? defaultPadding : 0,
              ),
              child: CategoryBtn(
                category: category['title'] ?? category['name'] ?? '',
                svgSrc: category['svgSrc'],
                isActive: isSelected,
                press: () {
                  setState(() {
                    selectedCategoryId = category['id'];
                  });
                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(category);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive ? primaryColor : Theme.of(context).dividerColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
