import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/gemini_service.dart';
import '../services/rewards_service.dart';
import '../services/wallet_service.dart';
import '../services/balance_service.dart';
import '../services/sdg_impact_service.dart';
import '../models/loyalty_rank.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;
import '../screens/profile_page.dart'; // Import ProfileData class

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  Message({
    required this.text, 
    required this.isUser,
    required this.timestamp,
  });
}

class TransitAssistantPage extends StatefulWidget {
  const TransitAssistantPage({super.key});

  @override
  State<TransitAssistantPage> createState() => _TransitAssistantPageState();
}

class _TransitAssistantPageState extends State<TransitAssistantPage> {
  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _isListening = false;
  late GeminiService _geminiService;
  bool _useGemini = true;
  String _errorMessage = '';
  late stt.SpeechToText _speechToText;
  bool _speechAvailable = true;
  
  // List of predefined responses for the demo (fallback if Gemini is not available)
  final Map<String, String> _mockResponses = {
    'route': 'To get from KL Sentral to Mid Valley, take the KTM Komuter train (Port Klang Line) from KL Sentral to Mid Valley station. It takes about 6 minutes and costs RM1.30. Trains depart every 15-30 minutes.',
    'points': 'You currently have 2,450 points. You\'re 1,550 points away from reaching Gold level! Keep using public transit to earn more points.',
    'schedule': 'The next train from KL Sentral to Mid Valley departs at 3:45 PM. After that, trains depart at 4:15 PM and 4:45 PM.',
    'weather': 'It\'s currently 32°C and partly cloudy in Kuala Lumpur. There\'s a 20% chance of rain later this afternoon.',
    'traffic': 'Current traffic conditions from KL Sentral to Mid Valley show light congestion. Estimated travel time by car is 15 minutes.',
    'rewards': 'With your current 2,450 points, you can redeem a free coffee at Starbucks (1,500 points), a RM5 Grab voucher (2,000 points), or save up for a RM10 transit credit (3,000 points).',
    'sdg': 'By using public transportation, you\'ve contributed to SDG 11 (Sustainable Cities) and SDG 13 (Climate Action). Your transit choices have saved approximately 28.5 kg of CO2 emissions this month!',
    'station': 'KL Sentral is the main transit hub in Kuala Lumpur. It connects multiple rail lines including KTM Komuter, KLIA Express, KLIA Transit, LRT, and MRT. You can find ticket counters on Level 1 and food options on Level 2.',
    'help': 'I can help you with:\n• Finding routes between locations\n• Checking schedules and fares\n• Showing your rewards points\n• Providing transit updates\n• Offering trip planning advice\n• Explaining your environmental impact\n\nJust ask me anything about transit in natural language!',
    'fallback': 'I understand your question is about transit services. While I\'m a demo version and can\'t provide real-time data, in the full version I\'d connect to the transit API to give you accurate information. Is there something specific about transit routes, schedules, or rewards I can help with?'
  };

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _initSpeechRecognition();
    // Add welcome message
    _addBotMessage('Hello! I\'m your Transit Assistant, powered by Google\'s Gemini AI. I can help with route planning, schedules, points balance, and travel tips. How can I assist you today?');
  }
  
  Future<void> _initializeGemini() async {
    _geminiService = Provider.of<GeminiService>(context, listen: false);
    try {
      await _geminiService.initialize();
      setState(() {
        _useGemini = true;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _useGemini = false;
        _errorMessage = e.toString();
        debugPrint('Failed to initialize Gemini: $e');
      });
      
      // Show error message if Gemini failed to initialize
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing Gemini AI: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  Future<void> _initSpeechRecognition() async {
    _speechToText = stt.SpeechToText();
    try {
      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: (error) => print('Speech recognition error: $error'),
      );
      if (!available) {
        debugPrint('Speech recognition not available on this device');
      }
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      // Set flag to disable speech recognition
      setState(() {
        _speechAvailable = false;
      });
    }
  }
  
  void _onSpeechStatus(String status) {
    debugPrint('Speech recognition status: $status');
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
    }
  }
  
  void _addBotMessage(String message) {
    setState(() {
      _messages.add(Message(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _formatGeminiResponse(String response) {
    // Process the response to handle markdown-style formatting
    
    // Replace lines starting with * with bullet points •
    final bulletPattern = RegExp(r'^\s*\*\s*(.*?)$', multiLine: true);
    response = response.replaceAllMapped(bulletPattern, (match) {
      return '• ${match.group(1)}';
    });
    
    return response;
  }
  
  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;
    
    final userMessage = _textController.text;
    
    // Add user message
    setState(() {
      _messages.add(Message(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _textController.clear();
      _isTyping = true;
    });
    
    try {
      String botResponse;
      
      if (_useGemini) {
        // Get data from various services
        final rewardsService = Provider.of<RewardsService>(context, listen: false);
        Provider.of<WalletService>(context, listen: false);
        final balanceService = Provider.of<BalanceService>(context, listen: false);
        final sdgImpactService = Provider.of<SdgImpactService>(context, listen: false);
        
        // Prepare context data
        final int currentPoints = rewardsService.points;
        final LoyaltyRank currentRank = rewardsService.currentRank;
        final LoyaltyRank? nextRank = rewardsService.nextRank;
        final int pointsToNextLevel = nextRank != null ? nextRank.creditsRequired - currentPoints : 0;
        final String currentLevelName = currentRank.name;
        final String nextLevelName = nextRank?.name ?? "Maximum Level";
        final double creditBalance = balanceService.balance;
        final double carbonSaved = sdgImpactService.impact.co2Saved;
        
        // Get available rewards (mock data since the actual method isn't available)
        final List<Map<String, dynamic>> availableRewards = [
          {'name': 'Free Coffee', 'points': 1500, 'description': 'Redeem for a free coffee at partner cafes'},
          {'name': 'RM5 Grab Voucher', 'points': 2000, 'description': 'Discount on your next Grab ride'},
          {'name': 'RM10 Transit Credit', 'points': 3000, 'description': 'Add RM10 to your transit wallet'},
          {'name': 'Movie Ticket', 'points': 5000, 'description': 'One free movie ticket at selected theaters'},
        ];
        
        // Get recent transactions
        final List<Transaction> recentTransactions = balanceService.transactions.take(5).toList();
        final List<Map<String, String>> recentTrips = recentTransactions
            .where((transaction) => transaction.isDebit)
            .map((trip) => {
                'date': '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                'title': trip.title,
                'amount': trip.amount.toString(),
                'type': trip.iconType.toString(),
              }).toList();
        
        // Format a prompt that includes context about being a transit assistant
        final String prompt = """
You are a transit assistant for public transportation in Malaysia. Your goal is to help users with transit-related questions.
You should provide helpful, accurate information about transportation routes, schedules, fares, and services.

The user's current information:
- Current points: $currentPoints points
- Current level: $currentLevelName
- Points needed for next level ($nextLevelName): $pointsToNextLevel more points
- Current wallet balance: RM$creditBalance
- Carbon emissions saved this month: ${carbonSaved.toStringAsFixed(2)} kg

Available rewards:
${availableRewards.map((r) => "* ${r['name']} (${r['points']} points): ${r['description']}").join('\n')}

Recent transactions:
${recentTrips.map((t) => "* ${t['date']}: ${t['title']} - RM${t['amount']}").join('\n')}

If asked about SDG impact, explain how using public transport contributes to Sustainable Development Goals, with the user's carbon savings of ${carbonSaved.toStringAsFixed(2)} kg this month.

Use **double asterisks** to emphasize important information, which will be displayed in bold.
Use * at the beginning of a line to create bullet points in your response.

User query: $userMessage
""";
        
        // Send message to Gemini
        String rawResponse = await _geminiService.sendMessage(prompt);
        
        // Format the response to handle markdown-style formatting
        botResponse = _formatGeminiResponse(rawResponse);
      } else {
        // Fallback to mock responses
        String rawResponse = _getMockResponse(userMessage.toLowerCase());
        botResponse = _formatGeminiResponse(rawResponse);
      }
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(Message(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(Message(
            text: "I'm sorry, I encountered an error. Please try again later.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Generate a mock response based on message keywords (used as fallback)
  String _getMockResponse(String message) {
    if (message.contains('route') || message.contains('go to') || message.contains('get to') || 
        message.contains('from') || message.contains('to ')) {
      return _mockResponses['route']!;
    } 
    else if (message.contains('point') || message.contains('reward') || message.contains('balance')) {
      return _mockResponses['points']!;
    }
    else if (message.contains('schedule') || message.contains('time') || message.contains('next train') || 
             message.contains('when') || message.contains('depart')) {
      return _mockResponses['schedule']!;
    }
    else if (message.contains('weather') || message.contains('rain') || message.contains('temperature')) {
      return _mockResponses['weather']!;
    }
    else if (message.contains('traffic') || message.contains('jam') || message.contains('congestion')) {
      return _mockResponses['traffic']!;
    }
    else if (message.contains('redeem') || message.contains('spend') || message.contains('what can i get')) {
      return _mockResponses['rewards']!;
    }
    else if (message.contains('sdg') || message.contains('environment') || message.contains('carbon') ||
             message.contains('emission') || message.contains('sustainable')) {
      return _mockResponses['sdg']!;
    }
    else if (message.contains('station') || message.contains('terminal') || message.contains('kl sentral')) {
      return _mockResponses['station']!;
    }
    else if (message.contains('help') || message.contains('what can you do') || message.contains('assist')) {
      return _mockResponses['help']!;
    }
    else {
      return _mockResponses['fallback']!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Transit Assistant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            // Google Agentspace banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.smart_toy_outlined, color: primaryColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Powered by Google Gemini',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _useGemini ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _useGemini ? Colors.green.shade300 : Colors.orange.shade300, 
                        width: 1
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _useGemini ? Icons.circle : Icons.warning_amber_rounded, 
                          size: 8, 
                          color: _useGemini ? Colors.green.shade700 : Colors.orange.shade700
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _useGemini ? 'Online' : 'Fallback Mode',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _useGemini ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Messages area
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            
            // Typing indicator
            if (_isTyping)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(0),
                      _buildDot(1),
                      _buildDot(2),
                      const SizedBox(width: 8),
                      Text(
                        'Typing...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Suggestions chips (new feature)
            if (!_isTyping && _messages.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildSuggestionChip('Show me route to KLCC'),
                    _buildSuggestionChip('What\'s my point balance?'),
                    _buildSuggestionChip('Next trains to Mid Valley'),
                    _buildSuggestionChip('My SDG impact'),
                  ],
                ),
              ),
            
            // Input area - simplified container with no bottom spacing
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 6.0,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _textController.text.isEmpty
                            ? Colors.grey.shade300
                            : primaryColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Message Assistant...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          suffixIcon: _textController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _textController.clear();
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          // Trigger a rebuild to update the clear button
                          setState(() {});
                        },
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  // Voice input button
                  GestureDetector(
                    onTap: _speechAvailable ? _toggleListening : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Speech recognition is not available on this device'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: !_speechAvailable
                            ? Colors.grey.shade200
                            : _isListening
                                ? Colors.red.withOpacity(0.2)
                                : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: !_speechAvailable
                              ? Colors.grey.shade400
                              : _isListening
                                  ? Colors.red
                                  : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing animation when listening
                          if (_isListening && _speechAvailable)
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.5, end: 1.2),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return RepaintBoundary(
                                  child: AnimatedScale(
                                    scale: value,
                                    duration: Duration.zero,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onEnd: () {
                                setState(() {}); // Restart animation
                              },
                            ),
                          
                          // Microphone icon
                          Icon(
                            !_speechAvailable
                                ? Icons.mic_off
                                : _isListening
                                    ? Icons.mic
                                    : Icons.mic_none,
                            color: !_speechAvailable
                                ? Colors.grey.shade500
                                : _isListening
                                    ? Colors.red
                                    : Colors.grey.shade700,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Send button
                  GestureDetector(
                    onTap: _textController.text.isEmpty ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _textController.text.isEmpty
                            ? null
                            : LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _textController.text.isEmpty ? Colors.grey.shade200 : null,
                        shape: BoxShape.circle,
                        boxShadow: _textController.text.isEmpty
                            ? null
                            : [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: _textController.text.isEmpty ? Colors.grey.shade400 : Colors.white,
                        size: 20,
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
  
  Widget _buildDot(int index) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(
          math.sin((DateTime.now().millisecondsSinceEpoch / 500) + index) * 0.3 + 0.4,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
  
  Widget _buildSuggestionChip(String suggestion) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _textController.text = suggestion;
            _sendMessage();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            suggestion,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleListening() {
    // Don't proceed if speech recognition is not available
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_isListening) {
      // Stop listening
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
    } else {
      // Start listening
      _startListening();
    }
  }
  
  void _startListening() async {
    if (!_speechAvailable) return;
    
    try {
      // Check if speech recognition is available
      if (!_speechToText.isAvailable) {
        await _initSpeechRecognition();
        // If still not available after init, exit
        if (!_speechAvailable) return;
      }
      
      setState(() {
        _isListening = true;
      });
      
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
            
            // If we have a final result, stop listening and send the message
            if (result.finalResult && _textController.text.isNotEmpty) {
              _isListening = false;
              Future.delayed(const Duration(milliseconds: 500), () {
                _sendMessage();
              });
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      setState(() {
        _isListening = false;
        _speechAvailable = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access microphone: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show a snackbar to indicate we're listening
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('Listening...'),
          ],
        ),
        duration: const Duration(seconds: 30),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isListening = false;
              _speechToText.stop();
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Ask me anything about transit!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Routes, schedules, rewards, travel tips',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(Message message) {
    final ThemeService themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // Assistant avatar
            Container(
              height: 36,
              width: 36,
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: message.isUser
                ? Text(
                    message.text,
                    style: const TextStyle(color: Colors.white),
                  )
                : _buildFormattedText(message.text),
            ),
          ),
          
          if (message.isUser) ...[
            // User avatar using profile image
            Container(
              height: 36,
              width: 36,
              margin: const EdgeInsets.only(left: 8.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Builder(
                  builder: (context) {
                    // Get profile image from ProfileData
                    final profileImage = ProfileData.sharedProfileImage;
                    
                    if (profileImage != null && profileImage.existsSync()) {
                      try {
                        return Image.file(
                          profileImage,
                          fit: BoxFit.cover,
                        );
                      } catch (e) {
                        return Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      }
                    } else {
                      return Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFormattedText(String text) {
    final ThemeService themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    // Process the text to identify bold sections (marked with **) and bullet points
    final List<InlineSpan> spans = [];
    
    // Split by newlines to handle bullet points
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Check if this is a bullet point
      if (line.startsWith('• ')) {
        // Add some space before bullet points (except first line)
        if (i > 0 && !lines[i-1].startsWith('• ')) {
          spans.add(const TextSpan(text: '\n'));
        }
        
        // Add bullet point with proper indentation
        spans.add(TextSpan(
          text: '• ',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ));
        
        // Process the bullet point text for bold formatting
        final bulletText = line.substring(2);
        _addFormattedTextSpans(bulletText, spans);
        
        // Add newline after bullet point
        spans.add(const TextSpan(text: '\n'));
      } else {
        // For regular text, process for bold sections
        _addFormattedTextSpans(line, spans);
        
        // Add newline if not the last line
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
    }
    
    return RichText(
      text: TextSpan(
        children: spans,
      ),
    );
  }
  
  void _addFormattedTextSpans(String text, List<InlineSpan> spans) {
    final ThemeService themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    
    // Find all bold sections in this text
    for (final match in boldPattern.allMatches(text)) {
      // Add text before the bold section
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.black87),
        ));
      }
      
      // Add the bold section
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      
      lastMatchEnd = match.end;
    }
    
    // Add any remaining text after the last bold section
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.black87),
      ));
    }
  }
  
  void _showInfoDialog(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 8),
            const Text('About Transit Assistant'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This is a demonstration of a transit assistant powered by Google Gemini generative AI.'),
            const SizedBox(height: 16),
            
            if (_errorMessage.isNotEmpty) ...[
              const Text(
                'Status: Error connecting to Gemini',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text(
                'Using fallback responses. To use Gemini, please add your API key to the .env file.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
            ] else if (_useGemini) ...[
              const Text(
                'Status: Connected to Gemini AI',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            
            const Text('In a production environment, this assistant would:'),
            const SizedBox(height: 8),
            ...['Connect to transit APIs for real-time data',
               'Access your account information securely',
               'Provide personalized route recommendations',
               'Remember your preferences over time',
               'Support voice input and output'
              ].map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
} 