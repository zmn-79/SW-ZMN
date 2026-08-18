import 'dart:async';
import 'package:flutter/material.dart';
import '../product/product_details_screen.dart';
import '../search/search_screen.dart';
import '../../services/product_service.dart';
import '../../services/session.dart';
import '../../models/product_model.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  List<ProductModel> products = [];

  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = true;
  bool isLoadingMore = false;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    loadProducts(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        products = [];
        hasMore = true;
      });
    }

    try {
      final result = await productService.getProducts(
        page: 1,
        search: searchQuery,
      );

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
      debugPrint("Error loading products: $e");
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final result = await productService.getProducts(
        page: currentPage + 1,
        search: searchQuery,
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
      debugPrint("Error loading more products: $e");
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery = value.trim().isEmpty ? null : value.trim();
      loadProducts(reset: true);
    });
  }

  void logout() {
    Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Privacy"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Privacy
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text("Appearance"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Appearance
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notifications"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Notifications
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("About App"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to About
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => showSettingsDialog(context),
          ),
        ],
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                        products.isEmpty
                            ? const Center(child: Text('No products found'))
                            : RefreshIndicator(
                              onRefresh: () => loadProducts(reset: true),
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: products.length + (hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= products.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final product = products[index];

                                  return Card(
                                    margin: const EdgeInsets.all(10),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ProductDetailsScreen(
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
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) => Container(
                                                        width: 56,
                                                        height: 56,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                        ),
                                                      ),
                                                )
                                                : Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.inventory_2_outlined,
                                                  ),
                                                ),
                                      ),
                                      title: Text(product.name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("🏪 ${product.storeName}"),
                                          Text("Quantity: ${product.quantity}"),
                                        ],
                                      ),
                                      trailing: Text(
                                        "${product.priceSell}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }
}
