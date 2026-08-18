import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../../models/category_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/session.dart';

class InformationPage extends StatefulWidget {
  final String email;
  final String password;

  const InformationPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  InformationPageState createState() => InformationPageState();
}

class InformationPageState extends State<InformationPage> {
  int currentSection = 0;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final storeNameController = TextEditingController();
  final storeTypeController = TextEditingController();
  final storeAddressController = TextEditingController();
  final paymentMethodsController = TextEditingController();
  final descriptionController = TextEditingController();
  final taxNumberController = TextEditingController();
  final commercialNumberController = TextEditingController();
  final categoryController = TextEditingController();
  String? userId;
  String? storeId;
  List<CategoryModel> categories = [];
  bool deliveryAvailable = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    passwordController.text = widget.password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF127369),
      appBar: AppBar(title: Text(''), backgroundColor: Color(0xFF007566)),
      body: Column(
        children: [
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: buildNavButton("Personal ", 0)),
                Expanded(child: buildNavButton("Store ", 1)),
                Expanded(child: buildNavButton(" Media", 2)),
              ],
            ),
          ),
          Divider(),
          Expanded(child: buildSection(currentSection)),
        ],
      ),
    );
  }

  Widget buildNavButton(String title, int sectionIndex) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            currentSection == sectionIndex
                ? const Color.fromARGB(255, 1, 3, 5)
                : Color.fromARGB(255, 0, 8, 8),
      ),
      onPressed: () {
        setState(() {
          currentSection = sectionIndex;
        });
      },
      child: Text(title),
    );
  }

  Widget buildSection(int section) {
    switch (section) {
      case 0:
        return personalInfoSection();
      case 1:
        return storeInfoSection();
      case 2:
        return permissionsSection();
      default:
        return Container();
    }
  }

  Widget personalInfoSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(fullNameController, "Full Name"),
          buildTextField(emailController, "Email"),
          buildTextField(phoneController, "Phone Number"),
          buildTextField(passwordController, "Password", obscure: true),
        ],
      ),
    );
  }

  List<String> storeTypes = [
    'Clothing',
    'Tools',
    'Medicine',
    'Electronics',
    'Food',
  ];

  String? selectedType;

  Widget storeInfoSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(storeNameController, "Store Name"),

          // بدل حقل Store Type اليدوي بحقل فيه Dropdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Store Type",
                    labelStyle: TextStyle(color: Color(0xFF127369)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF8AA6A3), // لون الخلفية
                  ),
                  value: selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue;
                    });
                  },
                  items:
                      storeTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          SizedBox(height: 16),

          buildTextField(storeAddressController, "Store Address"),
          buildTextField(paymentMethodsController, "Payment Methods"),
          buildTextField(descriptionController, "Store Description"),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget permissionsSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(taxNumberController, "Tax Number"),
          buildTextField(
            commercialNumberController,
            "Commercial Registration Number",
          ),
          SwitchListTile(
            title: Text("Delivery Available?"),
            value: deliveryAvailable,
            onChanged: (value) {
              setState(() {
                deliveryAvailable = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (selectedType == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select store type")),
                );
                return;
              }

              await submitInstitution();
            },
            child: Text("Submit All Info"),
          ),
          TextField(
            controller: categoryController,
            decoration: InputDecoration(labelText: "Product Categories"),
            onSubmitted: (value) {
              String category = value.trim();

              if (category.isNotEmpty) {
                setState(() {
                  categories.add(
                    CategoryModel(id: '', category: category, storeId: storeId),
                  );

                  categoryController.clear();
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: submitCategories,
            child: Text("Save Categories"),
          ),
        ],
      ),
    );
  }

  Future<void> submitInstitution() async {
    final body = {
      "fullName": fullNameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "password": passwordController.text,
      "role": "store_owner",
      "storeName": storeNameController.text,
      "storeType": selectedType,
      "storeAddress": storeAddressController.text,

      "paymentMethods": paymentMethodsController.text,
      "description": descriptionController.text,

      "taxNumber": taxNumberController.text,
      "commercialNumber": commercialNumberController.text,

      "categories": categories,
    };

    final result = await AuthService.register(body);

    if (result.isSuccess) {
      // حفظ User ID و Store ID
      setState(() {
        userId = result.data!.userId;
        storeId = result.data!.storeId;
      });

      Session.set(
        userId: result.data!.userId,
        role: result.data!.role,
        storeId: result.data!.storeId,
        token: result.data!.token,
      );

      debugPrint("User ID = $userId");
      debugPrint("Store ID = $storeId");
      debugPrint("✅ Institution saved successfully");
    } else {
      debugPrint("❌ Failed: ${result.errorMessage}");
    }
  }

  Future<void> submitCategories() async {
    bool allSuccess = true;

    final List<CategoryModel> savedCategories = [];

    for (var item in categories) {
      final savedCategory = await CategoryService.create(
        storeId: storeId ?? '',
        category: item.category,
      );

      if (savedCategory != null) {
        savedCategories.add(savedCategory);
        debugPrint("🎉 Category sent successfully");
      } else {
        allSuccess = false;
        debugPrint("❌ Failed category: ${item.category}");
      }
    }

    categories = savedCategories;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(categories: categories),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF127369)),
          filled: true, // Enable background color
          fillColor: Color(0xFF8AA6A3), // Choose your desired background color
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8AA6A3)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        enableSuggestions: false,
        autofocus: true,
        style: TextStyle(
          color: Color(0xFF127369),
        ), // 👈 here we use the custom color
        cursorColor: Color(0xFF127369),
      ),
    );
  }
}
