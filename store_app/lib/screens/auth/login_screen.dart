import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/session.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthService.login(email: email, password: password);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Login failed')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    final String? storeId = result.data!.storeId;

    Session.set(
      userId: result.data!.userId,
      role: result.data!.role,
      storeId: storeId,
      token: result.data!.token,
    );

    debugPrint('🔍 STORE ID FROM LOGIN: $storeId');

    List<CategoryModel> categories = [];
    List<ProductModel> products = [];

    if (storeId != null) {
      categories = await CategoryService.getByStore(storeId);
      products = await ProductService.getByStore(storeId);
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                HomeScreen(categories: categories, initialProducts: products),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF127369),
      appBar: AppBar(title: Text(''), backgroundColor: Color(0xFF007566)),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 50, left: 100),
              child: Image.asset('images/moder.png', width: 200, height: 200),
            ),
          ),

          // حقل الإيميل في موقع محدد
          Positioned(
            left: 50, // المسافة من اليسار
            top: 380, // المسافة من الأعلى
            child: Container(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF007566)),
                  filled: true,
                  fillColor: Color(0xFF8AA6A3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          // حقل الباسورد
          Positioned(
            left: 50,
            top: 460,
            child: Container(
              width: 300,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF007566)),
                  filled: true,
                  fillColor: Color(0xFF8AA6A3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // زر الدخول
          Positioned(
            left: 120,
            top: 540,
            child: Container(
              width: 150,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 16, 20, 22),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF007566),
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF007566), // ← لون النص هنا
                          ),
                        ),
              ),
            ),
          ),
          // زر التسجيل
          Positioned(
            left: 90,
            top: 620,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text(
                "Don't have an account? Register",
                style: TextStyle(
                  color: Color(0xFF8AA6A3),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF8AA6A3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
