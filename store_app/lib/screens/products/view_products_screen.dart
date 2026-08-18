import 'package:flutter/material.dart';
import 'edit_product_screen.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class ViewProductsScreen extends StatefulWidget {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final bool showAllDirectly;

  const ViewProductsScreen({
    super.key,
    required this.products,
    required this.categories,
    this.showAllDirectly = false,
  });

  @override
  State<ViewProductsScreen> createState() => _ViewProductsScreenState();
}

class _ViewProductsScreenState extends State<ViewProductsScreen> {
  List<ProductModel> filteredProducts = [];
  List<CategoryModel> categories = [];
  List<ProductModel> productsInCategory = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();
  final TextEditingController maxQuantityController = TextEditingController();
  bool showPriceFields = false;
  bool showQuantityFields = false;
  String? selectedCategory;

  static const String _allProductsKey = '__ALL__';

  Widget buildProductImage(ProductModel product, {double size = 48}) {
    if (product.imageUrl == null) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey[300],
        child: const Icon(Icons.inventory_2_outlined, size: 20),
      );
    }

    return Image.network(
      product.imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 20),
          ),
    );
  }

  void showProductOptions(ProductModel product) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(product.name),
            content: Text("Choose an action:"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditProductScreen(
                            product: product,
                            onSave: (updatedProduct) {
                              setState(() {
                                int index = filteredProducts.indexOf(product);
                                filteredProducts[index] = updatedProduct;
                              });
                            },
                          ),
                    ),
                  );
                },
                child: Text("Edit"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the options dialog
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text("Product Details"),
                          content: SingleChildScrollView(
                            child: Card(
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: buildProductImage(
                                        product,
                                        size: 160,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        product.name.isNotEmpty
                                            ? product.name
                                            : 'Unknown',
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(
                                            "Price Capital: \$${product.priceCapital}",
                                          ),
                                          Text(
                                            "Price Sell: \$${product.priceSell}",
                                          ),
                                          Text("Quantity: ${product.quantity}"),
                                          Text("Barcode: ${product.parcode}"),
                                          Text(
                                            "Manufactured: ${product.yearManufacture}",
                                          ),
                                          Text("Expiry: ${product.expiryDate}"),
                                          Text("Age: ${product.age}"),
                                          Text("Size: ${product.size}"),
                                          Text("category: ${product.category}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Close"),
                            ),
                          ],
                        ),
                  );
                },
                child: Text("View Details"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق نافذة الخيارات
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text(
                            "Are you sure you want to delete this product?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // إغلاق التأكيد

                                final success = await ProductService.delete(
                                  product.id,
                                );

                                if (!mounted) return;

                                if (success) {
                                  setState(() {
                                    filteredProducts.remove(product);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'فشل حذف المنتج، حاول مرة أخرى',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Filter Options"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showPriceFields = false;
                          showQuantityFields = false;
                        });
                        filterByExpiry();
                        Navigator.of(context).pop();
                      },
                      child: Text("Expired Products"),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        setStateDialog(() {
                          showQuantityFields = !showQuantityFields;
                          showPriceFields = false;
                        });
                      },
                      child: Text("Filter by Quantity"),
                    ),

                    if (showQuantityFields) ...[
                      SizedBox(height: 10),
                      TextField(
                        controller: minQuantityController,
                        decoration: InputDecoration(labelText: "Min Quantity"),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: maxQuantityController,
                        decoration: InputDecoration(labelText: "Max Quantity"),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          filterByQuantity();
                          Navigator.of(context).pop();
                        },
                        child: Text("Apply Quantity Filter"),
                      ),
                    ],

                    SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        setStateDialog(() {
                          showPriceFields = !showPriceFields;
                          showQuantityFields = false;
                        });
                      },
                      child: Text("Filter by Price"),
                    ),

                    if (showPriceFields) ...[
                      SizedBox(height: 10),
                      TextField(
                        controller: minPriceController,
                        decoration: InputDecoration(labelText: "Min Price"),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: maxPriceController,
                        decoration: InputDecoration(labelText: "Max Price"),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          filterByPrice();
                          Navigator.of(context).pop();
                        },
                        child: Text("Apply Price Filter"),
                      ),
                    ],

                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    categories = List<CategoryModel>.from(widget.categories);

    if (widget.showAllDirectly) {
      selectedCategory = _allProductsKey;
      productsInCategory = List.from(widget.products);
      filteredProducts = List.from(widget.products);
    } else {
      filteredProducts = List.from(widget.products);
    }
  }

  void filterProductsByCategory(String? category) {
    setState(() {
      if (category == selectedCategory) {
        selectedCategory = null;
        filteredProducts.clear();
        productsInCategory.clear();
      } else {
        selectedCategory = category;
        productsInCategory =
            widget.products
                .where((product) => product.categoryId == selectedCategory)
                .toList();
        filteredProducts = List.from(productsInCategory);
      }
    });
  }

  void filterByName() {
    String searchName = searchController.text.toLowerCase();
    setState(() {
      filteredProducts =
          productsInCategory.where((product) {
            return product.name.toLowerCase().contains(searchName);
          }).toList();
    });
  }

  void filterByExpiry() {
    DateTime currentDate = DateTime.now();
    setState(() {
      filteredProducts =
          productsInCategory.where((product) {
            if (product.expiryDate == null) return false;
            DateTime expiryDate = DateTime.parse(product.expiryDate!);
            return expiryDate.isBefore(currentDate);
          }).toList();
    });
  }

  void filterByQuantity() {
    double min = double.tryParse(minQuantityController.text) ?? 0;
    double max = double.tryParse(maxQuantityController.text) ?? 100;

    setState(() {
      filteredProducts =
          productsInCategory.where((product) {
            double quantity = product.quantity.toDouble();
            return quantity >= min && quantity <= max;
          }).toList();
    });
  }

  void filterByPrice() {
    double min = double.tryParse(minPriceController.text) ?? 0;
    double max = double.tryParse(maxPriceController.text) ?? 100;

    setState(() {
      filteredProducts =
          productsInCategory.where((product) {
            double price = product.priceSell;
            return price >= min && price <= max;
          }).toList();
    });
  }

  void showAll() {
    setState(() {
      filteredProducts = List.from(productsInCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF127369),
      appBar: AppBar(
        title: Text(selectedCategory == null ? 'Categories' : 'Products'),
        backgroundColor: Color(0xFF007566),
        leading:
            selectedCategory != null
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedCategory = null;
                      filteredProducts.clear();
                      searchController.clear();
                    });
                  },
                )
                : null,
      ),
      body:
          selectedCategory == null
              ? buildCategoriesView()
              : buildProductsView(),
    );
  }

  Widget buildCategoriesView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
        children:
            categories.map((category) {
              return ElevatedButton(
                onPressed: () {
                  filterProductsByCategory(category.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 17, 21, 24),
                  foregroundColor: Color(0xFF007566),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  category.category.isNotEmpty ? category.category : 'بدون اسم',
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildProductsView() {
    return Stack(
      children: [
        Positioned(
          top: 20,
          left: 10,
          child: SizedBox(
            width: 130,
            height: 47,
            child: ElevatedButton(
              onPressed: showFilterDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 15, 14),
                foregroundColor: Color(0xFF127369),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: Text("Filter", style: TextStyle(fontSize: 16)),
            ),
          ),
        ),

        Positioned(
          top: 20,
          left: 150,
          right: 10,
          child: Container(
            height: 47,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search by Name",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: filterByName,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 80,
          left: 10,
          right: 10,
          bottom: 10,
          child:
              filteredProducts.isEmpty
                  ? Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: buildProductImage(product),
                            ),
                            title: Text(
                              product.name.isNotEmpty
                                  ? product.name
                                  : 'Unnamed',
                            ),
                            onTap: () {
                              showProductOptions(product);
                            },
                          ),
                        );
                      },
                    ),
                  ),
        ),

        if (selectedCategory != null &&
            selectedCategory != _allProductsKey &&
            filteredProducts.length != productsInCategory.length)
          Positioned(
            top: 740,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 47,
              child: ElevatedButton(
                onPressed: showAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 4, 15, 14),
                  foregroundColor: Color(0xFF127369),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Cancel Filter", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
      ],
    );
  }
}
