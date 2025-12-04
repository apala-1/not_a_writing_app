import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/pencil.png",
      "title": "Write Freely",
      "subtitle": "Share your thoughts without needing to write a full book."
    },
    {
      "image": "assets/pencil.png",
      "title": "Connect Creatively",
      "subtitle": "Read small ideas, stories and writings from others."
    },
    {
      "image": "assets/pencil.png",
      "title": "Start Your Journey",
      "subtitle": "Write anything, anytime — without pressure."
    },
  ];

  void next() {
    if (_currentIndex < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            // Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          onboardingData[index]["image"]!,
                          height: 280,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          onboardingData[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          onboardingData[index]["subtitle"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.orange
                        : Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // NEXT / GET STARTED BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: next,
                child: Text(
                  _currentIndex == 2 ? "Get Started" : "Next",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
