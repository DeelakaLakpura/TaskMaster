import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    final trimmedMsg = message.trim();
    if (trimmedMsg.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': trimmedMsg, 'timestamp': DateTime.now()});
      _isTyping = true;
    });

    _scrollToBottom();

    // Handle special commands
    if (trimmedMsg.toLowerCase() == 'hi' || trimmedMsg.toLowerCase() == 'hello') {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Hello! 👋\nI\'m your Tech Assistant.\nHow can I help you today?',
          'timestamp': DateTime.now()
        });
        _isTyping = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyA-8YhEKXGhDYRep9UDg-WvrL98GPLCCZ8'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": trimmedMsg}]}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply = data['candidates']?[0]['content']['parts']?[0]['text'] ?? 'Sorry, I couldn\'t understand that.';
        reply = reply.replaceAll('**', ''); // Remove markdown bold

        await Future.delayed(Duration(seconds: 1)); // Simulate typing delay
        setState(() {
          _messages.add({'sender': 'bot', 'text': reply, 'timestamp': DateTime.now()});
          _isTyping = false;
        });
      } else {
        setState(() {
          _messages.add({'sender': 'bot', 'text': '⚠️ Oops! Something went wrong. Please try again.', 'timestamp': DateTime.now()});
          _isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': '🔌 Connection error. Please check your internet.', 'timestamp': DateTime.now()});
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (!available) return;

      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              _sendMessage(result.recognizedWords);
            }
          });
        },
        listenFor: Duration(seconds: 30),
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tech Assistant 🤖', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _messages.length) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  }
                  return _buildTypingIndicator();
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.green.shade500,
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                message['text'],
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.grey.shade800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade800,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade800,
            child: Text('🤖', style: TextStyle(fontSize: 24)),
          ),
          SizedBox(width: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(1),
                _buildDot(2),
                _buildDot(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue.shade800.withOpacity(_isTyping ? (0.5 + (index * 0.15)) : 0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your question or speak...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                        color: _isListening ? Colors.red : Colors.green),
                    onPressed: _startListening,
                  ),
                ),
                onSubmitted: (text) {
                  _sendMessage(text);
                  _controller.clear();
                },
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green.shade800,
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white,),
                onPressed: () {
                  final message = _controller.text.trim();
                  if (message.isNotEmpty) {
                    _sendMessage(message);
                    _controller.clear();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}