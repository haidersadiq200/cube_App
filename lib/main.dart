import 'package:flutter/material.dart';
import 'dart:async';
import 'db_helper.dart';
import 'notification_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CubeTracker(),
    );
  }
}

class Cube {
  int id;
  DateTime castingDate;
  DateTime inspectionDate;
  DateTime immersionDate;
  String labCode;
  String imagePath;
  
  Cube(this.id, this.castingDate, this.inspectionDate, this.immersionDate, this.labCode, this.imagePath);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'castingDate': castingDate.toIso8601String(),
      'inspectionDate': inspectionDate.toIso8601String(),
      'immersionDate': immersionDate.toIso8601String(),
      'labCode': labCode,
      'imagePath': imagePath,
    };
  }
}

class CubeTracker extends StatefulWidget {
  @override
  _CubeTrackerState createState() => _CubeTrackerState();
}

class _CubeTrackerState extends State<CubeTracker> {
  List<Cube> cubes = [];
  DBHelper dbHelper = DBHelper();
  // NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    loadCubes();
    Timer.periodic(Duration(hours: 24), (Timer t) => checkNotifications());
  }

  void loadCubes() async {
    List<Map<String, dynamic>> cubeMaps = await dbHelper.getCubes();
    setState(() {
      cubes = cubeMaps.map((cubeMap) => Cube(
        cubeMap['id'],
        DateTime.parse(cubeMap['castingDate']),
        DateTime.parse(cubeMap['inspectionDate']),
        DateTime.parse(cubeMap['immersionDate']),
        cubeMap['labCode'],
        cubeMap['imagePath'],
      )).toList();
    });
  }

  void checkNotifications() {
    DateTime now = DateTime.now();
    for (Cube cube in cubes) {
      for (int days in [3, 7, 28, 56]) {
        DateTime notificationDate = cube.castingDate.add(Duration(days: days));
        if (now.isAfter(notificationDate.subtract(Duration(days: 1))) && now.isBefore(notificationDate)) {
          sendNotification(cube.id, "${days}-day-before");
        } else if (now.isAfter(notificationDate) && now.isBefore(notificationDate.add(Duration(days: 1)))) {
          sendNotification(cube.id, "${days}-day");
        }
      }
    }
  }

  void sendNotification(int cubeId, String notificationType) {
    String title = 'Reminder for Cube ID: $cubeId';
    String body = 'It\'s time for your $notificationType notification';
    // notificationService.showNotification(cubeId, title, body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cube Tracker'),
      ),
      body: ListView.builder(
        itemCount: cubes.length,
        itemBuilder: (context, index) {
          Cube cube = cubes[index];
          return ListTile(
            title: Text('Cube ID: ${cube.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Casting Date: ${cube.castingDate}'),
                Text('Lab Code: ${cube.labCode}'),
                Image.asset(cube.imagePath)  // عرض الصورة
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  dbHelper.deleteCube(cube.id);
                  cubes.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // أضف منطق لإضافة مكعب جديد (قد تستخدم Dialog أو صفحة جديدة)
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DBHelper {
  void deleteCube(int id) {}
  
  getCubes() {}
}
