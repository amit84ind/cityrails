import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/chat_message.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class TrainChatScreen extends StatefulWidget {
  final String? initialLine;

  const TrainChatScreen({
    super.key,
    this.initialLine,
  });

  @override
  State<TrainChatScreen> createState() => _TrainChatScreenState();
}

class _TrainChatScreenState extends State<TrainChatScreen> {
  String _selectedLine = 'Central';
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLine != null) _selectedLine = widget.initialLine!;
    _stationController.text = 'Thane';
    _nameController.text = 'Commuter';
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _stationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final msgs =
        await DBHelper.instance.getChatMessages(line: _selectedLine);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
    }
  }

  Future<void> _postMessage() async {
    final msgText = _messageController.text.trim();
    if (msgText.isEmpty) return;

    final newMsg = ChatMessage(
      senderName: _nameController.text.trim().isEmpty
          ? 'Commuter'
          : _nameController.text.trim(),
      stationName: _stationController.text.trim().isEmpty
          ? 'Station'
          : _stationController.text.trim(),
      line: _selectedLine,
      message: msgText,
      timestamp: 'Just Now',
      likes: 1,
    );

    await DBHelper.instance.postChatMessage(newMsg);
    _messageController.clear();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: TirangaAppBar(
        title: '${_selectedLine.toUpperCase()} LINE CHAT',
        subtitle: 'Live Commuter Crowdsourced Railway Updates',
      ),
      body: Column(
        children: [
          // Line Selection Bar
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  ['Central', 'Western', 'Harbour', 'Trans-Harbour', 'Uran']
                      .map((line) {
                bool isSelected = _selectedLine == line;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedLine = line);
                    _loadMessages();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? TirangaTheme.navyBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            isSelected ? TirangaTheme.saffron : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      line,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Message List (matching image 3 screenshot format!)
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: TirangaTheme.saffron))
                : _messages.isEmpty
                    ? const Center(
                        child: Text('No updates posted yet for this line.',
                            style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return Card(
                            color: const Color(0xFF1E1E1E),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        msg.senderName,
                                        style: const TextStyle(
                                          color: Colors.tealAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        msg.timestamp,
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${msg.message} (sent from ${msg.stationName} Stn.)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.thumb_up_alt_outlined,
                                          color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${msg.likes}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Reply',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Message Post Input Bar
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type train status update...',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: TirangaTheme.saffron,
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _postMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
