import 'package:flutter/material.dart' ;
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:carousel_slider/carousel_controller.dart' as carousel_controller;

class ImageCarousel extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/images/American-studen-ebfdf61a-402d-470f-aea1-175fce862c20.webp',
    'assets/images/AYURVEDA-FUNDAMENTAL-COURSE.webp',
    'assets/images/AYURVEDA-PANCHAKARMA.webp',
    'assets/images/Tridosha-Phylos-93bcb7cd-2cd7-4967-ab96-7a1ffa759459.webp',
  ];

  final carousel_controller.CarouselSliderController _controller = carousel_controller.CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return carousel_slider.CarouselSlider(
      options: carousel_slider.CarouselOptions(
        height: 500.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: imagePaths.map((path) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
              child: Image.asset(path, fit: BoxFit.cover),
            );
          },
        );
      }).toList(),
      carouselController: _controller,
    );
  }
}