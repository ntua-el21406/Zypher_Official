import 'package:flutter/material.dart';
import 'package:my_zypher/db.dart';

class FriendRequestItem extends StatelessWidget {
  final int id;
  final int parentId;
  final String name;
  final DatabaseHelper dbHelper;

  const FriendRequestItem({
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
          Column(
            children: [
              SizedBox(
                width: 140, // Width of the Rate button
                height: 40, // Height of the Rate button
                child: ElevatedButton.icon(
                  onPressed: () {
                    dbHelper.insertFriend({
                      'user1_id': id,
                      'user2_id': parentId,
                    });
                    dbHelper.acceptFriendRequest({
                      'sender_id': id,
                      'receiver_id': parentId,
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Background color
                    foregroundColor: Colors.white, // Icon and text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Rounded corners for the button
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8), // Space between buttons
              SizedBox(
                width: 140, // Width of the Add friend button
                height: 40, // Height of the Add friend button
                child: ElevatedButton.icon(
                  onPressed: () {
                    dbHelper.rejectFriendRequest({
                      'sender_id': id,
                      'receiver_id': parentId,
                    });
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Background color
                    foregroundColor: Colors.white, // Icon and text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Rounded corners for the button
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
