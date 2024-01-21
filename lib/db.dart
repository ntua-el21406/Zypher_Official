import 'dart:ffi';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:faker/faker.dart';
import 'dart:math';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern for database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'users.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> initDatabase() async {
    print('Initialising Database...');
    final path = await fullPath;
    print('Database path: $path');

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {},
      singleInstance: true,
    );
    
    await database.execute(
      '''CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY,
          username TEXT,
          password TEXT,
          email TEXT,
          firstName TEXT,
          lastName TEXT,
          licencePlate TEXT,
          carModel TEXT,
          points INTEGER DEFAULT 1000,
          image_path TEXT)''',
    );
    await database.execute(
      '''CREATE TABLE IF NOT EXISTS friends (
          user1_id INTEGER,
          user2_id INTEGER,
          PRIMARY KEY (user1_id, user2_id),
          FOREIGN KEY (user1_id) REFERENCES users(id),
          FOREIGN KEY (user2_id) REFERENCES users(id))''',
    );
    await database.execute(
      '''CREATE TABLE IF NOT EXISTS friend_requests (
          sender_id INTEGER,
          receiver_id INTEGER,
          status TEXT DEFAULT 'pending',
          CHECK (status IN ('pending', 'accepted', 'rejected')),
          PRIMARY KEY (sender_id, receiver_id),
          FOREIGN KEY (sender_id) REFERENCES users(id),
          FOREIGN KEY (receiver_id) REFERENCES users(id))''',
    );
    await database.execute(
      '''CREATE TABLE IF NOT EXISTS activities (
          id INTEGER PRIMARY KEY,
          carModel TEXT,
          date DATE,
          price DECIMAL(10, 2), -- Assuming the price is a decimal value, adjust as needed
          driverId INTEGER,
          passengerId INTEGER,
          FOREIGN KEY (driverId) REFERENCES users(id),
          FOREIGN KEY (passengerId) REFERENCES users(id))''',
    );
    await database.execute(
      '''CREATE TABLE IF NOT EXISTS locations(
          id INTEGER PRIMARY KEY,
          userid INTEGER,
          start_lat TEXT,
          start_lon TEXT,
          end_lat TEXT,
          end_lon TEXT,
          status TEXT)''',
    );

    



    print('Database Initialised Succesfully');
    return database;
  }


  Future<void> insertRandomLocations(int count) async {
    final db = await database;
    
    int? rowCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM locations'));

    if (rowCount == 0) {

        Random random = Random();

        // Define the boundaries of Athens, Greece
        double latStart = 37.95;
        double latEnd = 38.05;
        double lonStart = 23.70;
        double lonEnd = 23.80;
        for (int i = 0; i < count; i++) {
      try {
        double startLat = latStart + (latEnd - latStart) * random.nextDouble();
        double startLon = lonStart + (lonEnd - lonStart) * random.nextDouble();
        double endLat = latStart + (latEnd - latStart) * random.nextDouble();
        double endLon = lonStart + (lonEnd - lonStart) * random.nextDouble();

        int userId = random.nextInt(count) + 1; // User IDs 1 through 10
        String status = random.nextBool() ? '1' : '0'; // Status 0 or 1

        Map<String, dynamic> locationData = {
          'userid': userId,
          'start_lat': startLat.toStringAsFixed(6),
          'start_lon': startLon.toStringAsFixed(6),
          'end_lat': endLat.toStringAsFixed(6),
          'end_lon': endLon.toStringAsFixed(6),
          'status': status
        };

        await db.insert('locations', locationData);

        // Print out the inserted data
        print('Inserted location: $locationData');
      } catch (e) {
        // If an error occurs, log the error and continue with the next iteration
        print('Error inserting location: $e');
      }
      }
    }






  }


  Future<void> insertRandomUsers(int count) async {
      final db = await database;
      final faker = Faker();

    int? rowCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));

    if (rowCount == 0){

      for (int i = 0; i < count; i++) {
        try {
          // Generate random user data
          String username = faker.internet.userName();
          String password = faker.internet.password();
          String email = faker.internet.email();
          String firstName = faker.person.firstName();
          String lastName = faker.person.lastName();
          String licencePlate = faker.vehicle.vin();
          String carModel = faker.vehicle.model();
          String imagePath = faker.image.image();

          // User data map
          Map<String, dynamic> userData = {
            'username': username,
            'password': password,
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'licencePlate': licencePlate,
            'carModel': carModel,
            'image_path': imagePath
          };

          // Insert the user into the "users" table
          await db.insert('users', userData);

          // Print out the inserted data
          print('Inserted user: $userData');
        } catch (e) {
          // If an error occurs, log the error and continue with the next iteration
          print('Error inserting user: $e');
        }
            await db.insert('users', {
      'username': 'epa',
      'password': 'epa',
      'email': 'epa@epa.com',
      'firstName': 'epa',
      'lastName': 'epa',
      'licencePlate': 'epa',
      'carModel': 'epa',
      'points': 1000,  // Using the default value
      'image_path': 'epa'
    });
      }
    }
  }














  Future<void> deleteTable(String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    print('Table $tableName Deleted');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user);
    print('User Inserted');
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<int> getUserId(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.first['id'];
  }

  Future<Map<String, dynamic>> getUserInfo(int id) async {
    final db = await database;
    // Query the users table for the row with the matching ID.
    List<Map<String, dynamic>> result = await db.query(
      'users',
      // Select all columns to get all user info.
      columns: [
        'id',
        'username',
        'password',
        'email',
        'firstName',
        'lastName',
        'licencePlate',
        'carModel',
        'points', //gia na parw tous pontous
        'image_path', // prostheto alli mia stili gia tin eikona
      ],
      where: 'id = ?',
      whereArgs: [id],
    );
    // Check if we got any results.
    if (result.isNotEmpty) {
      print('Id found');
      return result.first;
    } else {
      print('Id not found');
      return {};
    }
  }

  Future<int> getUserPoints(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['points'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.first['points'];
  }

  Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final db = await database;
    await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [id],
    );
    print('User Updated');
  }

  Future<void> saveUserImage(int userId, String imagePath) async {
    final db = await database;
    await db.update(
      'users',
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await database;
    // Select friends of the user from the friends table
    final result = await db.rawQuery('''
      SELECT users.id AS userId, users.firstName || ' ' || users.lastName AS fullName
      FROM users
      WHERE users.id != ? AND users.id IN (
      SELECT user1_id FROM friends WHERE user2_id = ?
      UNION
      SELECT user2_id FROM friends WHERE user1_id = ?)''',
        [userId, userId, userId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRecommendedFriends(int userId) async {
    final db = await database;
    // Select all users except the specified user and their friends
    final result = await db.rawQuery('''
      SELECT users.id AS userId, users.firstName || ' ' || users.lastName AS fullName
      FROM users
      WHERE users.id != ? AND users.id NOT IN (
      SELECT user1_id FROM friends WHERE user2_id = ?
      UNION
      SELECT user2_id FROM friends WHERE user1_id = ?)''',
        [userId, userId, userId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getFriendRequests(int userId) async {
    final db = await database;
    // Select friend requests for the user where the user is the receiver
    final result = await db.rawQuery('''
      SELECT users.id AS userId, users.firstName || ' ' || users.lastName AS fullName
      FROM friend_requests
      JOIN users ON friend_requests.sender_id = users.id
      WHERE friend_requests.receiver_id = ? AND friend_requests.status = 'pending'
      ''', [userId]);
    return result;
  }

  Future<void> insertFriend(Map<String, dynamic> friendship) async {
    final db = await database;

    // Check if the friendship already exists
    List<Map<String, dynamic>> existingFriendships = await db.query(
      'friends',
      where:
          '(user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)',
      whereArgs: [
        friendship['user1_id'],
        friendship['user2_id'],
        friendship['user2_id'],
        friendship['user1_id']
      ],
    );
    // If no existing friendships found, insert the new friendship
    if (existingFriendships.isEmpty) {
      await db.insert('friends', friendship);
      print('Friend Inserted');
    } else {
      print('Friendship already exists, not inserted');
    }
  }

  Future<void> insertFriendRequest(Map<String, dynamic> friendship) async {
    final db = await database;

    List<Map<String, dynamic>> friendRequestsSender = await db.query(
      'friend_requests',
      where: '(sender_id = ? AND receiver_id = ?)',
      whereArgs: [friendship['sender_id'], friendship['receiver_id']],
    );

    List<Map<String, dynamic>> friendRequestsSenderRejected = await db.query(
      'friend_requests',
      where: '(sender_id = ? AND receiver_id = ? AND status != "rejected")',
      whereArgs: [friendship['sender_id'], friendship['receiver_id']],
    );

    List<Map<String, dynamic>> friendRequestsReceiver = await db.query(
      'friend_requests',
      where: '(sender_id = ? AND receiver_id = ? AND status != "rejected")',
      whereArgs: [friendship['receiver_id'], friendship['sender_id']],
    );

    if (friendRequestsSenderRejected.isNotEmpty ||
        friendRequestsReceiver.isNotEmpty) {
      print('Friend Request already exists, not inserted');
    } else if (friendRequestsSender.isEmpty) {
      await db.insert('friend_requests', friendship);
      print('Friend Request Inserted');
    } else {
      await db.update(
        'friend_requests',
        {'status': 'pending'},
        where: '(sender_id = ? AND receiver_id = ?)',
        whereArgs: [friendship['sender_id'], friendship['receiver_id']],
      );
      print('Friend Request Updated to Pending');
    }
  }

  Future<void> rejectFriendRequest(Map<String, dynamic> friendship) async {
    final db = await database;
    // Update the friend request status to rejected
    await db.update(
      'friend_requests',
      {'status': 'rejected'},
      where: '(sender_id = ? AND receiver_id = ?)',
      whereArgs: [friendship['sender_id'], friendship['receiver_id']],
    );
    print('Friend Request Updated to Rejected');
  }

  Future<void> acceptFriendRequest(Map<String, dynamic> friendship) async {
    final db = await database;
    // Update the friend request status to rejected
    await db.update(
      'friend_requests',
      {'status': 'accepted'},
      where: '(sender_id = ? AND receiver_id = ?)',
      whereArgs: [friendship['sender_id'], friendship['receiver_id']],
    );
    print('Friend Request Updated to Accepted');
  }

  Future<int> getMutualFriendsCount(int userId1, int userId2) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM friends f1
      JOIN friends f2 ON (f1.user1_id = f2.user1_id AND f1.user2_id = ? AND f2.user2_id = ?)
      OR (f1.user1_id = f2.user2_id AND f1.user2_id = ? AND f2.user1_id = ?)
      OR (f1.user2_id = f2.user1_id AND f1.user1_id = ? AND f2.user2_id = ?)
      OR (f1.user2_id = f2.user2_id AND f1.user1_id = ? AND f2.user1_id = ?)
      WHERE f1.user1_id <> f1.user2_id AND f2.user1_id <> f2.user2_id
      ''', [
      userId1,
      userId2,
      userId2,
      userId1,
      userId1,
      userId2,
      userId2,
      userId1
    ]);
    return (result.first['count'] as int?) ?? 0;
  }

////////////////////////// LOCATIONS //////////////////////////////////

  Future<int> insertLocation(
    int userId,
    String startLat,
    String startLon,
    String endLat,
    String endLon,
    String status,
    
  ) async {
    final db = await database;
    Map<String, dynamic> row = {
      'userid': userId,
      'start_lat': startLat,
      'start_lon': startLon,
      'end_lat': endLat,
      'end_lon': endLon,
      'status': status, // Removed the semicolon and replaced it with a comma
    };

    return await db.insert('locations', row);
    
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await database;
    return db.query('locations', where: 'status = ?', whereArgs: ['0']);
  }

  Future<void> printStartLocations() async {
    List<Map<String, dynamic>> locations = await getLocations();
    for (var location in locations) {
      print(location['start']);
    }
  }

  Future<void> updatePassengerPoints(int userId, int points) async {
    final db = await initDatabase();
    var res = await db.query(
      'users',
      columns: ['points'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (res.isNotEmpty) {
      int currentPoints = res.first['points'] as int;
      int newPoints = currentPoints - points;
      if (newPoints >= 0) {
        await db.update(
          'users',
          {'points': newPoints},
          where: 'id = ?',
          whereArgs: [userId],
        );
        print('Updated points for user $userId');
      } else {
        print('Insufficient points for user $userId');
      }
    } else {
      print('User not found');
    }
  }

  Future<void> updateDriverPoints(int userId, int points) async {
    final db = await initDatabase();
    var res = await db.query(
      'users',
      columns: ['points'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (res.isNotEmpty) {
      int currentPoints = res.first['points'] as int;
      int newPoints = currentPoints + points;
      await db.update(
        'users',
        {'points': newPoints},
        where: 'id = ?',
        whereArgs: [userId],
      );
      print('Updated points for user $userId');
    } else {
      print('User not found');
    }
  }

  Future<void> updateLocationStatus(int locationId) async {
    final db = await database; // Get the database instance
    await db.update(
      'locations',
      {'status': '1'},
      where: 'id = ?',
      whereArgs: [locationId],
    );
    print('Updated status for location $locationId');
  }

  Future<Map<String, dynamic>?> getLocationById(int id) async {
    final db =
        await database; // Assuming 'database' is a Future<Database> instance
    List<Map<String, dynamic>> maps = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first; // Return the first (and presumably only) entry
    }
    return null; // Return null if no location is found
  }

  Future<String> getLocationStatus(String locationId) async {
    final db = await database; // Assuming this gets your database instance
    final List<Map<String, dynamic>> maps = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: [locationId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['status'].toString();
    } else {
      return 'Not Found';
    }
  }

  Future<List<Map<String, dynamic>>> getLocationsOfUsers() async {
    final db = await database;
    String query = '''
      SELECT 
      users.* ,
      locations.* 
      FROM users
      INNER JOIN locations ON users.id = locations.userid
      WHERE locations.status = '0'
    ''';
    var result = await db.rawQuery(query);
    return result;
  }

  Future<List<Map<String, dynamic>>> getLocationsClose(LatLng addressEnd, double rangeInKm) async {
    final db = await database;

    double lat = addressEnd.latitude;
    double lon = addressEnd.longitude;

    double rangeInDegreesLat = rangeInKm / 111.0;  // Roughly 111 kilometers per degree of latitude

    // For longitude, the distance varies based on the latitude.
    // double rangeInDegreesLon = rangeInKm / (111.0 * cos(lat * pi / 180));

    double latLower = lat - rangeInDegreesLat;
    double latUpper = lat + rangeInDegreesLat;
    double lonLower = lon - rangeInDegreesLat;
    double lonUpper = lon + rangeInDegreesLat;

    String latLowerStr = latLower.toString();
    String latUpperStr = latUpper.toString();
    String lonLowerStr = lonLower.toString();
    String lonUpperStr = lonUpper.toString();

    List<Map<String, dynamic>> results = await db.query('locations', 
      where: 'start_lat BETWEEN ? AND ? AND start_lon BETWEEN ? AND ?',
       whereArgs: [latLowerStr, latUpperStr, lonLowerStr, lonUpperStr]
    );

    return results;
  }




  
  Future<List<Map<String, dynamic>>> getCloseUsersWithLocations(LatLng addressEnd, double rangeInKm) async {
  final db = await database;

  // Calculate the latitude and longitude range
  double lat = addressEnd.latitude;
  double lon = addressEnd.longitude;
  double rangeInDegreesLat = rangeInKm / 111.0;

  double latLower = lat - rangeInDegreesLat;
  double latUpper = lat + rangeInDegreesLat;
  double lonLower = lon - rangeInDegreesLat;
  double lonUpper = lon + rangeInDegreesLat;

  String latLowerStr = latLower.toString();
  String latUpperStr = latUpper.toString();
  String lonLowerStr = lonLower.toString();
  String lonUpperStr = lonUpper.toString();

  // SQL query to get users with their locations that are close to the given addressEnd
  String query = '''
    SELECT 
      users.*,
      locations.* 
    FROM users
    INNER JOIN locations ON users.id = locations.userid
    WHERE locations.status = '0'
      AND locations.start_lat BETWEEN ? AND ?
      AND locations.start_lon BETWEEN ? AND ?
  ''';

  List<Map<String, dynamic>> results = await db.rawQuery(query, 
    [latLowerStr, latUpperStr, lonLowerStr, lonUpperStr]
  );

  return results;
}





}
