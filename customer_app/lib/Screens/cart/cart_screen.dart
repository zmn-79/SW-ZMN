import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../orders/orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartModel? cart;
  bool isLoading = true;
  bool isCheckingOut = false;
  final Set<String> updatingItems = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() {
      isLoading = true;
    });

    final result = await CartService.getCart();

    if (!mounted) return;

    setState(() {
      cart = result;
      isLoading = false;
    });
  }

  Future<void> updateQuantity(CartItemModel item, int newQuantity) async {
    if (newQuantity < 1) return;

    setState(() {
      updatingItems.add(item.productId);
    });

    final updatedCart = await CartService.updateItemQuantity(
      productId: item.productId,
      quantity: newQuantity,
    );

    if (!mounted) return;

    setState(() {
      updatingItems.remove(item.productId);
      if (updatedCart != null) {
        cart = updatedCart;
      }
    });
  }

  Future<void> removeItem(CartItemModel item) async {
    setState(() {
      updatingItems.add(item.productId);
    });

    final updatedCart = await CartService.removeItem(item.productId);

    if (!mounted) return;

    setState(() {
      updatingItems.remove(item.productId);
      if (updatedCart != null) {
        cart = updatedCart;
      }
    });
  }

  Future<void> checkout() async {
    setState(() {
      isCheckingOut = true;
    });

    final result = await OrderService.checkout();

    if (!mounted) return;

    setState(() {
      isCheckingOut = false;
    });

    if (result.hasStockIssue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Some items are unavailable'),
        ),
      );
      loadCart();
      return;
    }

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Checkout failed')),
      );
      return;
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  Widget buildItemImage(String? imageUrl) {
    if (imageUrl == null) {
      return Container(
        width: 64,
        height: 64,
        color: Colors.grey[300],
        child: const Icon(Icons.inventory_2_outlined),
      );
    }

    return Image.network(
      imageUrl,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            width: 64,
            height: 64,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : (cart == null || cart!.items.isEmpty)
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart!.items.length,
                      itemBuilder: (context, index) {
                        final item = cart!.items[index];
                        final isUpdating = updatingItems.contains(
                          item.productId,
                        );
                        final hasStockIssue =
                            item.availableQuantity != null &&
                            item.quantity > item.availableQuantity!;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildItemImage(item.imageUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName ?? 'Unknown Product',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (item.storeName != null)
                                        Text(
                                          '🏪 ${item.storeName}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      if (hasStockIssue)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            'Only ${item.availableQuantity} available',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                ),
                                                onPressed:
                                                    isUpdating
                                                        ? null
                                                        : () => updateQuantity(
                                                          item,
                                                          item.quantity - 1,
                                                        ),
                                              ),
                                              Text('${item.quantity}'),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                onPressed:
                                                    isUpdating
                                                        ? null
                                                        : () => updateQuantity(
                                                          item,
                                                          item.quantity + 1,
                                                        ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '\$${item.subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    isUpdating
                                                        ? null
                                                        : () =>
                                                            removeItem(item),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 18)),
                            Text(
                              '\$${cart!.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isCheckingOut ? null : checkout,
                            child:
                                isCheckingOut
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
