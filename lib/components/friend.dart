import 'package:flutter/material.dart';
import 'package:my_zypher/db.dart';

class FriendItem extends StatelessWidget {
  final int id;
  final int parentId;
  final String name;
  final DatabaseHelper dbHelper;

  const FriendItem({
    Key? key,
    required this.id,
    required this.parentId,
    required this.name,
    required this.dbHelper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FutureBuilder<int>(
              future: dbHelper.getMutualFriendsCount(parentId, id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final mutualFriendsCount = snapshot.data ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$mutualFriendsCount mutual friend(s)'),
                    ],
                  );
                }
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              dbHelper.deleteFriend(id, parentId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Friend Removed')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // Background color
              foregroundColor: Colors.white, // Icon and text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            icon: const Icon(Icons.remove),
            label: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
