import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AgeCalculatorApp());
}

class AgeCalculatorApp extends StatefulWidget {
  const AgeCalculatorApp({super.key});

  @override
  State<AgeCalculatorApp> createState() => _AgeCalculatorAppState();
}

class _AgeCalculatorAppState extends State<AgeCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: AgeHomePage(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class AgeHomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const AgeHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AgeHomePage> createState() => _AgeHomePageState();
}

class _AgeHomePageState extends State<AgeHomePage> {
  DateTime? _selectedDate;
  String? _ageDetails;
  int? _daysUntilBirthday;

  void _showCupertinoDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Text(
                'Select Birthdate',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate ?? DateTime(2000),
                  maximumDate: DateTime.now(),
                  minimumYear: 1900,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _selectedDate = value;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculateAge() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your birthdate.")),
      );
      return;
    }

    final today = DateTime.now();
    final birthDate = _selectedDate!;

    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    DateTime nextBirthday = DateTime(today.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, birthDate.month, birthDate.day);
    }

    final daysLeft = nextBirthday.difference(today).inDays;

    setState(() {
      _ageDetails = '$years Years, $months Months, $days Days';
      _daysUntilBirthday = daysLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Age Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About App',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Age Calculator',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.cake),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Developed with ❤️ by Bhanu Pratap Singh.\n\n'
                          'This app calculates your age and how many days are left until your next birthday 🎉',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeToggle,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.05),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select your birthdate:', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _showCupertinoDatePicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  _selectedDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                      : 'Tap to select date',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _calculateAge,
                                icon: const Icon(Icons.calculate),
                                label: const Text("Calculate Age"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_ageDetails != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.05),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("🎂 Your Age", style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 10),
                              Text(
                                _ageDetails!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "🎉 $_daysUntilBirthday days left for your next birthday!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
