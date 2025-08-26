import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/config/app_config.dart';
import '../../../core/models/post_model.dart';
import '../../../core/providers/auth_provider.dart';
// import '../../shared/widgets/custom_text_field.dart';

// Form providers
final titleProvider = StateProvider<String>((ref) => '');
final contentProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<PostCategory>((ref) => PostCategory.free);
final selectedImagesProvider = StateProvider<List<XFile>>((ref) => []);
final selectedTagsProvider = StateProvider<List<String>>((ref) => []);
final isAnonymousProvider = StateProvider<bool>((ref) => false);
final isSubmittingProvider = StateProvider<bool>((ref) => false);

final tagControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

class BoardWriteScreen extends ConsumerStatefulWidget {
  const BoardWriteScreen({
    super.key,
    required this.type,
    this.editPost,
  });

  final String type;
  final PostModel? editPost;

  @override
  ConsumerState<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends ConsumerState<BoardWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize category based on type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final category = _getCategoryFromType(widget.type);
      ref.read(selectedCategoryProvider.notifier).state = category;

      // If editing, populate form with existing data
      if (widget.editPost != null) {
        final post = widget.editPost!;
        _titleController.text = post.title;
        _contentController.text = post.content;
        ref.read(titleProvider.notifier).state = post.title;
        ref.read(contentProvider.notifier).state = post.content;
        ref.read(selectedTagsProvider.notifier).state = List.from(post.tags);
        ref.read(isAnonymousProvider.notifier).state = post.isAnonymous;
      }
    });

    _titleController.addListener(() {
      ref.read(titleProvider.notifier).state = _titleController.text;
    });

    _contentController.addListener(() {
      ref.read(contentProvider.notifier).state = _contentController.text;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  PostCategory _getCategoryFromType(String type) {
    switch (type) {
      case 'free':
        return PostCategory.free;
      case 'info':
        return PostCategory.info;
      case 'counseling':
        return PostCategory.counseling;
      default:
        return PostCategory.free;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final title = ref.watch(titleProvider);
    final content = ref.watch(contentProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedImages = ref.watch(selectedImagesProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('로그인 필요')),
        body: const Center(
          child: Text('게시글을 작성하려면 로그인이 필요합니다.'),
        ),
      );
    }

    final isFormValid = title.trim().isNotEmpty &&
        content.trim().isNotEmpty &&
        title.length <= AppConfig.maxPostTitleLength &&
        content.length <= AppConfig.maxPostContentLength;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.editPost != null ? '게시글 수정' : '게시글 작성'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          TextButton(
            onPressed: isFormValid && !isSubmitting
                ? () => _submitPost(context)
                : null,
            child: isSubmitting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              widget.editPost != null ? '수정' : '완료',
              style: TextStyle(
                color: isFormValid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    _CategorySelector(selectedCategory: selectedCategory),

                    const SizedBox(height: 20),

                    // Title Input
                    _TitleInput(controller: _titleController),

                    const SizedBox(height: 20),

                    // Content Input
                    _ContentInput(controller: _contentController),

                    const SizedBox(height: 20),

                    // Image Selector
                    _ImageSelector(selectedImages: selectedImages),

                    const SizedBox(height: 20),

                    // Tag Input
                    _TagInput(selectedTags: selectedTags),

                    const SizedBox(height: 20),

                    // Anonymous Option
                    _AnonymousOption(isAnonymous: isAnonymous),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final hasContent = _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty;

    if (!hasContent) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작성 취소'),
        content: const Text('작성 중인 내용이 있습니다. 정말 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 작성'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPost(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(isSubmittingProvider.notifier).state = true;

    try {
      // TODO: API 호출로 게시글 작성/수정
      await Future.delayed(const Duration(seconds: 2)); // Mock delay

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editPost != null ? '게시글이 수정되었습니다.' : '게시글이 작성되었습니다.'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isSubmittingProvider.notifier).state = false;
      }
    }
  }
}

class _CategorySelector extends ConsumerWidget {
  const _CategorySelector({required this.selectedCategory});

  final PostCategory selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PostCategory.values.map((category) {
            final isSelected = category == selectedCategory;
            return FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.surface,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 1.2,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TitleInput extends ConsumerWidget {
  const _TitleInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(titleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '제목',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red),
            ),
            const Spacer(),
            Text(
              '${title.length}/${AppConfig.maxPostTitleLength}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: title.length > AppConfig.maxPostTitleLength
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '제목을 입력하세요',
            counterText: '', // ← 여기로 옮김
          ),
          maxLength: AppConfig.maxPostTitleLength,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            if (value.length > AppConfig.maxPostTitleLength) {
              return '제목은 ${AppConfig.maxPostTitleLength}자 이내로 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _ContentInput extends ConsumerWidget {
  const _ContentInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '내용',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(color: Colors.red),
            ),
            const Spacer(),
            Text(
              '${content.length}/${AppConfig.maxPostContentLength}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: content.length > AppConfig.maxPostContentLength
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '내용을 입력하세요',
            alignLabelWithHint: true,
            counterText: '', // ← 여기로 옮김
          ),
          maxLines: 8,
          maxLength: AppConfig.maxPostContentLength,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '내용을 입력해주세요';
            }
            if (value.length > AppConfig.maxPostContentLength) {
              return '내용은 ${AppConfig.maxPostContentLength}자 이내로 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _ImageSelector extends ConsumerWidget {
  const _ImageSelector({required this.selectedImages});

  final List<XFile> selectedImages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '이미지',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${selectedImages.length}/${AppConfig.maxImagesPerPost}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          child: Row(
            children: [
              // Add Image Button
              if (selectedImages.length < AppConfig.maxImagesPerPost)
                InkWell(
                  onTap: () => _pickImages(context, ref),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '사진 추가',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selected Images
              if (selectedImages.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = selectedImages[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                image.path,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                                  : Image.file(
                                File(image.path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),

                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => _removeImage(ref, index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        if (selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '최대 ${AppConfig.maxImageSizeMB}MB, ${AppConfig.supportedImageFormats.join(', ')} 형식만 업로드 가능합니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImages(BuildContext context, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        final currentImages = ref.read(selectedImagesProvider);
        final remainingSlots = AppConfig.maxImagesPerPost - currentImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        ref.read(selectedImagesProvider.notifier).state = [
          ...currentImages,
          ...imagesToAdd,
        ];

        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('최대 ${AppConfig.maxImagesPerPost}장까지만 업로드할 수 있습니다.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(WidgetRef ref, int index) {
    final currentImages = ref.read(selectedImagesProvider);
    final updatedImages = List<XFile>.from(currentImages);
    updatedImages.removeAt(index);
    ref.read(selectedImagesProvider.notifier).state = updatedImages;
  }
}

class _TagInput extends ConsumerWidget {
  const _TagInput({required this.selectedTags});

  final List<String> selectedTags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagController = ref.watch(tagControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '태그',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: tagController,
          decoration: InputDecoration(
            hintText: '태그를 입력하고 엔터를 누르세요 (최대 5개)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(context, ref),
            ),
          ),
          onFieldSubmitted: (value) => _addTag(context, ref),
        ),
        if (selectedTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedTags.map((tag) {
              return Chip(
                label: Text('#$tag'),
                onDeleted: () => _removeTag(ref, tag),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addTag(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tagControllerProvider);
    final tag = controller.text.trim();
    final currentTags = ref.read(selectedTagsProvider);

    if (tag.isNotEmpty && !currentTags.contains(tag) && currentTags.length < 5) {
      ref.read(selectedTagsProvider.notifier).state = [...currentTags, tag];
      controller.clear();
    } else if (currentTags.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('태그는 최대 5개까지 추가할 수 있습니다.')),
      );
    }
  }

  void _removeTag(WidgetRef ref, String tag) {
    final currentTags = ref.read(selectedTagsProvider);
    ref.read(selectedTagsProvider.notifier).state =
        currentTags.where((t) => t != tag).toList();
  }
}

class _AnonymousOption extends ConsumerWidget {
  const _AnonymousOption({required this.isAnonymous});

  final bool isAnonymous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isAnonymous,
            onChanged: (value) =>
            ref.read(isAnonymousProvider.notifier).state = value ?? false,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '익명으로 작성',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '작성자 정보가 표시되지 않습니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}