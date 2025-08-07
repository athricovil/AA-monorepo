import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'chatbot_widget.dart';
import 'providers/cart_provider.dart';
import 'styles.dart';
import 'login.dart';
import 'signup.dart';
import 'app_config.dart';
import 'product.dart';
import 'product_detail_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

ValueNotifier<String?> loggedInUsername = ValueNotifier<String?>(null);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final double videoHeight = 300.0; // Define videoHeight with a suitable value

  bool _showDrawer = false;

  List<Product> _products = [];
  bool _productsLoading = true;
  String? _productsError;
  Map<int, int> _productQuantities = {}; // Track quantities for each product

  int getQuantityForProduct(int productId) {
    return _productQuantities[productId] ?? 1;
  }

  void setQuantityForProduct(int productId, int quantity) {
    if (_productQuantities[productId] != quantity && mounted) {
      setState(() {
        _productQuantities[productId] = quantity;
      });
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
      // Registration success, open sign in modal
      _openAuthOverlay(true);
    } else if (result != null && result.isNotEmpty) {
      loggedInUsername.value = result;
      // After login, reload userId from session and refresh UI
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart(_products);
      setState(() {}); // Force UI refresh so cart logic sees new userId
    }
  }

  void _openDrawer() {
    if (!_showDrawer && mounted) {
      setState(() {
        _showDrawer = true;
      });
    }
  }

  void _closeDrawer() {
    if (_showDrawer && mounted) {
      setState(() {
        _showDrawer = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/AAV_web.mp4');
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setVolume(0);
      _controller.setLooping(true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.play();
      });
      setState(() {});
    }).catchError((error) {
      print('Video initialization error: $error');
    });
    _fetchProducts();
    _restoreLogin();
  }

  Future<void> _restoreLogin() async {
    final username = await UserSession.getUsername();
    if (username != null && username.isNotEmpty) {
      loggedInUsername.value = username;
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _productsLoading = true;
      _productsError = null;
    });
    try {
      final response = await http.get(Uri.parse(AppConfig.apiBaseUrl + '/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _productsLoading = false;
        });
      } else {
        setState(() {
          _productsError = 'Failed to load products';
          _productsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _productsError = 'Error: $e';
        _productsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  // Navbar
                  _buildNavbar(cartProvider),
                  _buildNotificationBar(),
                  _buildHorizontalMenu(),
                  // Expanded body
                  Expanded(
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double screenWidth = MediaQuery.of(context).size.width;
                            int crossAxisCount = 1;
                            if (screenWidth >= 1200) {
                              crossAxisCount = 4;
                            } else if (screenWidth >= 900) {
                              crossAxisCount = 3;
                            } else if (screenWidth >= 600) {
                              crossAxisCount = 2;
                            }
                            double cardAspectRatio = 0.65; // Reduced to accommodate quantity selector
                            double videoHeight = screenWidth * 9 / 16;
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: screenWidth,
                                        height: videoHeight,
                                        child: FutureBuilder(
                                          future: _initializeVideoPlayerFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.done) {
                                              return VideoPlayer(_controller);
                                            } else {
                                              return Center(child: CircularProgressIndicator());
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth,
                                        height: videoHeight,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              const Color.fromARGB(0, 255, 255, 255),
                                              Color.fromARGB(255, 255, 255, 255),
                                            ],
                                            stops: [0.7, 1.0],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, bottom: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Relax, Revive & Rejuvenate',
                                          style: kSectionTitleStyle,
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryButtonColor),
                                          child: Text('Book a Plan', style: kButtonTextStyle),
                                        ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text(
                                            'Products',
                                            style: kSectionTitleStyle,
                                          ),
                                        ),
                                        if (_productsLoading)
                                          Center(child: CircularProgressIndicator())
                                        else if (_productsError != null)
                                          Center(child: Text(_productsError!))
                                        else
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 24,
                                            mainAxisSpacing: 24,
                                            childAspectRatio: cardAspectRatio,
                                          ),
                                          itemCount: _products.length,
                                          itemBuilder: (context, index) {
                                            final product = _products[index];
                                            return GestureDetector(
                                              onTap: () {
                                                // Pass product data directly instead of using route name
                                                final productMap = {
                                                  'id': product.id,
                                                  'name': product.name,
                                                  'image': product.imageUrl,
                                                  'desc': product.description,
                                                  'price': product.price,
                                                };
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProductDetailPage(product: productMap),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                elevation: 4,
                                                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(16),
                                                            topRight: Radius.circular(16),
                                                          ),
                                                          child: Container(
                                                            color: Colors.white,
                                                            child: product.imageUrl.isNotEmpty
                                                                ? Image.network(
                                                                    product.imageUrl,
                                                                    width: double.infinity,
                                                                    fit: BoxFit.cover,
                                                                  )
                                                                : Container(color: Colors.grey[200]),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        product.name,
                                                        style: kProductTitleStyle,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        product.description,
                                                        style: kProductDescStyle,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        '₹${product.price.toStringAsFixed(2)}',
                                                        style: kProductPriceStyle,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.star, color: Colors.orange, size: 16),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '(${product.rating.toStringAsFixed(1)})',
                                                            style: kProductRatingStyle,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      // Quantity selector
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Qty:',
                                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                          ),
                                                          SizedBox(width: 4),
                                                          Container(
                                                            height: 24,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    int currentQty = getQuantityForProduct(product.id);
                                                                    if (currentQty > 1) {
                                                                      setQuantityForProduct(product.id, currentQty - 1);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: Icon(Icons.remove, size: 12),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 30,
                                                                  height: 24,
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      left: BorderSide(color: Colors.grey),
                                                                      right: BorderSide(color: Colors.grey),
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      getQuantityForProduct(product.id).toString(),
                                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    int currentQty = getQuantityForProduct(product.id);
                                                                    if (currentQty < 10) { // Max quantity limit
                                                                      setQuantityForProduct(product.id, currentQty + 1);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: Icon(Icons.add, size: 12),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          int selectedQuantity = getQuantityForProduct(product.id);
                                                          cartProvider.addToCart(
                                                            CartItem(
                                                              productId: product.id,
                                                              name: product.name,
                                                              image: product.imageUrl,
                                                              desc: product.description,
                                                              price: product.price,
                                                              quantity: selectedQuantity,
                                                            ),
                                                            productId: product.id,
                                                            productsList: _products,
                                                          );
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('${product.name} (${selectedQuantity}) added to cart!')),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: kAddToCartButtonColor,
                                                          minimumSize: Size(double.infinity, 40),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          padding: EdgeInsets.symmetric(vertical: 8),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.shopping_bag, color: Colors.white, size: 18),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              'Add to Cart',
                                                              style: kButtonTextStyle,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 20),
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
                                ],
                              ));
                          },
                        ),
                        ChatbotWidget(),
                      ],
                    ),
                  ),
                ],
              ),
              // Drawer overlay
              if (_showDrawer)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeDrawer,
                    child: Material(
                      color: Colors.black.withOpacity(0.3),
                      child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {}, // Prevent tap from closing drawer
                        child: Container(
                          width: 350,
                          child: Drawer(
                            child: Container(
                              color: Color(0xFF4A2C2A),
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    // Top section with user info
                                    Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.grey[300],
                                                child: Icon(Icons.person, size: 40, color: Colors.grey),
                                              ),
                                              SizedBox(width: 16),
                                              ValueListenableBuilder<String?>(
                                                valueListenable: loggedInUsername,
                                                builder: (context, username, _) {
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        username?.isNotEmpty == true ? username! : 'Guest',
                                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        username?.isNotEmpty == true ? 'Welcome back!' : 'Sign in to continue',
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.white, size: 28),
                                            onPressed: _closeDrawer,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(color: Colors.white54),
                                    
                                    // Conditional sign in/register or user options based on login status
                                    ValueListenableBuilder<String?>(
                                      valueListenable: loggedInUsername,
                                      builder: (context, username, _) {
                                        if (username?.isNotEmpty == true) {
                                          // User is logged in - show user-specific options
                                          return Column(
                                            children: [
                                              _buildDrawerItem(Icons.account_circle, 'My Account', () {
                                                _closeDrawer();
                                                Navigator.pushNamed(context, '/my-account');
                                              }),
                                              _buildDrawerItem(Icons.shopping_cart, 'My Cart', () {
                                                _closeDrawer();
                                                Navigator.pushNamed(context, '/cart');
                                              }),
                                              _buildDrawerItem(Icons.logout, 'Sign Out', () {
                                                _closeDrawer();
                                                loggedInUsername.value = null;
                                                UserSession.clearUserSession();
                                              }),
                                              Divider(color: Colors.white54),
                                            ],
                                          );
                                        } else {
                                          // User is not logged in - show sign in and register options
                                          return Column(
                                            children: [
                                              _buildDrawerItem(Icons.login, 'Sign In', () {
                                                _closeDrawer();
                                                _openAuthOverlay(true);
                                              }),
                                              _buildDrawerItem(Icons.person_add, 'Register', () {
                                                _closeDrawer();
                                                _openAuthOverlay(false);
                                              }),
                                              Divider(color: Colors.white54),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    
                                    // Navigation menu items
                                    _buildDrawerItem(Icons.home, 'Home', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/home');
                                    }),
                                    _buildDrawerItem(Icons.info, 'About Us', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/about');
                                    }),
                                    _buildDrawerItem(Icons.local_offer, 'Services', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/services');
                                    }),
                                    _buildDrawerItem(Icons.school, 'Courses', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/courses');
                                    }),
                                    _buildDrawerItem(Icons.person, 'Doctors', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/doctors');
                                    }),
                                    _buildDrawerItem(Icons.shopping_cart, 'Products', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/products');
                                    }),
                                    _buildDrawerItem(Icons.contact_mail, 'Contact Us', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/contact');
                                    }),
                                    _buildDrawerItem(Icons.help, 'FAQs', () {
                                      _closeDrawer();
                                      Navigator.pushNamed(context, '/faqs');
                                    }),
                                    Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                icon: Icon(Icons.menu, color: Colors.black87, size: 28),
                onPressed: _openDrawer,
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