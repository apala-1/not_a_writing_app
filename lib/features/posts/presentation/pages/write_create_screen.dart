import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:not_a_writing_app/features/posts/data/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/theme/colors.dart';

// Provider for PostRemoteDatasource
final postRemoteDatasourceProvider = Provider<PostRemoteDatasource>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);
  return PostRemoteDatasource(userSessionService: userSessionService);
});

// Provider for PostRepository
final postRepositoryProvider = Provider<IPostRepository>((ref) {
  final remote = ref.read(postRemoteDatasourceProvider);
  return PostRepositoryImpl(remoteDatasource: remote);
});

class WriteScreen extends ConsumerStatefulWidget {
  const WriteScreen({super.key});

  @override
  ConsumerState<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends ConsumerState<WriteScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  bool isDraft = false;
  bool isLoading = false;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> submitPost() async {
  if (_titleController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _contentController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All fields are required')),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final postRepo = ref.read(postRepositoryProvider);

    final post = await postRepo.createPost(
      title: _titleController.text,
      description: _descriptionController.text,
      content: _contentController.text,
      isDraft: isDraft,
      attachments: _selectedImages,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDraft ? 'Draft saved successfully' : 'Post published successfully',
        ),
      ),
    );

    // Reset form
    _titleController.clear();
    _descriptionController.clear();
    _contentController.clear();
    setState(() {
      _selectedImages.clear();
      isDraft = false;
    });

    // ← Pop back and signal that a new post was created
    if (!isDraft) {
      Navigator.pop(context, true); // true indicates new post was created
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Create Post",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputCard(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Title...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInputCard(
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Description (min 50 characters)...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildInputCard(
                child: TextField(
                  controller: _contentController,
                  expands: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Start writing your content...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Add Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: isDraft,
                  onChanged: (val) => setState(() => isDraft = val),
                ),
                Text(
                  isDraft ? "Draft" : "Publish",
                  style: const TextStyle(color: AppColors.textPrimary),
                )
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isDraft ? "Save Draft" : "Publish Post",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}
