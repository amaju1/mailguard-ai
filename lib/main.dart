import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ScamDetectorApp());
}

class ScamDetectorApp extends StatelessWidget {
  const ScamDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MailGuard AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2457E6),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController emailController =
      TextEditingController();

  String? result;
String explanation = '';
bool isAnalyzing = false;

int riskScore = 0;
List<String> indicators = [];
String recommendation = '';

  Future<void> analyzeEmail() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter an email first.'),
      ),
    );
    return;
  }

  setState(() {
    isAnalyzing = true;
    result = null;
  });

  try {
    final response = await http.post(
      Uri.parse('https://phoniness-vigorous-sighing.ngrok-free.dev/analyse'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prediction = data['prediction'];
      final confidence = (data['confidence'] as num).toDouble();

      setState(() {
  result = prediction == 'Insufficient information'
      ? 'Insufficient information'
      : prediction == 'Phishing/Spam'
          ? 'Likely phishing'
          : 'Legitimate email';
        riskScore = prediction == 'Insufficient information'
    ? 0
    : prediction == 'Phishing/Spam'
        ? confidence.round()
        : (100 - confidence).round();

        indicators = [];

        explanation =
            'Your trained machine-learning model classified this email as $prediction with ${confidence.toStringAsFixed(1)}% confidence.';

        recommendation = prediction == 'Phishing/Spam'
            ? 'Do not click links, download attachments, or share personal information. Verify the sender independently.'
            : 'The model classified this email as legitimate. However, always verify unexpected requests and suspicious links.';

        isAnalyzing = false;
      });
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection error: $e'),
      ),
    );
  }
}
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2457E6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MailGuard AI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Intelligent Email Security',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 38),

              const Text(
                'Stay one step ahead\nof email scams.',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Analyse suspicious emails and identify '
                'potential phishing attempts using AI.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Email input card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Color(0xFF2457E6),
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Email Analysis',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Paste your email content below',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: emailController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText:
                            'Paste the suspicious email here...',
                        hintStyle: const TextStyle(
                          color: Colors.black38,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed:
                            isAnalyzing ? null : analyzeEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2457E6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: isAnalyzing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.security),
                                  SizedBox(width: 10),
                                  Text(
                                    'Analyse Email',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Results
             if (result != null)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SECURITY ANALYSIS',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          result!,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: result == 'Likely phishing'
                ? Colors.red
                : result == 'Suspicious email'
                    ? Colors.orange
                    : Colors.green,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estimated risk score',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '$riskScore/100',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: riskScore / 100,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            color: riskScore >= 60
                ? Colors.red
                : riskScore >= 30
                    ? Colors.orange
                    : Colors.green,
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Analysis explanation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          explanation,
          style: const TextStyle(
            color: Colors.black54,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Detected indicators',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        if (indicators.isEmpty)
          const Text(
            'No selected warning keywords found.',
            style: TextStyle(color: Colors.green),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: indicators.map((word) {
              return Chip(
                label: Text(word),
                backgroundColor: Colors.red.shade50,
                labelStyle: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        const Text(
          'Security recommendation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          recommendation,
          style: const TextStyle(
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    ),
  ),
              const SizedBox(height: 25),

              const Text(
                'Your Security Matters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              const FeatureTile(
                icon: Icons.phishing_outlined,
                title: 'Phishing Detection',
                subtitle: 'Identify suspicious email content.',
              ),

              const FeatureTile(
                icon: Icons.lock_outline,
                title: 'Privacy Focused',
                subtitle: 'Designed with email security in mind.',
              ),

              const FeatureTile(
                icon: Icons.analytics_outlined,
                title: 'Smart Analysis',
                subtitle: 'Understand potential email threats.',
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'MAILGUARD AI  •  EMAIL SECURITY',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2457E6),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}