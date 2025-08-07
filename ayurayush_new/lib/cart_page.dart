import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'providers/cart_provider.dart';
import 'product.dart';
import 'app_config.dart';
import 'user_session.dart';
import 'home_page.dart'; // for loggedInUsername
import 'login.dart';
import 'signup.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Razorpay _razorpay;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
    _loadProductsAndFetchCart();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
    super.dispose();
  }

  Future<void> _loadProductsAndFetchCart() async {
    try {
      final response = await http.get(Uri.parse(AppConfig.apiBaseUrl + '/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.fetchCart(_products);
        if (mounted) setState(() {});
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
      );
      Provider.of<CartProvider>(context, listen: false).clearCart();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet: ${response.walletName}')),
      );
    }
  }

  void _openCheckout(double amount) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payments are currently supported only on mobile devices.')),
      );
      return;
    }

    var options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': (amount * 100).toInt(),
      'name': 'Ayurayush',
      'description': 'Payment for Ayurvedic Products',
      'prefill': {
        'contact': '1234567890',
        'email': 'customer@ayurayush.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _openAuthOverlay(bool login) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        login ? "Sign In" : "Register",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2C2A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  login ? LoginPageContent() : SignupPageContent(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        login ? "Don't have an account? " : "Already have an account? ",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openAuthOverlay(!login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF4A2C2A),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          login ? "Register" : "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result == 'show_signin') {
      _openAuthOverlay(true);
    } else if (result != null && result.isNotEmpty) {
      loggedInUsername.value = result;
      await _loadProductsAndFetchCart();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              children: [
                _buildNavbar(),
                _buildNotificationBar(),
                _buildHorizontalMenu(),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(minHeight: 200, minWidth: 200),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Ensure we have valid constraints
                        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
                          return Container(
                            width: double.infinity,
                            height: 400,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        if (constraints.maxWidth > 800) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildCartContent(cartProvider)),
                              Expanded(flex: 1, child: _buildOrderSummary(cartProvider)),
                            ],
                          );
                        } else {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCartContent(cartProvider),
                                _buildOrderSummary(cartProvider),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: Colors.black87, size: 28),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black87, size: 26),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 26, minHeight: 26),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Image.asset('assets/images/logo.png', height: 48),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildUserDropdown(),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: IconButton(
                              icon: Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 28),
                              onPressed: () => Navigator.pushNamed(context, '/cart'),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ),
                          if (cartProvider.cartItems.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    cartProvider.cartItems.length.toString(),
                                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBar() {
    return Container(
      width: double.infinity,
      color: Color(0xFF5A5A5A),
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          'Flat Rs 200 cashback on first Mobikwik UPI transaction*',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: Color.fromARGB(255, 196, 196, 196),
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalMenu() {
    return Container(
      color: Colors.white,
      height: 54,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuItem('Home'),
            _buildMenuItem('About Us'),
            _buildMenuItem('Services'),
            _buildMenuItem('Courses'),
            _buildMenuItem('Doctors'),
            _buildMenuItem('Products'),
            _buildMenuItem('Contact Us'),
            _buildMenuItem('FAQs'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return InkWell(
      onTap: () {
        switch (title) {
          case 'Home':
            Navigator.pushNamed(context, '/home');
            break;
          case 'About Us':
            Navigator.pushNamed(context, '/about');
            break;
          case 'Products':
            Navigator.pushNamed(context, '/products');
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          title,
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildUserDropdown() {
    return ValueListenableBuilder<String?>(
      valueListenable: loggedInUsername,
      builder: (context, username, _) {
        if (username != null && username.isNotEmpty) {
          return PopupMenuButton<int>(
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFF4A2C2A),
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: 8),
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 18),
                ],
              ),
            ),
            offset: Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            color: Colors.white,
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.pushNamed(context, '/cart');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/my-account');
                  break;
                case 4:
                  loggedInUsername.value = null;
                  UserSession.clearUserSession();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Wishlist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('Track Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                height: 1,
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
              PopupMenuItem(
                value: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red.shade600, size: 20),
                      SizedBox(width: 12),
                      Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red.shade600)),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return PopupMenuButton<int>(
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF4A2C2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                ],
              ),
            ),
            offset: Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            color: Colors.white,
            onSelected: (value) {
              switch (value) {
                case 0:
                  _openAuthOverlay(true);
                  break;
                case 1:
                  _openAuthOverlay(false);
                  break;
                case 2:
                  Navigator.pushNamed(context, '/cart');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/my-account');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.login, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person_add, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('Register', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                height: 1,
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
              PopupMenuItem(
                value: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Wishlist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('Track Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCartContent(CartProvider cartProvider) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 200,
        minWidth: 200,
        maxWidth: 800,
      ),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                child: Text('Your Cart', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 16),
              if (cartProvider.cartItems.isEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  child: Center(
                    child: Text('Your cart is empty.', style: TextStyle(fontSize: 18)),
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: cartProvider.cartItems.map((item) => _buildCartItem(item, cartProvider)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 80,
        maxHeight: 150,
        minWidth: 200,
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          leading: Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image.startsWith('http')
                  ? Image.network(
                      item.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                  : Image.asset(item.image, width: 60, height: 60, fit: BoxFit.cover),
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                'Quantity: ${item.quantity}',
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue[700]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.price.toStringAsFixed(2)} each',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.remove_circle, color: Colors.red, size: 24),
                  onPressed: () async {
                    try {
                      await cartProvider.removeFromCart(item, productsList: _products);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.name} removed from cart!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to remove item from cart')),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 200,
        minWidth: 200,
        maxWidth: 400,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  child: Text('Order Summary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal'),
                    Text('₹${cartProvider.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery'),
                    Text('FREE'),
                  ],
                ),
                Container(
                  width: double.infinity,
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('₹${cartProvider.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cartProvider.totalPrice > 0 ? () => _openCheckout(cartProvider.totalPrice) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A2C2A),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Proceed to Buy', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Color(0xFF4A2C2A),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ValueListenableBuilder<String?>(
                            valueListenable: loggedInUsername,
                            builder: (context, username, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username?.isNotEmpty == true ? username! : 'Guest',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    username?.isNotEmpty == true ? 'Welcome back!' : 'Sign in to continue',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white54),
              ValueListenableBuilder<String?>(
                valueListenable: loggedInUsername,
                builder: (context, username, _) {
                  if (username?.isNotEmpty == true) {
                    return Column(
                      children: [
                        _buildDrawerItem(Icons.account_circle, 'My Account', () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/my-account');
                        }),
                        _buildDrawerItem(Icons.shopping_cart, 'My Cart', () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/cart');
                        }),
                        _buildDrawerItem(Icons.logout, 'Sign Out', () {
                          Navigator.pop(context);
                          loggedInUsername.value = null;
                          UserSession.clearUserSession();
                        }),
                        Divider(color: Colors.white54),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildDrawerItem(Icons.login, 'Sign In', () {
                          Navigator.pop(context);
                          _openAuthOverlay(true);
                        }),
                        _buildDrawerItem(Icons.person_add, 'Register', () {
                          Navigator.pop(context);
                          _openAuthOverlay(false);
                        }),
                        Divider(color: Colors.white54),
                      ],
                    );
                  }
                },
              ),
              _buildDrawerItem(Icons.home, 'Home', () => Navigator.pushNamed(context, '/home')),
              _buildDrawerItem(Icons.info, 'About Us', () => Navigator.pushNamed(context, '/about')),
              _buildDrawerItem(Icons.shopping_cart, 'Products', () => Navigator.pushNamed(context, '/products')),
              _buildDrawerItem(Icons.contact_mail, 'Contact Us', () => Navigator.pushNamed(context, '/contact')),
              _buildDrawerItem(Icons.help, 'FAQs', () => Navigator.pushNamed(context, '/faqs')),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text, VoidCallback onTap) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 16),
              Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
