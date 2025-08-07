import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app_config.dart';
import '../user_session.dart';
import '../product.dart';

class CartItem {
  final int? productId;
  final String name;
  final String image;
  final String desc;
  final double price;
  final int quantity;

  CartItem({
    this.productId,
    required this.name,
    required this.image,
    required this.desc,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> addToCart(CartItem item, {int? productId, List<Product>? productsList}) async {
    int? userId = await UserSession.getUserId();
    
    if (userId == null || userId == 0) {
      // Guest: local cart
      _cartItems.add(item);
      notifyListeners();
    } else {
      // Logged in: send to backend
      final token = await UserSession.getToken();
      
      // Check if we have all required data
      if (token == null || token.isEmpty) {
        _cartItems.add(item);
        notifyListeners();
        return;
      }
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final requestBody = {
        'userId': userId,
        'productId': productId ?? item.productId,
        'quantity': item.quantity,
      };
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/cart'),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (productsList != null) {
          await fetchCart(productsList); // Fetch from backend after add for logged-in users
        } else {
          // Add to local cart for immediate UI update when productsList is not available
          _cartItems.add(item);
          notifyListeners();
        }
      } else if (response.statusCode == 403) {
        // Token might be invalid, fall back to local cart
        _cartItems.add(item);
        notifyListeners();
      } else {
        throw Exception('Failed to add to cart in backend: ${response.statusCode} - ${response.body}');
      }
    }
  }

  Future<void> removeFromCart(CartItem item, {List<Product>? productsList}) async {
    int? userId = await UserSession.getUserId();
    if (userId == null || userId == 0) {
      // Guest: remove from local cart
      _cartItems.remove(item);
      notifyListeners();
    } else {
      // Logged in: remove from backend
      if (item.productId != null) {
        final token = await UserSession.getToken();
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final response = await http.delete(
          Uri.parse(AppConfig.apiBaseUrl + '/cart?userId=$userId&productId=${item.productId}'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          if (productsList != null) {
            await fetchCart(productsList); // Refresh cart from backend after deletion
          }
        } else {
          throw Exception('Failed to remove from cart in backend');
        }
      } else {
        // Fallback: remove from local cart if productId is not available
        _cartItems.remove(item);
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> fetchCart(List<Product> productsList) async {
    int? userId = await UserSession.getUserId();
    if (userId == null || userId == 0) {
      // Guest: use local cart
      notifyListeners();
      return;
    }
    final token = await UserSession.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(
      Uri.parse(AppConfig.apiBaseUrl + '/cart/$userId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _cartItems = data.map((json) {
        final product = productsList.firstWhere(
          (p) => p.id == json['productId'],
          orElse: () => Product(
            id: json['productId'],
            name: 'Unknown',
            description: '',
            price: 0.0,
            imageUrl: '',
            rating: 0.0,
          ),
        );
        return CartItem(
          productId: json['productId'],
          name: product.name,
          image: product.imageUrl,
          desc: product.description,
          price: product.price,
          quantity: json['quantity'] ?? 1,
        );
      }).toList();
      notifyListeners();
    }
  }
}