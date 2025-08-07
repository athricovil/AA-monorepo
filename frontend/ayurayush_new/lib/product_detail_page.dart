import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chatbot_widget.dart';
import 'providers/cart_provider.dart';
import 'user_session.dart';
import 'home_page.dart'; // for loggedInUsername
import 'styles.dart';
import 'login.dart';
import 'signup.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              // Navbar (same style as home page)
              _buildNavbar(cartProvider),
              // Notification bar
              _buildNotificationBar(),
              // Horizontal menu
              _buildHorizontalMenu(),
              // Expanded body
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
                                    Center(
                                      child: widget.product['image'] != null && widget.product['image'].isNotEmpty
                                          ? Image.network(
                                              widget.product['image'],
                                              width: 300,
                                              height: 300,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 300,
                                                  height: 300,
                                                  color: Colors.grey[200],
                                                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  width: 300,
                                                  height: 300,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 300,
                                              height: 300,
                                              color: Colors.grey[200],
                                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                                            ),
                                    ),
                                    SizedBox(height: 20),
                                    // Product Name
                                    Text(
                                      widget.product['name'],
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    // Product Price
                                    Text(
                                      '₹${widget.product['price'].toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    SizedBox(height: 10),
                                    // Product Description
                                    Text(
                                      widget.product['desc'],
                                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 20),
                                    // Placeholder for Ratings
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.orange, size: 20),
                                        Icon(Icons.star, color: Colors.orange, size: 20),
                                        Icon(Icons.star, color: Colors.orange, size: 20),
                                        Icon(Icons.star_half, color: Colors.orange, size: 20),
                                        Icon(Icons.star_border, color: Colors.orange, size: 20),
                                        SizedBox(width: 4),
                                        Text(
                                          '(4.2)',
                                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    // Quantity Selector
                                    Row(
                                      children: [
                                        Text(
                                          'Quantity:',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 20),
                                        Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (_selectedQuantity > 1) {
                                                    setState(() {
                                                      _selectedQuantity--;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(Icons.remove, size: 20),
                                                ),
                                              ),
                                              Container(
                                                width: 60,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(color: Colors.grey),
                                                    right: BorderSide(color: Colors.grey),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _selectedQuantity.toString(),
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_selectedQuantity < 10) {
                                                    setState(() {
                                                      _selectedQuantity++;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(Icons.add, size: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    // Add to Cart Button
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await cartProvider.addToCart(
                                              CartItem(
                                                productId: widget.product['id'],
                                                name: widget.product['name'],
                                                image: widget.product['image'],
                                                desc: widget.product['desc'],
                                                price: widget.product['price']?.toDouble() ?? 0.0,
                                                quantity: _selectedQuantity,
                                              ),
                                              productId: widget.product['id'],
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${widget.product['name']} (${_selectedQuantity}) added to cart!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to add to cart: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kAddToCartButtonColor,
                                          minimumSize: Size(200, 45),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.shopping_bag, color: Colors.white, size: 18),
                                            SizedBox(width: 6),
                                            Text(
                                              'Add to Cart',
                                              style: kButtonTextStyle.copyWith(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            ChatbotWidget(),
                          ],
                        ),
                      ),
                      // Footer at bottom
                      Container(
                        padding: EdgeInsets.all(16),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.question_answer, color: kSupportIconColor, size: 30),
                                SizedBox(width: 10),
                                Icon(Icons.person, color: kSupportIconColor, size: 30),
                                SizedBox(width: 10),
                                Icon(Icons.video_call, color: kSupportIconColor, size: 30),
                                SizedBox(width: 10),
                                Icon(Icons.book, color: kSupportIconColor, size: 30),
                                SizedBox(width: 10),
                                Icon(Icons.library_books, color: kSupportIconColor, size: 30),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Online support 24/7    Experienced doctors    Face to face interaction    Initial consultation    Free online library',
                              textAlign: TextAlign.center,
                              style: kSupportTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavbar(CartProvider cartProvider) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.search, color: Colors.black87, size: 26),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          Image.asset('assets/images/logo.png', height: 48),
          Row(
            children: [
              _buildUserDropdown(),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 28),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  if (cartProvider.cartItems.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          cartProvider.cartItems.length.toString(),
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
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
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.pushNamed(context, '/cart');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/my-account');
                  break;
                case 2:
                  // TODO: Navigate to wishlist
                  break;
                case 3:
                  // TODO: Navigate to track order
                  break;
                case 4:
                  loggedInUsername.value = null;
                  UserSession.clearUserSession();
                  break;
              }
            },
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
      // Registration success, open sign in modal
      _openAuthOverlay(true);
    } else if (result != null && result.isNotEmpty) {
      loggedInUsername.value = result;
      // Cart will be updated when user navigates to other pages
    }
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
}
