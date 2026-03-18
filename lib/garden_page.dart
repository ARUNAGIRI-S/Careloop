import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  @override
  Widget build(BuildContext context) {

    final dbRef =
        FirebaseDatabase.instance.ref("garden");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Garden Automation"),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.onValue,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.data!.snapshot.exists) {
            return const Center(
                child: Text("No Garden Data Found"));
          }

          final data = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          String soil =
              data["soil"]?.toString() ?? "--";

          String light =
              data["light"]?.toString() ?? "--";

          int soilValue =
              int.tryParse(soil) ?? 0;

          Color soilColor =
              soilValue < 30
                  ? Colors.red
                  : soilValue < 60
                      ? Colors.orange
                      : Colors.green;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                gardenCard(
                  "Soil Moisture",
                  "$soil %",
                  Icons.water_drop,
                  soilColor,
                ),

                gardenCard(
                  "Garden Light",
                  light,
                  Icons.lightbulb,
                  light == "ON"
                      ? Colors.green
                      : Colors.grey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget gardenCard(
      String title,
      String value,
      IconData icon,
      Color color) {

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading:
            Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style:
              const TextStyle(fontSize: 18),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}