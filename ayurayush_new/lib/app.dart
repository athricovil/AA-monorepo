import 'package:flutter/material.dart';
import 'about_page.dart';
import 'products_page.dart';
import 'cart_page.dart';
import 'my_account.dart';
import 'home_page.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayurayush',
      theme: ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
  ),
),
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        // Handle any dynamic routes that don't have product data passed directly
        // For now, just return the default route
        return MaterialPageRoute(builder: (context) => HomePage());
      },
      routes: {
        '/home': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/products': (context) => ProductsPage(),
        '/cart': (context) => CartPage(),
        '/my-account': (context) => MyAccountPage(),
      },
    );
  }
}
