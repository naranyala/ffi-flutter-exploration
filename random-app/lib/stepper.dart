import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CustomStepper(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class CustomStepper extends StatefulWidget {
  const CustomStepper({super.key});

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int currentStep = 0;
  final PageController pageController = PageController();

  final List<String> stepTitles = [
    'Welcome',
    'Profile',
    'Complete'
  ];

  void goToStep(int step) {
    setState(() {
      currentStep = step;
    });
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  // Step Indicators
                  Row(
                    children: List.generate(stepTitles.length, (index) {
                      bool isActive = index <= currentStep;
                      bool isCurrent = index == currentStep;

                      return Expanded(
                        child: Row(
                          children: [
                            // Circle
                            GestureDetector(
                              onTap: () => goToStep(index),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive ? Colors.blue : Colors.grey[300],
                                  border: isCurrent
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : null,
                                ),
                                child: Center(
                                  child: isActive && index < currentStep
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isActive ? Colors.white : Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            // Line
                            if (index < stepTitles.length - 1)
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: index < currentStep ? Colors.blue : Colors.grey[300],
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  // Step Labels
                  Row(
                    children: stepTitles.asMap().entries.map((entry) {
                      int index = entry.key;
                      String title = entry.value;
                      bool isActive = index <= currentStep;

                      return Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentStep = index;
                  });
                },
                children: [
                  // Step 1
                  _buildStepContent(
                    icon: Icons.waving_hand,
                    title: 'Welcome!',
                    subtitle: 'Let\'s get started with your journey',
                    content: const Column(
                      children: [
                        Icon(Icons.rocket_launch, size: 80, color: Colors.blue),
                        SizedBox(height: 20),
                        Text(
                          'Ready to begin?',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  // Step 2
                  _buildStepContent(
                    icon: Icons.person,
                    title: 'Your Profile',
                    subtitle: 'Tell us about yourself',
                    content: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text('Email: user@example.com'),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text('Phone: +1234567890'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 3
                  _buildStepContent(
                    icon: Icons.check_circle,
                    title: 'All Done!',
                    subtitle: 'You\'ve completed the setup',
                    content: const Column(
                      children: [
                        Icon(Icons.celebration, size: 80, color: Colors.green),
                        SizedBox(height: 20),
                        Text(
                          'Congratulations!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Setup completed successfully',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => goToStep(currentStep - 1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),

                  if (currentStep > 0) const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentStep < stepTitles.length - 1
                          ? () => goToStep(currentStep + 1)
                          : () {
                              // Handle completion
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Setup completed!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        currentStep < stepTitles.length - 1 ? 'Next' : 'Finish',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          content,
        ],
      ),
    );
  }
}
