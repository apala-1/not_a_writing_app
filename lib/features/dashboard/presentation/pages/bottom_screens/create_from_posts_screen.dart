import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/book_viewmodel.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_posts_usecase.dart';

class CreateFromPostsScreen extends ConsumerStatefulWidget {
  const CreateFromPostsScreen({super.key});

  @override
  ConsumerState<CreateFromPostsScreen> createState() =>
      _CreateFromPostsScreenState();
}

class _CreateFromPostsScreenState
    extends ConsumerState<CreateFromPostsScreen> {
  List<PostEntity> selectedPosts = [];

  void togglePost(PostEntity post) {
    setState(() {
      if (selectedPosts.contains(post)) {
        selectedPosts.remove(post);
      } else {
        selectedPosts.add(post);
      }
    });
  }

Future<Map<String, dynamic>?> showBookDetailsDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  XFile? pickedImage;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Book Details"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Book Title"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          pickedImage = image;
                        });
                      }
                    },
                    child: Container(
                      color: Colors.grey[200],
                      height: 100,
                      width: double.infinity,
                      child: pickedImage == null
                          ? const Center(child: Text("Pick Cover Photo"))
                          : Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final description = descriptionController.text.trim();
                  if (title.isEmpty || description.length < 50 || pickedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Title, description (≥50 chars) and cover photo required"),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    "title": title,
                    "description": description,
                    "coverPhoto": pickedImage!,
                  });
                },
                child: const Text("Create"),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final bookViewModel = ref.read(bookViewModelProvider);
    final postsAsync = ref.watch(myPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create from Posts"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          Expanded(
            child: postsAsync.when(
              data: (posts) {
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final isSelected = selectedPosts.contains(post);

                    return ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.content),
                      trailing:
                          isSelected ? const Icon(Icons.check) : null,
                      onTap: () => togglePost(post),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text(err.toString())),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
  onPressed: selectedPosts.isEmpty
      ? null
      : () async {
          final details = await showBookDetailsDialog(context);
          if (details == null) return; // user cancelled

          // Pass title/description along with posts
          await bookViewModel.createBook(
            selectedPosts,
            title: details["title"]!,
            description: details["description"]!,
            coverPhoto: details["coverPhoto"]!,
          );
        },
  child: const Text("Create Book"),
),
          ),
        ],
      ),
    );
  }
}