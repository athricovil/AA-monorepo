import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ChatbotWidget extends StatefulWidget {
  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  bool _isChatOpen = false;
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'bot', 'message': 'Hello! Welcome to Ayurayush. How can I assist you today?', 'isRichText': false},
  ];
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _products = [
    {'name': 'Pilopouse', 'image': 'assets/images/pilopouse.jpg', 'desc': 'Herbal supplement for health.', 'price': 2195.00, 'keywords': ['supplement', 'health']},
    {'name': 'Prostostop', 'image': 'assets/images/prostostop.jpg', 'desc': 'Supports prostate health.', 'price': 875.00, 'keywords': ['prostate', 'health']},
    {'name': 'Saffron Care', 'image': 'assets/images/saffron_care.jpg', 'desc': 'Skin-nourishing oil.', 'price': 3895.00, 'keywords': ['skin', 'care', 'oil']},
    {'name': 'Stomacalm', 'image': 'assets/images/stomacalm.jpg', 'desc': 'Digestive health support.', 'price': 1599.00, 'keywords': ['digestive', 'health']},
    {'name': 'Vaji Cap', 'image': 'assets/images/vaji_cap.jpg', 'desc': 'Herbal supplements to improve sexual capacity.', 'price': 2499.00, 'keywords': ['sexual', 'health', 'supplement']},
  ];

  void _handleUserMessage(String message) {
    setState(() {
      _messages.add({'sender': 'user', 'message': message, 'isRichText': false});
    });

    var response = _generateBotResponse(message.toLowerCase());
    setState(() {
      _messages.add(response);
    });

    _controller.clear();
  }

  Map<String, dynamic> _generateBotResponse(String message) {
    if (message.contains('hi') || message.contains('hello')) {
      return {'sender': 'bot', 'message': 'Hello! How can I help you today?', 'isRichText': false};
    } else if (message.contains('ayurveda')) {
      return {'sender': 'bot', 'message': 'Ayurveda is a 5,000-year-old system of natural healing. Would you like to learn more or explore related products?', 'isRichText': false};
    } else if (message.contains('cart')) {
      return {'sender': 'bot', 'message': 'You can view your cart by clicking the shopping cart icon. Would you like to go to your cart now?', 'isRichText': false};
    } else if (message.contains('about')) {
      return {'sender': 'bot', 'message': 'Learn more about us on the About page. Would you like to visit?', 'isRichText': false};
    } else if (message.contains('contact')) {
      return {'sender': 'bot', 'message': 'Contact us at info@ayurayush.com or +1(650) 695-7707. Visit the Contact page for more?', 'isRichText': false};
    } else {
      List<Map<String, dynamic>> suggestions = _getProductSuggestions(message);
      if (suggestions.isNotEmpty) {
        return {
          'sender': 'bot',
          'message': suggestions,
          'isRichText': true,
          'additionalText': 'Would you like to add any of these to your cart or view the Products page? Let me know how else I can assist!'
        };
      } else {
        return {'sender': 'bot', 'message': "I'm not sure I understand. Can you tell me more? I can help with Ayurveda, products, your cart, or contact information.", 'isRichText': false};
      }
    }
  }

  List<Map<String, dynamic>> _getProductSuggestions(String message) {
    List<Map<String, dynamic>> suggestions = [];
    for (var product in _products) {
      for (var keyword in product['keywords']) {
        if (message.contains(keyword)) {
          suggestions.add(product);
          break;
        }
      }
    }
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isChatOpen)
          Positioned(
            bottom: 80,
            right: 20,
            child: Container(
              width: MediaQuery.of(context).size.width > 600 ? 350 : 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF6A1B9A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ayurayush Assistant',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isChatOpen = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isBot = message['sender'] == 'bot';
                        return Align(
                          alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isBot ? Colors.grey[200] : Color(0xFF6A1B9A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: message['isRichText'] == true
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Based on your need, I recommend:',
                                        style: TextStyle(
                                          color: isBot ? Colors.black : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      ...List.generate(
                                        (message['message'] as List<Map<String, dynamic>>).length,
                                        (i) {
                                          final product = (message['message'] as List<Map<String, dynamic>>)[i];
                                          return Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '- ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: product['name'],
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 14,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Navigator.pushNamed(context, '/products/${product['name'].toLowerCase()}');
                                                      },
                                                  ),
                                                  TextSpan(
                                                    text: ' (₹${product['price'].toStringAsFixed(2)}) - ${product['desc']}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        message['additionalText'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isBot ? Colors.black : Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _handleUserMessage(value);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.send, color: Color(0xFF6A1B9A)),
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              _handleUserMessage(_controller.text);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Color(0xFF6A1B9A),
            onPressed: () {
              setState(() {
                _isChatOpen = !_isChatOpen;
              });
            },
            child: Icon(_isChatOpen ? Icons.chat_bubble_outline : Icons.chat, color: Colors.white),
          ),
        ),
      ],
    );
  }
}