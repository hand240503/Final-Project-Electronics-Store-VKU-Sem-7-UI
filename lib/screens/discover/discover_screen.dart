import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/search/components/search_form.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/services/products/product_service.dart';
import 'package:shop/routes/route_constants.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await ProductService.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleFilter() {
    // Xử lý bộ lọc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter button pressed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Form
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SearchForm(
                onChanged: (value) {
                  _searchController.text = value ?? '';
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _performSearch(value ?? '');
                    }
                  });
                },
                onTabFilter: _handleFilter,
                focusNode: _focusNode,
              ),
            ),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                  vertical: defaultPadding / 2,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lỗi: $_errorMessage',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _isSearching && _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            'Không tìm thấy sản phẩm',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : _isSearching && _searchResults.isNotEmpty
                          ? _buildSearchResults()
                          : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  // Kết quả tìm kiếm
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(
            left: defaultPadding,
            right: defaultPadding,
            bottom: defaultPadding,
          ),
          child: SecondaryProductCard(
            image: product.image,
            brandName: product.brandName,
            title: product.title,
            price: product.price,
            discountPercent: product.discountPercent ?? 0,
            priceAfterDiscount: product.priceAfterDiscount,
            press: () {
              Navigator.pushNamed(
                context,
                productDetailsScreenRoute,
                arguments: product.id,
              );
            },
          ),
        );
      },
    );
  }
}
