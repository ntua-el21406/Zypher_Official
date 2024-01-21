// user_item.dart
import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  final String name;
  final double rating;
  final Widget imageWidget; // Accepting a Widget for the image

  const UserItem({
    Key? key,
    required this.name,
    required this.rating,
    required this.imageWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Text(' $rating'),
                  ],
                ),
              ],
            ),
          ),
          // Using CircleAvatar with a child widget
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent, // Make background transparent
            child: ClipOval(
              child: imageWidget, // Using the passed Widget directly
            ),
          ),
        ],
      ),
    );
  }
}
