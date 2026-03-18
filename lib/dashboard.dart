import 'package:flutter/material.dart';
import 'health_monitoring_page.dart';
import 'security_page.dart';
import 'garden_page.dart';
import 'ai_assistant_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CareLoop Dashboard"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                const SizedBox(height: 10),

                const Text(
                  "Smart Elder Care System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 30),

                buildDashboardCard(
                  context: context,
                  title: "Health Monitoring",
                  subtitle: "Live Temperature, Motion & Emergency",
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  screen: const HealthMonitoringPage(),
                ),

                buildDashboardCard(
                  context: context,
                  title: "Home Security",
                  subtitle: "RFID Access & Intrusion Detection",
                  icon: Icons.security,
                  color: Colors.blueAccent,
                  screen: const SecurityPage(),
                ),

                buildDashboardCard(
                  context: context,
                  title: "Garden Automation",
                  subtitle: "Soil Moisture & LDR Light Control",
                  icon: Icons.eco,
                  color: Colors.green,
                  screen: const GardenPage(),
                ),

                buildDashboardCard(
                  context: context,
                  title: "AI Assistant",
                  subtitle: "Smart Suggestions & Voice Help",
                  icon: Icons.smart_toy,
                  color: Colors.purple,
                  screen: const AIPage(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDashboardCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [

              CircleAvatar(
                backgroundColor: color,
                radius: 28,
                child: Icon(icon, color: Colors.white, size: 28),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}