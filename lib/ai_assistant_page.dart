import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> messages = [];
  bool isLoading = false;

  // 🔐 ADD YOUR API KEY HERE (ONE LINE ONLY)
  final String apiKey = "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";

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  void initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(settings);

    // 🚫 Removed requestPermission() because it crashes on Chrome
  }

  Future<void> showAlert(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'careloop_channel',
      'CareLoop Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(0, title, body, details);
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();
    String lowerMessage = userMessage.toLowerCase();

    setState(() {
      messages.add({"role": "user", "text": userMessage});
      isLoading = true;
    });

    _controller.clear();
    scrollToBottom();

    try {

      // 🌙 Auto lock door at night
      int hour = DateTime.now().hour;
      if (hour >= 22 || hour <= 5) {
        await FirebaseDatabase.instance
            .ref("security")
            .update({"door": "Locked"});
      }

      // ================= DEVICE CONTROL =================

      if (lowerMessage.contains("turn on garden light")) {
        await FirebaseDatabase.instance.ref("garden").update({"light": "ON"});
        addAIMessage("🌱 Garden light turned ON");
        return;
      }

      if (lowerMessage.contains("turn off garden light")) {
        await FirebaseDatabase.instance.ref("garden").update({"light": "OFF"});
        addAIMessage("🌱 Garden light turned OFF");
        return;
      }

      if (lowerMessage.contains("lock door")) {
        await FirebaseDatabase.instance.ref("security").update({"door": "Locked"});
        addAIMessage("🔒 Door Locked");
        return;
      }

      if (lowerMessage.contains("unlock door")) {
        await FirebaseDatabase.instance.ref("security").update({"door": "Unlocked"});
        addAIMessage("🔓 Door Unlocked");
        return;
      }

      // ================= SMART HEALTH CHECK =================

      if (lowerMessage.contains("parent") ||
          lowerMessage.contains("health") ||
          lowerMessage.contains("okay")) {

        final snapshot =
            await FirebaseDatabase.instance.ref("health").get();

        if (!snapshot.exists) {
          addAIMessage("⚠️ No health data available.");
          return;
        }

        final data = Map<String, dynamic>.from(snapshot.value as Map);

        String motion = data["motion"]?.toString() ?? "No";
        String temperature = data["temperature"]?.toString() ?? "0";
        String emergency = data["emergency"]?.toString() ?? "No";
        String fall = data["fall"]?.toString() ?? "No";

        double tempValue = double.tryParse(temperature) ?? 0;

        int riskScore = 0;

        if (emergency == "Yes") riskScore += 50;
        if (fall == "Yes") riskScore += 40;
        if (motion == "No") riskScore += 20;
        if (tempValue > 38 || tempValue < 34) riskScore += 20;

        if (riskScore >= 50) {
          await showAlert("🚨 High Risk", "Immediate attention required!");
          addAIMessage("🚨 HIGH RISK detected! Immediate attention required!");
          return;
        }

        if (riskScore >= 20) {
          addAIMessage("⚠️ Moderate risk detected. Please check on them.");
          return;
        }

        addAIMessage("✅ Everything looks normal. Motion and vitals are stable.");
        return;
      }

      // ================= NORMAL AI CHAT =================

      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
          "HTTP-Referer": "http://localhost",
          "X-Title": "CareLoop App",
        },
        body: jsonEncode({
          "model": "mistralai/mistral-7b-instruct",
          "messages": [
            {"role": "user", "content": userMessage}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes));

        String aiReply =
            decoded["choices"][0]["message"]["content"]
                .toString()
                .trim();

        addAIMessage(aiReply);
      } else {
        addAIMessage("Error: ${response.statusCode}");
      }

    } catch (e) {
      addAIMessage("Connection Error");
    }
  }

  void addAIMessage(String text) {
    setState(() {
      messages.add({"role": "ai", "text": text});
      isLoading = false;
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CareLoop AI Assistant"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {

                final message = messages[index];
                final isUser = message["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(
                              colors: [Colors.teal, Colors.green])
                          : const LinearGradient(
                              colors: [Colors.white, Colors.grey]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message["text"] ?? "",
                      style: TextStyle(
                        color:
                            isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}