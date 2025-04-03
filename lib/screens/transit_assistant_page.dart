import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
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
  
  // List of predefined responses for the demo
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
    // Add welcome message
    _addBotMessage('Hello! I\'m your Transit Assistant, powered by Google\'s Agentspace AI. I can help with route planning, schedules, points balance, and travel tips. How can I assist you today?');
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

  void _sendMessage() {
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
    
    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      // Generate appropriate response
      String botResponse = _getMockResponse(userMessage.toLowerCase());
      
      setState(() {
        _isTyping = false;
        _messages.add(Message(
          text: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }
  
  // Generate a mock response based on message keywords
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
                    'Powered by Google Agentspace',
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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    onTap: _toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red.withOpacity(0.2) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isListening ? Colors.red : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Send button
                  GestureDetector(
                    onTap: _textController.text.isEmpty ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
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
    // In a real app, this would use the speech recognition API
    // For this demo, we'll simulate the process
    
    if (_isListening) {
      // Stop listening
      setState(() {
        _isListening = false;
        // Simulate receiving text from voice
        _textController.text = 'Show me the next train to KL Sentral';
      });
    } else {
      // Start listening
      setState(() {
        _isListening = true;
        _showListeningSnackBar();
      });
      
      // Simulate listening for 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
            _textController.text = 'Show me the next train to KL Sentral';
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      });
    }
  }
  
  void _showListeningSnackBar() {
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
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
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
            const Text('This is a demonstration of a transit assistant powered by Google Agentspace generative AI.'),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Text(
              'For this demo, try asking about routes, schedules, points, or SDG impact.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
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