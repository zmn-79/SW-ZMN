import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import '../../services/store_service.dart';
import '../store/store_products_screen.dart';

class StoreProfileScreen extends StatefulWidget {
  final String storeId;

  const StoreProfileScreen({super.key, required this.storeId});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final StoreService storeService = StoreService();

  StoreModel? store;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStore();
  }

  Future<void> loadStore() async {
    try {
      final storeData = await storeService.getStoreById(widget.storeId);

      if (!mounted) return;

      setState(() {
        store = storeData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store?.storeName ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(store?.storeType ?? ''),
                          const SizedBox(height: 10),
                          Text(store?.storeAddress ?? ''),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.storefront),
                      label: const Text('View All Products'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StoreProductsScreen(
                                  storeId: widget.storeId,
                                  storeName: store?.storeName ?? 'Store',
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
