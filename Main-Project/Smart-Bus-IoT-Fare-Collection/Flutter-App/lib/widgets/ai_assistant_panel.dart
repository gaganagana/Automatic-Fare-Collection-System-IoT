import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';

class AIAssistantPanel extends StatefulWidget {
  const AIAssistantPanel({super.key});

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final app = context.read<AppState>();
      final isKn = app.locale.languageCode == 'kn';
      final isHi = app.locale.languageCode == 'hi';
      final greeting = isKn
          ? 'ನಮಸ್ಕಾರ! 👋 ನಾನು ನಿಮ್ಮ ಸ್ಮಾರ್ಟ್ ಬಸ್ AI ಚಾಟ್‌ಬಾಟ್.\n\nನೀವು ನನ್ನನ್ನು ಯಾವುದೇ BMTC ಮಾರ್ಗ (ಉದಾ: 600F, 500D, 335E, 365, 25A), ಸಮಯ, ನಿಲ್ದಾಣಗಳು, ₹10/ನಿಲ್ದಾಣ ಪ್ರಯಾಣ ದರ ಅಥವಾ ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ ಬ್ಯಾಲೆನ್ಸ್ ಬಗ್ಗೆ ಕೇಳಬಹುದು.'
          : (isHi
              ? 'नमस्ते! 👋 मैं आपका स्मार्ट बस AI चैटबॉट हूँ।\n\nआप मुझसे किसी भी BMTC रूट (उदा: 600F, 500D, 335E, 365, 25A), समय, स्टॉप्स, ₹10/स्टॉप किराया या स्मार्ट कार्ड बैलेंस के बारे में पूछ सकते हैं।'
              : 'Hello! 👋 I am your Smart Bus AI Chatbot.\n\nAsk me about any BMTC route (e.g. 600F, 500D, 335E, 365, 25A), timings, stops, ₹10/stop fares, or your Smart Card balance.');
      _messages.add(_ChatMessage(
        user: false,
        text: greeting,
        time: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _ask([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    final app = context.read<AppState>();
    final answer = app.aiAnswer(text);
    setState(() {
      _messages.add(_ChatMessage(
        user: true,
        text: text,
        time: DateTime.now(),
      ));
      _messages.add(_ChatMessage(
        user: false,
        text: answer,
        time: DateTime.now(),
      ));
      _controller.clear();
    });
    _scrollToBottom();
  }



  void _clearChat() {
    setState(() {
      _messages.clear();
      final app = context.read<AppState>();
      final isKn = app.locale.languageCode == 'kn';
      final isHi = app.locale.languageCode == 'hi';
      final greeting = isKn
          ? 'ನಮಸ್ಕಾರ! 👋 ನಾನು ನಿಮ್ಮ ಸ್ಮಾರ್ಟ್ ಬಸ್ AI ಚಾಟ್‌ಬಾಟ್.\n\nನೀವು ನನ್ನನ್ನು ಯಾವುದೇ BMTC ಮಾರ್ಗ (ಉದಾ: 600F, 500D, 335E, 365, 25A), ಸಮಯ, ನಿಲ್ದಾಣಗಳು, ₹10/ನಿಲ್ದಾಣ ಪ್ರಯಾಣ ದರ ಅಥವಾ ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ ಬ್ಯಾಲೆನ್ಸ್ ಬಗ್ಗೆ ಕೇಳಬಹುದು.'
          : (isHi
              ? 'नमस्ते! 👋 मैं आपका स्मार्ट बस AI चैटबॉट हूँ।\n\nआप मुझसे किसी भी BMTC रूट (उदा: 600F, 500D, 335E, 365, 25A), समय, स्टॉप्स, ₹10/स्टॉप किराया या स्मार्ट कार्ड बैलेंस के बारे में पूछ सकते हैं।'
              : 'Hello! 👋 I am your Smart Bus AI Chatbot.\n\nAsk me about any BMTC route (e.g. 600F, 500D, 335E, 365, 25A), timings, stops, ₹10/stop fares, or your Smart Card balance.');
      _messages.add(_ChatMessage(
        user: false,
        text: greeting,
        time: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final isKn = app.locale.languageCode == 'kn';
    final isHi = app.locale.languageCode == 'hi';

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Title and Clear Button
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined, size: 18, color: AppColors.amber),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  l10n.aiAssistantTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
                tooltip: l10n.clearChat,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _clearChat,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            l10n.aiAssistantSubtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 10),

          // Route & Topic Quick Action Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickChip('🗺️ Plan Any Trip', isKn ? 'Kengeri to ITPL ಹೇಗೆ ಹೋಗುವುದು?' : (isHi ? 'Kengeri से ITPL कैसे जाएं?' : 'Bus from Kengeri to ITPL')),
                const SizedBox(width: 5),
                _quickChip('✈️ Airport (KIA)', isKn ? 'ವಿಮಾನ ನಿಲ್ದಾಣದ ಬಸ್ಸುಗಳು KIA ವಿವರಗಳು' : (isHi ? 'एयरपोर्ट बस रूट KIA विवरण' : 'Airport KIA bus routes and timings')),
                const SizedBox(width: 5),
                _quickChip('🤖 AI & ML in Bus', isKn ? 'ಸ್ಮಾರ್ಟ್ ಬಸ್‌ನಲ್ಲಿ Machine Learning ಹೇಗೆ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ?' : (isHi ? 'स्मार्ट बस में Machine Learning कैसे काम करती है?' : 'How does Machine Learning work in this Smart Bus?')),
                const SizedBox(width: 5),
                _quickChip('⚙️ Hardware Specs', isKn ? 'IoT ಹಾರ್ಡ್‌ವೇರ್ ವಿವರಗಳು ಮತ್ತು ಪಿನ್‌ಔಟ್‌ಗಳು' : (isHi ? 'IoT हार्डवेयर विवरण और सर्किट' : 'Explain Arduino, NodeMCU, and RFID hardware components')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptRoute600F, isKn ? '600F ಬಸ್ ಮಾರ್ಗ ಮತ್ತು ವಿವರಗಳು' : (isHi ? '600F बस रूट और विवरण' : 'Tell me about route 600F')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptRoute500D, isKn ? '500D ಬಸ್ ಮಾರ್ಗ ವಿವರಗಳು' : (isHi ? '500D बस रूट विवरण' : 'Tell me about route 500D')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptRoute335E, isKn ? '335E ಬಸ್ ಮಾರ್ಗ ವಿವರಗಳು' : (isHi ? '335E बस रूट विवरण' : 'Tell me about route 335E')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptRoute365, isKn ? '365 ಬಸ್ ಮಾರ್ಗ ವಿವರಗಳು' : (isHi ? '365 बस रूट विवरण' : 'Tell me about route 365')),
                const SizedBox(width: 5),
                _quickChip('🚌 Route 401B', isKn ? '401B ಬಸ್ ಮಾರ್ಗ ವಿವರಗಳು' : (isHi ? '401B बस रूट विवरण' : 'Tell me about route 401B')),
                const SizedBox(width: 5),
                _quickChip('🚌 Route 201', isKn ? '201 ಬಸ್ ಮಾರ್ಗ ವಿವರಗಳು' : (isHi ? '201 बस रूट विवरण' : 'Tell me about route 201')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptRoute25A, isKn ? '25A ಬಸ್ ಮಾರ್ಗ 18 ನಿಲ್ದಾಣಗಳು' : (isHi ? '25A बस रूट 18 स्टॉप्स' : 'Route 25A all stops')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptFareRule, isKn ? 'ಸ್ಮಾರ್ಟ್ ಬಸ್ ಪ್ರಯಾಣ ದರ ನಿಯಮ (ಪ್ರತಿ ನಿಲ್ದಾಣಕ್ಕೆ ₹10)' : (isHi ? 'स्मार्ट बस किराया नियम (₹10 प्रति स्टॉप)' : 'Smart Bus fare rule at ₹10 per stop')),
                const SizedBox(width: 5),
                _quickChip(l10n.promptBalance, isKn ? 'ನನ್ನ ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ ಬ್ಯಾಲೆನ್ಸ್ ಎಷ್ಟು?' : (isHi ? 'मेरा कार्ड बैलेंस कितना है?' : 'My card balance')),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Scrollable Chat Message History Box
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.panelAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];

                return Align(
                  alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    decoration: BoxDecoration(
                      color: m.user
                          ? AppColors.blue.withValues(alpha: 0.18)
                          : const Color(0xFF161F2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: m.user
                            ? AppColors.blue.withValues(alpha: 0.4)
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              m.user ? Icons.person : Icons.smart_toy,
                              size: 13,
                              color: m.user ? AppColors.blue : AppColors.amber,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              m.user ? 'You' : 'Smart Bus AI',
                              style: TextStyle(
                                color: m.user ? AppColors.blue : AppColors.amber,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('HH:mm').format(m.time),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          m.text,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Input Bar (TextField + Send)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _ask(),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: l10n.askHint,
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: l10n.sendButton,
                onPressed: () => _ask(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.send, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, String query) => ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600)),
        onPressed: () => _ask(query),
        backgroundColor: AppColors.panelAlt,
        side: const BorderSide(color: AppColors.border),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _ChatMessage {
  final bool user;
  final String text;
  final DateTime time;

  const _ChatMessage({
    required this.user,
    required this.text,
    required this.time,
  });
}
