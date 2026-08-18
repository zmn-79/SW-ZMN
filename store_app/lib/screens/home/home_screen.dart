import 'package:flutter/material.dart';
import '../products/add_product_screen.dart';
import '../products/view_products_screen.dart';
import '../orders/orders_screen.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/session.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<ProductModel>? initialProducts;

  HomeScreen({super.key, required this.categories, this.initialProducts});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<ProductModel> products = [];
  late List<CategoryModel> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.categories; // استلام البيانات عند بداية الصفحة
    products = widget.initialProducts ?? [];
  }

  void onProductAdded(ProductModel newProduct) {
    setState(() {
      products.add(newProduct);
    });
  }

  void logout(BuildContext context) {
    Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  void showSettingsDialog(BuildContext context, double x, double y) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // 👈 عشان الخلفية تكون شفافة
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: x, // 👈 موقع الـ X
              top: y, // 👈 موقع الـ Y
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Profile"),
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
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text("Privacy"),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to Privacy
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.color_lens),
                        title: Text("Appearance "),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to About
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text("Notifications"),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to About
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text("About App"),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to About
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context); // إغلاق القائمة أولًا
                          logout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF127369),
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF007566),

        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            showSettingsDialog(context, 10, 50); // 👈 استدعاء الدالة
          },
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50, left: 100),
                    child: Image.asset(
                      'images/moder.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                // "Edit Medicine" (1) → بحث وتعديل مباشر لكل المنتجات
                Positioned(
                  left: 220,
                  top: 340,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ViewProductsScreen(
                                products: products,
                                categories: categories,
                                showAllDirectly: true,
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, color: Color(0xFF127369)),
                    label: Text(
                      "Edit  Product",
                      style: TextStyle(color: Color(0xFF127369)), // لون النص
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                        255,
                        15,
                        6,
                        9,
                      ), // لون الزر
                      minimumSize: Size(100, 100), // حجم الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // انحناء الحواف
                      ),
                    ),
                  ),
                ),

                // "Add Medicine" → إضافة منتج جديد
                Positioned(
                  left: 47,
                  top: 340,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddProductScreen(
                                onProductAdded: onProductAdded,
                                categories: categories,
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, color: Color(0xFF127369)),
                    label: Text(
                      "Add  Product",
                      style: TextStyle(color: Color(0xFF127369)), // لون النص
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                        255,
                        15,
                        6,
                        9,
                      ), // لون الزر
                      minimumSize: Size(100, 100), // حجم الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // انحناء الحواف
                      ),
                    ),
                  ),
                ),

                // "View Product" → عرض المنتجات بالفئات
                Positioned(
                  left: 47,
                  top: 460,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ViewProductsScreen(
                                products: products,
                                categories: categories,
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, color: Color(0xFF127369)),
                    label: Text(
                      "View Product",
                      style: TextStyle(color: Color(0xFF127369)), // لون النص
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                        255,
                        15,
                        6,
                        9,
                      ), // لون الزر
                      minimumSize: Size(100, 100), // حجم الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // انحناء الحواف
                      ),
                    ),
                  ),
                ),

                // "Edit Product" (2) → نفس البحث والتعديل المباشر
                Positioned(
                  left: 220,
                  top: 460,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ViewProductsScreen(
                                products: products,
                                categories: categories,
                                showAllDirectly: true,
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, color: Color(0xFF127369)),
                    label: Text(
                      "Edit  Product",
                      style: TextStyle(color: Color(0xFF127369)), // لون النص
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                        255,
                        15,
                        6,
                        9,
                      ), // لون الزر
                      minimumSize: Size(100, 100), // حجم الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // انحناء الحواف
                      ),
                    ),
                  ),
                ),

                // "Orders" → شاشة الطلبات الحقيقية (كانت BottomSheet محلي وهمي)
                Positioned(
                  left: 50,
                  top: 580,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.list, color: Color(0xFF127369)),
                    label: Text(
                      "Orders",
                      style: TextStyle(color: Color(0xFF127369)), // لون النص
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 5, 8, 14),
                      minimumSize: Size(325, 50),
                    ),
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
