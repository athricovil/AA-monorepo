import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'styles.dart';
import 'app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionnaireKey = GlobalKey<FormState>();
  
  // Shipping details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  // Payment details
  String _selectedPaymentMethod = 'UPI';
  final _upiIdController = TextEditingController();
  
  // Questionnaire answers
  final Map<String, String> _questionnaireAnswers = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Predefined questions for Ayurvedic consultation
  final List<Map<String, String>> _questions = [
    {
      'id': 'age',
      'question': 'What is your age?',
      'type': 'text'
    },
    {
      'id': 'gender',
      'question': 'What is your gender?',
      'type': 'select',
      'options': 'Male,Female,Other'
    },
    {
      'id': 'dosha',
      'question': 'Do you know your body type (Dosha)?',
      'type': 'select',
      'options': 'Vata,Pitta,Kapha,Don\'t know'
    },
    {
      'id': 'health_issues',
      'question': 'What are your main health concerns?',
      'type': 'textarea'
    },
    {
      'id': 'medications',
      'question': 'Are you currently taking any medications?',
      'type': 'textarea'
    },
    {
      'id': 'allergies',
      'question': 'Do you have any allergies?',
      'type': 'textarea'
    },
    {
      'id': 'lifestyle',
      'question': 'Describe your lifestyle (diet, exercise, sleep)?',
      'type': 'textarea'
    },
    {
      'id': 'stress_level',
      'question': 'How would you rate your stress level?',
      'type': 'select',
      'options': 'Low,Moderate,High,Very High'
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await UserSession.getUsername();
    if (username != null) {
      // Load user data from API
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.apiBaseUrl}/users/profile'),
          headers: {'Authorization': 'Bearer ${await UserSession.getToken()}'}
        );
        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryButtonColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                _buildOrderSummary(cartProvider),
                SizedBox(height: 24),
                
                // Shipping Details
                _buildShippingDetails(),
                SizedBox(height: 24),
                
                // Payment Method
                _buildPaymentMethod(),
                SizedBox(height: 24),
                
                // Questionnaire
                _buildQuestionnaire(),
                SizedBox(height: 24),
                
                // Place Order Button
                _buildPlaceOrderButton(cartProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    double total = cartProvider.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...cartProvider.cartItems.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${item.name} x${item.quantity}'),
                  ),
                  Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                ],
              ),
            )),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('₹${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'City is required' : null,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'State is required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _pincodeController,
                    decoration: InputDecoration(
                      labelText: 'Pincode',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Pincode is required' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Select Payment Method',
                border: OutlineInputBorder(),
              ),
              items: ['UPI', 'Net Banking', 'Credit Card', 'Debit Card', 'PayTM', 'Cash on Delivery']
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            if (_selectedPaymentMethod == 'UPI') ...[
              SizedBox(height: 16),
              TextFormField(
                controller: _upiIdController,
                decoration: InputDecoration(
                  labelText: 'UPI ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _selectedPaymentMethod == 'UPI' && value?.isEmpty == true 
                    ? 'UPI ID is required' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnaire() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Questionnaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Please answer these questions to help us provide better consultation.', 
                 style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Form(
              key: _questionnaireKey,
              child: Column(
                children: _questions.map((question) => _buildQuestionField(question)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionField(Map<String, String> question) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question['question']!, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          if (question['type'] == 'text')
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your answer',
              ),
              onChanged: (value) {
                _questionnaireAnswers[question['id']!] = value;
              },
              validator: (value) => value?.isEmpty == true ? 'This field is required' : null,
            )
          else if (question['type'] == 'select')
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: Text('Select an option'),
              items: question['options']!.split(',').map((option) => 
                DropdownMenuItem(value: option.trim(), child: Text(option.trim()))
              ).toList(),
              onChanged: (value) {
                _questionnaireAnswers[question['id']!] = value!;
              },
              validator: (value) => value == null ? 'Please select an option' : null,
            )
          else if (question['type'] == 'textarea')
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your answer',
              ),
              maxLines: 3,
              onChanged: (value) {
                _questionnaireAnswers[question['id']!] = value;
              },
              validator: (value) => value?.isEmpty == true ? 'This field is required' : null,
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _placeOrder(cartProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryButtonColor,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading 
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Place Order', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate() || !_questionnaireKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Create order request
      final orderRequest = {
        'userId': userId,
        'shippingAddress': '${_addressController.text}, ${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}',
        'billingAddress': '${_addressController.text}, ${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}',
        'paymentMethod': _selectedPaymentMethod,
        'items': cartProvider.cartItems.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
          'unitPrice': item.price,
        }).toList(),
      };

      // Submit order
      final orderResponse = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/orders/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await UserSession.getToken()}'
        },
        body: json.encode(orderRequest),
      );

      if (orderResponse.statusCode != 200) {
        throw Exception('Failed to create order: ${orderResponse.body}');
      }

      final orderData = json.decode(orderResponse.body);
      final orderId = orderData['id'];

      // Submit questionnaire
      final questionnaireRequest = {
        'userId': userId,
        'orderId': orderId,
        'questions': _questions.map((q) => q['question']).toList(),
        'answers': _questionnaireAnswers,
      };

      final questionnaireResponse = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/questionnaires/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await UserSession.getToken()}'
        },
        body: json.encode(questionnaireRequest),
      );

      if (questionnaireResponse.statusCode != 200) {
        print('Warning: Failed to submit questionnaire: ${questionnaireResponse.body}');
      }

      // Clear cart
      cartProvider.clearCart();

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Order Placed Successfully!'),
            content: Text('Your order has been placed. Order number: ${orderData['orderNumber']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }
}
