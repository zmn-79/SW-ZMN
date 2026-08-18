import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/session.dart';

class AddProductScreen extends StatefulWidget {
  final Function(ProductModel) onProductAdded;
  final List<CategoryModel> categories;

  const AddProductScreen({
    super.key,
    required this.onProductAdded,
    required this.categories,
  });

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  List<CategoryModel> categories = [];
  String statusMessage = "";
  String? selectedCategory;
  String? categoryId;

  void initState() {
    super.initState();
    categories = List<CategoryModel>.from(widget.categories);
  }

  List<ProductModel> products = [];

  Future<void> onProductAdded(ProductModel product, File? imageFile) async {
    debugPrint("STORE ID => ${Session.storeId}");
    debugPrint("CATEGORY ID => $categoryId");

    var savedProduct = await ProductService.create(product);

    if (savedProduct == null) {
      debugPrint("❌ Failed to save product");
      return;
    }

    debugPrint("✅ Product saved successfully");

    if (imageFile != null) {
      final withImage = await ProductService.uploadImage(
        productId: savedProduct.id,
        imageFile: imageFile,
      );

      if (withImage != null) {
        savedProduct = withImage;
        debugPrint("✅ Image uploaded successfully");
      } else {
        debugPrint("❌ Product saved, but image upload failed");
      }
    }

    setState(() {
      products.add(savedProduct!);
    });

    widget.onProductAdded(savedProduct);
  }

  void showAddProductDialog(
    BuildContext context,
    Future<void> Function(ProductModel, File?) onProductAdded,
    String selectedCategory,
  ) {
    int _step = 0;
    DateTime expiryDate = DateTime.now();
    File? pickedImage;
    final ImagePicker picker = ImagePicker();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceCapitalController =
        TextEditingController();
    final TextEditingController pricesellController = TextEditingController();
    final TextEditingController parcodeController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController yearManufactureController =
        TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController sizeController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              Future<void> pickImage() async {
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );

                if (picked != null) {
                  setStateDialog(() {
                    pickedImage = File(picked.path);
                  });
                }
              }

              void nextStep() async {
                setStateDialog(() {
                  _step++;
                  if (_step == 9) {
                    int yearManufacture =
                        int.tryParse(yearManufactureController.text) ?? 0;
                    int lifespanYears = int.tryParse(ageController.text) ?? 0;
                    expiryDate = DateTime(yearManufacture + lifespanYears);
                  }
                });

                if (_step == 9) {
                  final newProduct = ProductModel(
                    id: '',
                    storeId: Session.storeId,
                    categoryId: categoryId,
                    name: nameController.text,
                    priceCapital:
                        double.tryParse(priceCapitalController.text) ?? 0.0,
                    priceSell: double.tryParse(pricesellController.text) ?? 0.0,
                    parcode: int.tryParse(parcodeController.text) ?? 0,
                    quantity: int.tryParse(quantityController.text) ?? 0,
                    yearManufacture:
                        int.tryParse(yearManufactureController.text) ?? 0,
                    age: int.tryParse(ageController.text) ?? 0,
                    size: sizeController.text,
                    expiryDate: expiryDate.toString(),
                    category: selectedCategory,
                  );
                  await onProductAdded(newProduct, pickedImage);
                  setStateDialog(() {});
                }
              }

              void resetForm() {
                setStateDialog(() {
                  _step = 0;
                  pickedImage = null;
                });
                nameController.clear();
                priceCapitalController.clear();
                quantityController.clear();
                parcodeController.clear();
                yearManufactureController.clear();
                ageController.clear();
                sizeController.clear();
                pricesellController.clear();
              }

              return AlertDialog(
                title: Text("Add New Product"),
                content: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_step == 0)
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Enter product name",
                          ),
                          enableSuggestions: false,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 1)
                        TextField(
                          controller: priceCapitalController,
                          decoration: InputDecoration(
                            hintText: "Enter Capital price",
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 2)
                        TextField(
                          controller: pricesellController,
                          decoration: InputDecoration(
                            hintText: "Enter sell price",
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 3)
                        TextField(
                          controller: parcodeController,
                          decoration: InputDecoration(
                            hintText: "Enter parcode",
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 4)
                        TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            hintText: "Enter quantity",
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 5)
                        TextField(
                          controller: yearManufactureController,
                          decoration: InputDecoration(
                            hintText: "Enter year Manufacture",
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 6)
                        TextField(
                          controller: ageController,
                          decoration: InputDecoration(hintText: "Enter age"),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 7)
                        TextField(
                          controller: sizeController,
                          decoration: InputDecoration(hintText: "Enter size"),
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          onSubmitted: (_) => nextStep(),
                        ),
                      if (_step == 8)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (pickedImage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    pickedImage!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: pickImage,
                              icon: Icon(Icons.image),
                              label: Text(
                                pickedImage == null
                                    ? "Choose Image (optional)"
                                    : "Change Image",
                              ),
                            ),
                          ],
                        ),
                      if (_step == 9)
                        Column(
                          children: [
                            Text(
                              statusMessage,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: resetForm,
                              child: Text("Add Another Product"),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                actions: [
                  if (_step < 9)
                    TextButton(onPressed: nextStep, child: Text("Next")),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close"),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF127369),
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Color(0xFF007566),
      ),
      body: Stack(
        children: [
          Positioned(
            left: 20,
            top: 100,
            right: 20,
            bottom: 20,
            child:
                categories.isEmpty
                    ? Container(
                      width: 10,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        "لا توجد فئات حالياً",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : Container(
                      padding: EdgeInsets.all(0),
                      color: Colors.transparent,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children:
                            categories.map((category) {
                              return Container(
                                width: 10,
                                height: 10,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      categoryId = category.id;
                                    });
                                    showAddProductDialog(
                                      context,
                                      onProductAdded,
                                      category.id,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      17,
                                      21,
                                      24,
                                    ),
                                    foregroundColor: Color(0xFF007566),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    category.category.isNotEmpty
                                        ? category.category
                                        : 'بدون اسم',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
