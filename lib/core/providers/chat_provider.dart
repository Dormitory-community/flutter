import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_room_model.dart';
class ChatRoomsNotifier extends StateNotifier<AsyncValue<List<ChatRoom>>> {
  ChatRoomsNotifier(this._supabase) : super(const AsyncValue.loading()) {
    _init();
  }

  final SupabaseClient _supabase;

  void _init() {
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    try {
      state = const AsyncValue.loading();

      // 임시 데이터 (실제로는 Supabase에서 가져와야 함)
      final chatRooms = [
        ChatRoom(
          id: 'group_1',
          name: '플로깅 그룹',
          avatar: null,
          lastMessage: '오늘 플로깅 기대됩니다!',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          unreadCount: 2,
          participants: ['user1', 'user2', 'user3'],
          isGroup: true,
        ),
        ChatRoom(
          id: 'group_2',
          name: '환경보호 동아리',
          avatar: null,
          lastMessage: '다음 주 활동 일정 공유드립니다',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
          participants: ['user1', 'user4', 'user5'],
          isGroup: true,
        ),
        ChatRoom(
          id: 'group_3',
          name: '기숙사 3동',
          avatar: null,
          lastMessage: '공지사항이 있습니다',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 5,
          participants: ['user1', 'user6', 'user7', 'user8'],
          isGroup: true,
        ),
      ];

      state = AsyncValue.data(chatRooms);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshChatRooms() async {
    await loadChatRooms();
  }
}

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier(this._supabase) : super(const AsyncValue.loading());

  final SupabaseClient _supabase;

  Future<void> loadMessages(String chatRoomId) async {
    try {
      state = const AsyncValue.loading();

      // 임시 데이터
      final messages = [
        ChatMessage(
          id: '1',
          senderId: 'user1',
          senderName: '김플로깅',
          senderAvatar: null,
          text: '안녕하세요! 오늘 플로깅 기대됩니다!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 60)),
        ),
        ChatMessage(
          id: '2',
          senderId: 'user2',
          senderName: '환경지킴이',
          senderAvatar: null,
          text: '네, 저도요! 다들 조심히 오세요~',
          timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
        ),
        ChatMessage(
          id: '3',
          senderId: 'user1',
          senderName: '김플로깅',
          senderAvatar: null,
          text: '혹시 준비물 중에\n특별히 챙겨야 할 게\n있을까요?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        ),
        ChatMessage(
          id: '4',
          senderId: 'user3',
          senderName: '깨비로드 운영진',
          senderAvatar: null,
          text: '쓰레기 봉투와 집게는 현장에서 제공됩니다!\n개인 텀블러나 장갑 정도\n챙겨오시면 좋아요.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ];

      state = AsyncValue.data(messages);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void addMessage(ChatMessage message) {
    state = state.whenData((messages) {
      return [...messages, message];
    });
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
    List<String>? imagePreviews,
  }) async {
    try {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'currentUser',
        senderName: '나',
        senderAvatar: null,
        text: text,
        timestamp: DateTime.now(),
        imagePreviews: imagePreviews,
      );

      addMessage(newMessage);

      // 실제로는 Supabase에 메시지 저장
      // await _supabase.from('messages').insert({
      //   'chat_room_id': chatRoomId,
      //   'sender_id': currentUserId,
      //   'text': text,
      //   'image_previews': imagePreviews,
      // });
    } catch (e) {
      // 에러 처리
      rethrow;
    }
  }
}

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, AsyncValue<List<ChatRoom>>>((ref) {
  final supabase = ref.read(supabaseProvider);
  return ChatRoomsNotifier(supabase);
});

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  final supabase = ref.read(supabaseProvider);
  return ChatMessagesNotifier(supabase);
});