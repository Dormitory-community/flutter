import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/chat_room_model.dart';
import '../../../core/providers/chat_provider.dart';

class ChatMessageScreen extends ConsumerStatefulWidget {
  const ChatMessageScreen({
    super.key,
    required this.chatRoomId,
  });

  final String chatRoomId;

  @override
  ConsumerState<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends ConsumerState<ChatMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<XFile> _selectedImages = [];

  static const double _headerHeight = 70;
  static const double _inputHeight = 70;
  static const double _imagePreviewHeight = 80;

  @override
  void initState() {
    super.initState();
    // 채팅방 메시지 로드
    Future.microtask(() {
      ref.read(chatMessagesProvider.notifier).loadMessages(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(chatMessagesProvider);
    final chatRoomsState = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: chatRoomsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('채팅방 정보를 불러올 수 없습니다: $error')),
        data: (chatRooms) {
          final chatRoom = chatRooms.firstWhere(
                (room) => room.id == widget.chatRoomId,
            orElse: () => ChatRoom(
              id: widget.chatRoomId,
              name: '알 수 없는 채팅방',
              lastMessage: '',
              lastMessageTime: DateTime.now(),
              participants: [],
            ),
          );

          return Stack(
            children: [
              // 메시지 리스트
              Positioned.fill(
                top: _headerHeight,
                bottom: _inputHeight + (_selectedImages.isNotEmpty ? _imagePreviewHeight : 0),
                child: messagesState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('메시지를 불러올 수 없습니다: $error')),
                  data: (messages) => ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _MessageBubble(
                        message: message,
                        isCurrentUser: message.senderId == 'currentUser',
                      );
                    },
                  ),
                ),
              ),

              // 헤더
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _headerHeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    chatRoom.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              // 이미지 미리보기
              if (_selectedImages.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _inputHeight,
                  height: _imagePreviewHeight,
                  child: _buildImagePreview(),
                ),

              // 메시지 입력창
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _inputHeight,
                child: _buildMessageInput(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          final image = _selectedImages[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(image.path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            onPressed: _pickImages,
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _canSendMessage() ? _sendMessage : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _canSendMessage()
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: _canSendMessage()
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSendMessage() {
    return _messageController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _sendMessage() async {
    if (!_canSendMessage()) return;

    final text = _messageController.text.trim();
    List<String>? imagePaths;
    if (_selectedImages.isNotEmpty) {
      imagePaths = _selectedImages.map((e) => e.path).toList();
    }

    try {
      await ref.read(chatMessagesProvider.notifier).sendMessage(
        chatRoomId: widget.chatRoomId,
        text: text,
        imagePreviews: imagePaths,
      );
      _messageController.clear();
      setState(() => _selectedImages.clear());

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('메시지 전송 실패: $e')));
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
  });

  final ChatMessage message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Text(
                message.senderName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                _buildAvatar(),
                const SizedBox(width: 8),
              ],
              if (isCurrentUser) ...[
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment:
                  isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (message.imagePreviews != null && message.imagePreviews!.isNotEmpty)
                      _buildImageGrid(context, message.imagePreviews!),
                    if (message.text.isNotEmpty) ...[
                      if (message.imagePreviews != null &&
                          message.imagePreviews!.isNotEmpty)
                        const SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                            Radius.circular(isCurrentUser ? 16 : 4),
                            bottomRight:
                            Radius.circular(isCurrentUser ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message.text,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isCurrentUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isCurrentUser) ...[
                const SizedBox(width: 8),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF10b981).withOpacity(0.1),
      ),
      child: message.senderAvatar != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          message.senderAvatar!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      color: Color(0xFF10b981),
      size: 18,
    );
  }

  Widget _buildImageGrid(BuildContext context, List<String> imagePreviews) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: imagePreviews.take(4).map((imagePath) {
          return GestureDetector(
            onTap: () => _showImageModal(context, imagePath),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: imagePreviews.length == 1 ? 200 : 96,
                height: imagePreviews.length == 1 ? 200 : 96,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showImageModal(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}
