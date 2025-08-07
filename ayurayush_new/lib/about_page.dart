import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chatbot_widget.dart';
import 'providers/cart_provider.dart';
import 'styles.dart';
import 'user_session.dart';
import 'home_page.dart'; // for loggedInUsername
import 'login.dart';
import 'signup.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      if (mounted) setState(() {});
    }
  }

  Widget _buildNavbar(CartProvider cartProvider) {
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
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 28, minHeight: 28),
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

  Widget _buildFeatureItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle,
              color: Color(0xFF4A2C2A),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              decoration: (text.contains('www.') || text.contains('@')) 
                  ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              children: [
                _buildNavbar(cartProvider),
                _buildNotificationBar(),
                _buildHorizontalMenu(),
                Expanded(
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF4A2C2A).withOpacity(0.1),
                                        Colors.white,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Relax, Revive & Rejuvenate',
                                        style: kSectionTitleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(backgroundColor: kAddToCartButtonColor),
                                        child: Text('Book a Plan', style: kButtonTextStyle),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, bottom: 10),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          'About us',
                                          style: kSectionTitleStyle,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Ayur Ayush',
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A2C2A)),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Welcome to Ayur-Ayush, your gateway to the profound wisdom of Authentic and Traditional Ayurveda. Nestled in the heart of Kerala, Ayurayush invites you to embark on a journey towards holistic health and wellness through time-honored Ayurvedic practices.',
                                          style: TextStyle(fontSize: 16, height: 1.5),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Embracing modern technology, Ayurayush extends its services beyond physical boundaries, offering Online Ayurvedic consultations and follow-up health checkups to ensure continued well-being. Our comprehensive range of offerings includes authentic Ayurvedic treatments, enriching Ayurveda courses, and a curated selection of genuine Ayurvedic products, all tailored to meet your individual needs.',
                                          style: TextStyle(fontSize: 16, height: 1.5),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.symmetric(horizontal: 16),
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'ESSENCE OF AYURVEDA',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4A2C2A),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Ayurveda, a 5,000-year-old system of natural healing emphasizes a balanced lifestyle. The term Ayurveda is derived from two Sanskrit words ayur (life) and veda (science or knowledge). Thus, Ayurveda means "knowledge of life". Ayurveda encourages certain lifestyle, Diet habits, natural therapies and Herbal medication to regain a balance between the body, mind, spirit, and the environment.',
                                              style: TextStyle(fontSize: 16, height: 1.5),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.symmetric(horizontal: 16),
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4A2C2A).withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Color(0xFF4A2C2A).withOpacity(0.2)),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Get unique experience!',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4A2C2A),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Column(
                                              children: [
                                                _buildFeatureItem('With our treatment you have access to world-class practitioners'),
                                                _buildFeatureItem('Personalized online consultations'),
                                                _buildFeatureItem('Convenient Access - Easily access online and offline consultation'),
                                                _buildFeatureItem('Natural herbal remedies'),
                                                _buildFeatureItem('Experienced Ayurveda practitioners'),
                                                _buildFeatureItem('Holistic Approach - Holistic treatment'),
                                                _buildFeatureItem('Side-effect free'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.symmetric(horizontal: 16),
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4A2C2A),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'CONTACT US',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            _buildContactItem(Icons.language, 'www.ayurayush.com'),
                                            _buildContactItem(Icons.phone, '+1(650) 695-7707'),
                                            _buildContactItem(Icons.email, 'info@ayurayush.com'),
                                          ],
                                        ),
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
                            ),
                          );
                        },
                      ),
                      ChatbotWidget(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}