import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  final Function(ProductModel) onSave;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceCapitalController = TextEditingController();
  TextEditingController pricesellController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  bool isSaving = false;
  bool isUploadingImage = false;
  File? newImageFile;
  String? currentImageUrl;

  @override
  void initState() {
    super.initState();
    currentImageUrl = widget.product.imageUrl;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        newImageFile = File(picked.path);
      });

      setState(() {
        isUploadingImage = true;
      });

      final updated = await ProductService.uploadImage(
        productId: widget.product.id,
        imageFile: newImageFile!,
      );

      if (!mounted) return;

      setState(() {
        isUploadingImage = false;
        if (updated != null) {
          currentImageUrl = updated.imageUrl;
          widget.onSave(updated);
        }
      });

      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل رفع الصورة، حاول مرة أخرى')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: isUploadingImage ? null : pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        newImageFile != null
                            ? Image.file(
                              newImageFile!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            )
                            : currentImageUrl != null
                            ? Image.network(
                              currentImageUrl!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    width: 140,
                                    height: 140,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            )
                            : Container(
                              width: 140,
                              height: 140,
                              color: Colors.grey[300],
                              child: const Icon(Icons.add_a_photo, size: 32),
                            ),
                  ),
                  if (isUploadingImage) const CircularProgressIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUploadingImage ? 'Uploading...' : 'Tap image to change',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: widget.product.name),
              autofocus: true,
            ),
            TextField(
              controller: pricesellController,
              decoration: InputDecoration(
                hintText: 'Price Sell: ${widget.product.priceSell}',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                hintText: 'Quantity: ${widget.product.quantity}',
              ),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: priceCapitalController,
              decoration: InputDecoration(
                hintText: 'Price Capital: ${widget.product.priceCapital}',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  isSaving
                      ? null
                      : () async {
                        final updatedProduct = widget.product.copyWith(
                          name:
                              nameController.text.isNotEmpty
                                  ? nameController.text
                                  : widget.product.name,
                          priceSell:
                              double.tryParse(pricesellController.text) ??
                              widget.product.priceSell,
                          priceCapital:
                              double.tryParse(priceCapitalController.text) ??
                              widget.product.priceCapital,
                          quantity:
                              int.tryParse(quantityController.text) ??
                              widget.product.quantity,
                        );

                        setState(() {
                          isSaving = true;
                        });

                        final savedProduct = await ProductService.update(
                          updatedProduct,
                        );

                        if (!mounted) return;

                        if (savedProduct != null) {
                          widget.onSave(savedProduct);
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            isSaving = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فشل حفظ التعديل، حاول مرة أخرى'),
                            ),
                          );
                        }
                      },
              child:
                  isSaving
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
