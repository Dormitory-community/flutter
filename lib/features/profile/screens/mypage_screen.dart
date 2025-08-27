import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/router/app_router.dart';
import '../../../features/shared/widgets/user_avatar.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  bool _isEditModalOpen = false;
  String _editName = '';
  File? _selectedImage;
  String? _previewImagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
                vertical: isTablet ? 32 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '마이페이지',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '내 활동을 한눈에 확인하고 정보를 관리하세요.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Section
                  _buildProfileSection(user, theme),

                  const SizedBox(height: 24),

                  // Menu Items
                  _buildMenuSection(theme),
                ],
              ),
            ),
          )

        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel user, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  UserAvatar(
                    avatarUrl: user.avatarUrl,
                    displayName: user.displayName,
                    size: 80,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                user.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user.email,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 16),

              // Edit Button
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(user),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('프로필 수정'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildMenuSection(ThemeData theme) {
    final menuItems = [
      _MenuItem(
        title: '내 게시글',
        description: '작성한 게시글을 확인하세요',
        icon: Icons.article_outlined,
        onTap: () => context.push(AppRoutes.myPagePosts),
      ),
      _MenuItem(
        title: '내 댓글',
        description: '작성한 댓글을 확인하세요',
        icon: Icons.chat_bubble_outline,
        onTap: () => context.push(AppRoutes.myPageComments),
      ),
      _MenuItem(
        title: '스크랩',
        description: '스크랩한 게시글을 확인하세요',
        icon: Icons.bookmark_border,
        onTap: () => context.push(AppRoutes.myPageBookmarks),
      ),
      _MenuItem(
        title: '개인정보 및 보안',
        description: '계정 정보와 보안 설정을 관리하세요',
        icon: Icons.security_outlined,
        onTap: () => context.push(AppRoutes.myPagePrivacy),
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                onTap: item.onTap,
              ),
              if (index < menuItems.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showEditDialog(UserModel user) {
    setState(() {
      _editName = user.displayName;
      _previewImagePath = user.avatarUrl;
      _selectedImage = null;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isTablet = MediaQuery.of(context).size.width > 600;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: isTablet ? 400 : null,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    '프로필 수정',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Avatar with edit button
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          )
                              : _previewImagePath != null
                              ? UserAvatar(
                            avatarUrl: _previewImagePath,
                            displayName: _editName,
                            size: 80,
                          )
                              : UserAvatar(
                            displayName: _editName,
                            size: 80,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => _pickImage(setDialogState),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Name field
                  TextField(
                    controller: TextEditingController(text: _editName),
                    onChanged: (value) {
                      setDialogState(() {
                        _editName = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email field (readonly)
                  TextField(
                    controller: TextEditingController(text: user.email),
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveProfile(user),
                          child: const Text('저장'),
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
    );
  }

  Future<void> _pickImage(StateSetter setDialogState) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setDialogState(() {
          _selectedImage = File(image.path);
          _previewImagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile(UserModel user) async {
    try {
      // TODO: 실제 프로필 업데이트 로직 구현
      // - 이미지 업로드 (_selectedImage)
      // - 사용자 정보 업데이트 (_editName)

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 업데이트 실패: $e')),
        );
      }
    }
  }
}

class _MenuItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  _MenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}