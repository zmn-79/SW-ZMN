import 'dart:async';
import '../product/product_details_screen.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ProductService productService = ProductService();
  Timer? _debounce;

  List<ProductModel> products = [];
  int currentPage = 1;
  bool hasMore = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = value.trim();

      setState(() {
        query = trimmed;
      });

      if (trimmed.isEmpty) {
        setState(() {
          products = [];
          hasMore = false;
        });
        return;
      }

      search(reset: true);
    });
  }

  Future<void> search({bool reset = false}) async {
    setState(() {
      isLoading = reset;
    });

    try {
      final result = await productService.getProducts(page: 1, search: query);

      if (!mounted) return;

      setState(() {
        products = result.products;
        currentPage = result.page;
        hasMore = result.hasMore;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint("Search error: $e");
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || query.isEmpty) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final result = await productService.getProducts(
        page: currentPage + 1,
        search: query,
      );

      if (!mounted) return;

      setState(() {
        products.addAll(result.products);
        currentPage = result.page;
        hasMore = result.hasMore;
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingMore = false;
      });
      debugPrint("Search load more error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search products or stores",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : query.isEmpty
                    ? const Center(child: Text("Start typing to search"))
                    : products.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                      controller: scrollController,
                      itemCount: products.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= products.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = products[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailsScreen(
                                        product: product,
                                      ),
                                ),
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child:
                                  product.imageUrl != null
                                      ? Image.network(
                                        product.imageUrl!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 18,
                                              ),
                                            ),
                                      )
                                      : Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 18,
                                        ),
                                      ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(product.storeName),
                            trailing: Text(
                              "${product.priceSell}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
