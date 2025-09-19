import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = 'YOUR_API_KEY';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with TickerProviderStateMixin {
  String currentQuote = "";
  String currentAuthor = "";
  bool isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _loadRandomQuote();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _fetchQuoteFromAPI() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/quotes'),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: ${response.body}');

        if (data is List && data.isNotEmpty) {
          final quoteData = data[0];
          return {
            'quote': quoteData['quote'] ?? 'No quote available',
            'author': quoteData['author'] ?? 'Unknown',
          };
        }
      } else {
        debugPrint('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
    }

    final fallbackQuotes = [
      {
        'quote': 'The only way to do great work is to love what you do.',
        'author': 'Steve Jobs',
      },
      {
        'quote': 'Innovation distinguishes between a leader and a follower.',
        'author': 'Steve Jobs',
      },
      {
        'quote':
            'Life is what happens to you while you\'re busy making other plans.',
        'author': 'John Lennon',
      },
      {
        'quote':
            'The future belongs to those who believe in the beauty of their dreams.',
        'author': 'Eleanor Roosevelt',
      },
      {
        'quote':
            'It is during our darkest moments that we must focus to see the light.',
        'author': 'Aristotle',
      },
    ];

    final randomQuote =
        fallbackQuotes[DateTime.now().millisecondsSinceEpoch %
            fallbackQuotes.length];
    return randomQuote;
  }

  Future<void> _loadRandomQuote() async {
    setState(() {
      isLoading = true;
    });

    _fadeController.reset();

    try {
      final quote = await _fetchQuoteFromAPI();
      setState(() {
        currentQuote = quote['quote']!;
        currentAuthor = quote['author']!;
        isLoading = false;
      });

      _fadeController.forward();
      _scaleController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        currentQuote = "Something went wrong. Please try again.";
        currentAuthor = "Error";
      });
    }
  }

  void _onNewQuotePressed() {
    HapticFeedback.lightImpact();
    _scaleController.reset();
    _loadRandomQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 184, 168, 227),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Daily Inspiration',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 15, 21, 28),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Discover wisdom in every word',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color.fromARGB(255, 6, 8, 8),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2C3E50,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                if (isLoading)
                                  const Column(
                                    children: [
                                      CircularProgressIndicator(
                                        color: Color.fromARGB(
                                          255,
                                          184,
                                          161,
                                          56,
                                        ),
                                        strokeWidth: 2,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Loading inspiration...',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            22,
                                            53,
                                            75,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      Text(
                                        currentQuote,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              height: 1.5,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 1,
                                            color: const Color(0xFF3498DB),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            currentAuthor,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFF3498DB,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(width: 16),
                                          Container(
                                            width: 40,
                                            height: 1,
                                            color: const Color(0xFF3498DB),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const Spacer(),
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _onNewQuotePressed,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Quote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 22, 53, 75),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
