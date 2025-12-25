import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/chatbot/chatbot_service.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/product/product_card.dart';
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isServiceHealthy = true;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _checkServiceHealth();
  }

  Future<void> _checkServiceHealth() async {
    final isHealthy = await ChatbotService.healthCheck();
    setState(() {
      _isServiceHealthy = isHealthy;
    });
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text:
            'Xin chào! Mình là trợ lý AI của bạn. Mình đang phát triển nên không phải lúc nào cũng đúng. Bạn có thể phản hồi để giúp mình cải thiện tốt hơn.\n\nMình sẵn sàng giúp bạn với câu hỏi về chính sách và tìm kiếm sản phẩm. Hôm nay bạn cần mình hỗ trợ gì không? ^^',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_isLoading) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Gửi tin nhắn và nhận response
      final response = await ChatbotService.sendMessage(text);
      print('💬 Chatbot response: ${jsonEncode(response.toJson())}');
      // Parse products nếu có trong metadata
      List<ProductModel>? products;
      if (response.metadata != null && response.metadata!['products'] != null) {
        try {
          final productsList = response.metadata!['products'] as List;
          products = productsList
              .map((p) => ProductModel.fromJson(p))
              .toList()
              .take(3)
              .toList(); // Giới hạn 3 sản phẩm
        } catch (e) {
          debugPrint('❌ Error parsing products: $e');
        }
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          products: products,
        ));
        _isLoading = false;
      });
    } on ChatbotException catch (e) {
      debugPrint('❌ CHATBOT ERROR');
      debugPrint('Error: ${e.message}');
      debugPrint('Code: ${e.code}');

      setState(() {
        _messages.add(ChatMessage(
          text: '❌ ${e.getUserFriendlyMessage()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ UNEXPECTED ERROR');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Có lỗi không mong muốn xảy ra. Vui lòng thử lại.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý AI',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  _isServiceHealthy ? 'Đang hoạt động' : 'Không hoạt động',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: _isServiceHealthy ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        // ❌ Đã xóa nút 3 chấm (actions)
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đang suy nghĩ...',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // ✅ Giữ lại suggested questions
          _buildSuggestedQuestions(),
          _buildMessageInput(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                'Tích hợp trí tuệ nhân tạo, thông tin mang tính tham khảo',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    if (_messages.length > 1) return const SizedBox.shrink();

    final suggestions = [
      'Gợi ý sản phẩm cho tôi',
      'Laptop nào giá rẻ nhưng cấu hình cao?',
      'Điện thoại di động nào chụp ảnh đẹp nhất?',
    ];

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _isLoading ? null : () => _sendMessage(suggestions[index]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        suggestions[index],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.blue.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung chat',
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                enabled: !_isLoading,
                onSubmitted: (value) {
                  if (!_isLoading) {
                    _sendMessage(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: _isLoading ? Colors.grey.shade300 : Colors.blue.shade400,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _isLoading ? null : () => _sendMessage(_messageController.text),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color: _isLoading ? Colors.grey.shade500 : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ProductModel>? products;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.products,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Text message
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser ? Colors.blue.shade400 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: message.isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Product cards (nếu có)
          if (message.products != null && message.products!.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Debug indicator
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                '📦 ${message.products!.length} sản phẩm được đề xuất',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 40), // Offset for avatar
                itemCount: message.products!.length,
                itemBuilder: (context, index) {
                  final product = message.products![index];
                  debugPrint('🎨 Building card for product: ${product.title}');
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ProductCard(
                      image: product.image,
                      brandName: product.brandName,
                      title: product.title,
                      price: product.priceAfterDiscount ?? 0.0,
                      discountPercent: product.discountPercent,
                      productId: product.id,
                      press: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: product.id,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // Debug: Show why products not shown
            if (!message.isUser)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 8),
                child: Text(
                  message.products == null ? '' : '',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.orange,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
