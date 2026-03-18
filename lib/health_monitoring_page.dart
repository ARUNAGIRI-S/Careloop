import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HealthMonitoringPage extends StatefulWidget {
  const HealthMonitoringPage({Key? key}) : super(key: key);

  @override
  State<HealthMonitoringPage> createState() =>
      _HealthMonitoringPageState();
}

class _HealthMonitoringPageState
    extends State<HealthMonitoringPage> {

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("health");

  String temperature = "--";
  String motion = "No";
  String emergency = "No";

  @override
  void initState() {
    super.initState();

    dbRef.onValue.listen((event) {
      final data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          temperature =
              data["temperature"]?.toString() ?? "--";
          motion =
              data["motion"]?.toString() ?? "No";
          emergency =
              data["emergency"]?.toString() ?? "No";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Monitoring"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            buildCard(
              "Temperature",
              "$temperature °C",
              Icons.thermostat,
              Colors.orange,
            ),

            buildCard(
              "Motion",
              motion,
              Icons.directions_walk,
              Colors.blue,
            ),

            buildCard(
              "Emergency",
              emergency,
              Icons.warning,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(
      String title,
      String value,
      IconData icon,
      Color color) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 28,
          child: Icon(icon,
              color: Colors.white, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}