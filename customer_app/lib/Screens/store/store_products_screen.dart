import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../Screens/product/product_details_screen.dart';

class StoreProductsScreen extends StatefulWidget {
  final String storeId;
  final String storeName;

  const StoreProductsScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen> {
  final ProductService productService = ProductService();

  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await productService.getProductsByStore(widget.storeId);

      if (!mounted) return;

      setState(() {
        products = data;
        filteredProducts = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint("Error loading store products: $e");
    }
  }

  void searchProducts(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
        return;
      }

      filteredProducts =
          products
              .where((product) => product.name.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.storeName)),
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
                        hintText: "Search in this store",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: searchProducts,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadProducts,
                      child:
                          filteredProducts.isEmpty
                              ? ListView(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(top: 100),
                                    child: Center(
                                      child: Text('No products found'),
                                    ),
                                  ),
                                ],
                              )
                              : ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];

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
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) => Container(
                                                        width: 48,
                                                        height: 48,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons
                                                              .image_not_supported,
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
                                      subtitle: Text(
                                        'Quantity: ${product.quantity}',
                                      ),
                                      trailing: Text(
                                        '${product.priceSell}',
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
                  ),
                ],
              ),
    );
  }
}
