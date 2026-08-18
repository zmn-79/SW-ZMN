import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import '../../services/store_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StoreModel? store;
  bool isLoading = true;
  bool isSaving = false;

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final paymentMethodsController = TextEditingController();
  final descriptionController = TextEditingController();
  final taxNumberController = TextEditingController();
  final commercialNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStore();
  }

  @override
  void dispose() {
    storeNameController.dispose();
    storeAddressController.dispose();
    paymentMethodsController.dispose();
    descriptionController.dispose();
    taxNumberController.dispose();
    commercialNumberController.dispose();
    super.dispose();
  }

  Future<void> loadStore() async {
    setState(() {
      isLoading = true;
    });

    final data = await StoreService.getMyStore();

    if (!mounted) return;

    setState(() {
      store = data;
      isLoading = false;

      if (data != null) {
        storeNameController.text = data.storeName;
        storeAddressController.text = data.storeAddress;
        paymentMethodsController.text = data.paymentMethods;
        descriptionController.text = data.description;
        taxNumberController.text = data.taxNumber;
        commercialNumberController.text = data.commercialNumber;
      }
    });
  }

  Future<void> saveChanges() async {
    if (store == null) return;

    setState(() {
      isSaving = true;
    });

    final updated = store!.copyWith(
      storeName: storeNameController.text,
      storeAddress: storeAddressController.text,
      paymentMethods: paymentMethodsController.text,
      description: descriptionController.text,
      taxNumber: taxNumberController.text,
      commercialNumber: commercialNumberController.text,
    );

    final result = await StoreService.updateMyStore(updated);

    if (!mounted) return;

    setState(() {
      isSaving = false;
      if (result.isSuccess) {
        store = result.store;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Profile updated successfully'
              : (result.errorMessage ?? 'Failed to update profile'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : store == null
              ? const Center(child: Text('Could not load store profile'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      store!.storeType,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: storeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Store Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: storeAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Store Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: paymentMethodsController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Methods',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taxNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Tax Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commercialNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Commercial Registration Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSaving ? null : saveChanges,
                      child:
                          isSaving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
    );
  }
}
