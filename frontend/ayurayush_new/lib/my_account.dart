import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'signup.dart';
import 'user_session.dart';
import 'styles.dart';
import 'providers/cart_provider.dart';
import 'home_page.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String? username;
  bool isLoading = true;
  bool _showDrawer = false;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final savedUsername = await UserSession.getUsername();
    setState(() {
      username = savedUsername;
      isLoading = false;
    });
  }

  void _openDrawer() {
    setState(() {
      _showDrawer = true;
    });
  }

  void _closeDrawer() {
    setState(() {
      _showDrawer = false;
    });
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
      if (mounted) setState(() {
        username = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : username != null
                            ? _buildLoggedInView()
                            : _buildGuestView(),
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
            _buildMenuItem('My Account', isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {bool isActive = false}) {
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
          case 'My Account':
            // Already on account page
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: isActive ? Border(bottom: BorderSide(color: Color(0xFF4A2C2A), width: 2)) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Color(0xFF4A2C2A) : Colors.black87,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
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
                color: Color(0xFF4A2C2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF4A2C2A), size: 16),
                  ),
                  SizedBox(width: 8),
                  Text(
                    username.length > 10 ? '${username.substring(0, 10)}...' : username,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
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
                  Navigator.pushNamed(context, '/my-account');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/cart');
                  break;
                case 4:
                  loggedInUsername.value = null;
                  UserSession.clearUserSession();
                  setState(() {
                    username = null;
                  });
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
                      Icon(Icons.account_circle, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                      Icon(Icons.shopping_cart, color: Color(0xFF4A2C2A), size: 20),
                      SizedBox(width: 12),
                      Text('My Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

  Widget _buildLoggedInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A2C2A), Color(0xFF6D4C41)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4A2C2A).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        username!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ayurvedic Health Explorer',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Orders', '12', Icons.shopping_bag, kSupportIconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Wishlist', '5', Icons.favorite, Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Rewards', '₹250', Icons.stars, Colors.orange),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Account Sections
          Text(
            'Account',
            style: kSectionTitleStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          
          _buildAccountSection('My Orders', 'Track, return, or cancel orders', Icons.shopping_bag, () {}),
          _buildAccountSection('My Wishlist', 'View your saved products', Icons.favorite_border, () {}),
          _buildAccountSection('Address Book', 'Manage delivery addresses', Icons.location_on, () {}),
          _buildAccountSection('Payment Methods', 'Manage cards and wallets', Icons.payment, () {}),
          
          const SizedBox(height: 24),
          
          Text(
            'Settings',
            style: kSectionTitleStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          
          _buildAccountSection('Profile Settings', 'Update personal information', Icons.person, () {}),
          _buildAccountSection('Notifications', 'Manage app notifications', Icons.notifications, () {}),
          _buildAccountSection('Privacy & Security', 'Password, data settings', Icons.security, () {}),
          _buildAccountSection('Language & Region', 'App language and location', Icons.language, () {}),
          
          const SizedBox(height: 24),
          
          Text(
            'Support',
            style: kSectionTitleStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          
          _buildAccountSection('Help Center', 'FAQs and support articles', Icons.help, () {}),
          _buildAccountSection('Contact Us', 'Get in touch with support', Icons.support_agent, () {}),
          _buildAccountSection('Rate the App', 'Share your feedback', Icons.star, () {}),
          
          const SizedBox(height: 32),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await UserSession.clearUserSession();
                loggedInUsername.value = null;
                setState(() {
                  username = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.red[200]!),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guest Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A2C2A), Color(0xFF6D4C41)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4A2C2A).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to AyurAyush',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in or create an account to access your personalized Ayurvedic journey',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openAuthOverlay(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF4A2C2A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Sign In', style: kButtonTextStyle.copyWith(color: Color(0xFF4A2C2A))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openAuthOverlay(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Create Account', style: kButtonTextStyle),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Features for Guests
          Text(
            'Why Create an Account?',
            style: kSectionTitleStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          
          _buildFeatureCard(
            'Track Your Orders',
            'Get real-time updates on your order status and delivery',
            Icons.track_changes,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Save Your Favorites',
            'Create wishlists and save products for later',
            Icons.favorite,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Personalized Recommendations',
            'Get product suggestions based on your health needs',
            Icons.recommend,
            kSupportIconColor,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Exclusive Offers',
            'Access member-only discounts and early sales',
            Icons.local_offer,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Health Journey Tracking',
            'Monitor your wellness progress with our tools',
            Icons.health_and_safety,
            Colors.purple,
          ),
          
          const SizedBox(height: 32),
          
          // Browse as Guest
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Text(
                  'Browse as Guest',
                  style: kSectionTitleStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can continue shopping without an account, but you\'ll miss out on personalized features',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text('Continue Browsing'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Support Section
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
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[700]),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
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
