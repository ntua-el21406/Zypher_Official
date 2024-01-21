import 'package:flutter/material.dart';
import '../components/recommended_friend.dart';
import '../components/friend_request.dart';
import '../core/constants/constants.dart';
import '../components/friend.dart';
import 'package:my_zypher/db.dart';

class FriendsScreen extends StatefulWidget {
  final int id;
  final DatabaseHelper dbHelper;
  const FriendsScreen({Key? key, required this.id, required this.dbHelper})
      : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center column content vertically
          children: [
            Image.asset(Constants.singleLetterLogoPath,
                height: 80), // Logo image
            const Text(
              'Friends',
              style: TextStyle(
                decoration: TextDecoration.underline, // No underline for title
                fontSize: 30.0,
              ),
            ),
          ],
        ),
        centerTitle: true, // Center the column
        toolbarHeight:
            150, // Increase the toolbar height to accommodate the logo and title
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My friends'),
            Tab(text: 'Recommended'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyFriendsTab(id: widget.id, dbHelper: widget.dbHelper),
          RecommendedTab(id: widget.id, dbHelper: widget.dbHelper),
          RequestsTab(id: widget.id, dbHelper: widget.dbHelper),
        ],
      ),
    );
  }
}

// ===================== MY FRIENDS ====================================

class MyFriendsTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  const MyFriendsTab({Key? key, required this.dbHelper, required this.id})
      : super(key: key);

  @override
  State<MyFriendsTab> createState() => _MyFriendsTabState();
}

class _MyFriendsTabState extends State<MyFriendsTab> {
  late Future<List<FriendItem>> friends;

  Future<List<FriendItem>> getFriendsHelper(int userId) async {
    final results = await widget.dbHelper.getFriends(userId); //
    return results.map(
      (result) {
        return FriendItem(
          id: result['userId'],
          parentId: userId,
          name: result['fullName'],
          dbHelper: widget.dbHelper,
        );
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    friends = getFriendsHelper(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FriendItem>>(
      future: friends,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final friend = snapshot.data![index];
              return FriendItem(
                name: friend.name,
                id: friend.id,
                parentId: widget.id,
                dbHelper: widget.dbHelper,
              );
            },
          );
        }
      },
    );
  }
}

// ========================= RECOMMENDED FRIENDS ================================

class RecommendedTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  const RecommendedTab({Key? key, required this.dbHelper, required this.id})
      : super(key: key);

  @override
  State<RecommendedTab> createState() => _RecommendedTabState();
}

class _RecommendedTabState extends State<RecommendedTab> {
  late Future<List<RecommendedFriendItem>> recommendedFriends;

  Future<List<RecommendedFriendItem>> getRecommendedFriendsHelper(
      int userId) async {
    final results = await widget.dbHelper.getRecommendedFriends(userId);
    return results.map(
      (result) {
        return RecommendedFriendItem(
          id: result['userId'],
          parentId: userId,
          name: result['fullName'],
          dbHelper: widget.dbHelper,
        );
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    recommendedFriends = getRecommendedFriendsHelper(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecommendedFriendItem>>(
      future: recommendedFriends,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final friend = snapshot.data![index];
              return RecommendedFriendItem(
                name: friend.name,
                id: friend.id,
                parentId: widget.id,
                dbHelper: widget.dbHelper,
              );
            },
          );
        }
      },
    );
  }
}

// ===================== REQUESTS =============================

class RequestsTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  const RequestsTab({Key? key, required this.dbHelper, required this.id})
      : super(key: key);

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  late Future<List<FriendRequestItem>> friendRequests;

  Future<List<FriendRequestItem>> getFriendRequestsHelper(int userId) async {
    final results = await widget.dbHelper.getFriendRequests(userId);
    return results.map(
      (result) {
        return FriendRequestItem(
          id: result['userId'],
          parentId: userId,
          name: result['fullName'],
          dbHelper: widget.dbHelper,
        );
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    friendRequests = getFriendRequestsHelper(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FriendRequestItem>>(
      future: friendRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final friend = snapshot.data![index];
              return FriendRequestItem(
                name: friend.name,
                id: friend.id,
                parentId: widget.id,
                dbHelper: widget.dbHelper,
              );
            },
          );
        }
      },
    );
  }
}
