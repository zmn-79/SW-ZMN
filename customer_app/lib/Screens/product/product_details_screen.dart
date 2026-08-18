import 'package:flutter/material.dart';
import '../profile/store_profile_screen.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isAddingToCart = false;

  Future<void> addToCart() async {
    setState(() {
      isAddingToCart = true;
    });

    final result = await CartService.addItem(
      productId: widget.product.id,
      quantity: 1,
    );

    if (!mounted) return;

    setState(() {
      isAddingToCart = false;
    });

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Failed to add to cart')),
      );
      return;
    }

    if (result.stockWarning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added to cart, but only ${result.availableQuantity} in stock',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  product.imageUrl != null
                      ? Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: double.infinity,
                              height: 220,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                              ),
                            ),
                      )
                      : Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.inventory_2_outlined, size: 48),
                      ),
            ),

            const SizedBox(height: 20),

            Text(
              product.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "Price: ${product.priceSell}",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(
              "Quantity: ${product.quantity}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text("Size: ${product.size}", style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    product.quantity <= 0 || isAddingToCart ? null : addToCart,
                icon:
                    isAddingToCart
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.add_shopping_cart),
                label: Text(
                  product.quantity <= 0 ? 'Out of Stock' : 'Add to Cart',
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              "Store",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.store),
                title: Text(product.storeName),
                subtitle: const Text("Open Store Profile"),
                onTap:
                    product.storeId.isEmpty
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StoreProfileScreen(
                                    storeId: product.storeId,
                                  ),
                            ),
                          );
                        },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
