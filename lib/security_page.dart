import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dbRef =
        FirebaseDatabase.instance.ref("security");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Security"),
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
                child: Text("No Security Data Found"));
          }

          final data = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          String door =
              data["door"]?.toString() ?? "--";

          String intrusion =
              data["intrusion"]?.toString() ?? "--";

          String rfid =
              data["rfid"]?.toString() ?? "--";

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                securityCard(
                  "Door Status",
                  door,
                  Icons.lock,
                  door == "Locked"
                      ? Colors.red
                      : Colors.green,
                ),

                securityCard(
                  "Intrusion",
                  intrusion,
                  Icons.warning,
                  intrusion == "Detected"
                      ? Colors.red
                      : Colors.green,
                ),

                securityCard(
                  "RFID Access",
                  rfid,
                  Icons.badge,
                  Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget securityCard(
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