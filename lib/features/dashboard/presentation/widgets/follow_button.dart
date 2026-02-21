import 'package:flutter/material.dart';
import 'package:not_a_writing_app/core/services/storage/follow_service.dart';

class FollowButton extends StatefulWidget {
  final String userId;
  final FollowService service;

  const FollowButton({
    super.key,
    required this.userId,
    required this.service,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    final result = await widget.service.isFollowing(widget.userId);
    setState(() {
      isFollowing = result;
      loading = false;
    });
  }

  Future<void> toggleFollow() async {
    if (isFollowing) {
      await widget.service.unfollow(widget.userId);
    } else {
      await widget.service.follow(widget.userId);
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox(height: 36);

    return ElevatedButton(
      onPressed: toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFollowing ? Colors.grey : Colors.blue,
      ),
      child: Text(
        isFollowing ? "Following" : "Follow",
      ),
    );
  }
}