import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthli/community/sync_service.dart';
import '../database/models/post_model.dart';
import '../database/models/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'package:uuid/uuid.dart';
import 'package:healthli/database/dao/dao_providers.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final String currentUserId;
  const PostCard({super.key, required this.post, required this.currentUserId});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with TickerProviderStateMixin {
  bool _showComments = false;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isLiking = false;
  bool _isSaving = false;
  late AnimationController _likeAnimationController;
  late AnimationController _saveAnimationController;
  final TextEditingController _commentController = TextEditingController();
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _isSaved = widget.post.savedBy.contains(widget.currentUserId);
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _saveAnimationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);
    HapticFeedback.lightImpact();

    final postDao = ref.read(postDaoProvider);
    final userId = widget.currentUserId;
    final post = widget.post;
    final isCurrentlyLiked = _isLiked;

    if (isCurrentlyLiked) {
      await postDao.unlikePost(post.id, userId);
      _likeAnimationController.reverse();
    } else {
      await postDao.likePost(post.id, userId);
      _likeAnimationController.forward();
      // Create notification for post owner if not self
      if (post.userId != userId) {
        await CommunitySyncService.createLikeNotification(
          postId: post.id,
          postOwnerId: post.userId,
          actorId: userId,
        );
      }
    }

    setState(() => _isLiked = !isCurrentlyLiked);
    // Optionally: ref.refresh(postsProvider());

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLiking = false);
  }

  void _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final postDao = ref.read(postDaoProvider);
    final userId = widget.currentUserId;
    final isCurrentlySaved = _isSaved;

    if (isCurrentlySaved) {
      await postDao.unsavePost(widget.post.id, userId);
      _saveAnimationController.reverse();
    } else {
      await postDao.savePost(widget.post.id, userId);
      _saveAnimationController.forward();
    }

    setState(() => _isSaved = !isCurrentlySaved);
    ref.refresh(savedPostsProvider(userId));

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isSaving = false);
  }

  void _showShareOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final commentsAsync = ref.watch(commentsForPostProvider(post.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE1E8ED), width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to post detail if needed
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // User info and timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Anonymous',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.grey[900],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimeAgo(post.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // More options
                  _ActionIcon(
                    icon: Icons.more_horiz,
                    onTap: () => _showMoreOptions(),
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Post content
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF14171A),
                ),
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  // Comments
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble_outline,
                    count: commentsAsync.maybeWhen(
                      data: (comments) => comments.length,
                      orElse: () => 0,
                    ),
                    onTap: () => setState(() => _showComments = !_showComments),
                    color: Colors.grey[600]!,
                    activeColor: Colors.green[600]!,
                    isActive: _showComments,
                  ),

                  const Spacer(),

                  // Repost (placeholder)
                  _ActionButton(
                    icon: Icons.repeat,
                    activeIcon: Icons.repeat,
                    count: 0,
                    onTap: () {},
                    color: Colors.grey[600]!,
                    activeColor: Colors.green[600]!,
                    isActive: false,
                  ),

                  const Spacer(),

                  // Like
                  AnimatedBuilder(
                    animation: _likeAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_likeAnimationController.value * 0.1),
                        child: _ActionButton(
                          icon: Icons.favorite_border,
                          activeIcon: Icons.favorite,
                          count: post.likes + (_isLiked ? 1 : 0),
                          onTap: _handleLike,
                          color: Colors.grey[600]!,
                          activeColor: Colors.red[500]!,
                          isActive: _isLiked,
                          loading: _isLiking,
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Share
                  _ActionButton(
                    icon: Icons.share_outlined,
                    activeIcon: Icons.share_outlined,
                    count: null,
                    onTap: _showShareOptions,
                    color: Colors.grey[600]!,
                    activeColor: Colors.green[600]!,
                    isActive: false,
                  ),

                  const SizedBox(width: 8),

                  // Save
                  AnimatedBuilder(
                    animation: _saveAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_saveAnimationController.value * 0.1),
                        child: _ActionIcon(
                          icon:
                              _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          onTap: _handleSave,
                          color:
                              _isSaved ? Colors.green[600]! : Colors.grey[600]!,
                          loading: _isSaving,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Comments section
              if (_showComments) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 12),
                commentsAsync.when(
                  data:
                      (comments) => Column(
                        children: [
                          // Add comment
                          _buildAddComment(),
                          const SizedBox(height: 12),
                          // Comments list
                          for (final comment in comments)
                            _CommentTile(comment: comment),
                        ],
                      ),
                  loading:
                      () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, _) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error loading comments: $e'),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddComment() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.green[600], size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Post your reply',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              minLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _submittingComment
            ? Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              ),
            )
            : _ActionIcon(
              icon: Icons.send,
              onTap: () => _submitComment(),
              color: Colors.green[600]!,
              size: 18,
            ),
      ],
    );
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _submittingComment) return;

    setState(() => _submittingComment = true);

    try {
      final comment = Comment(
        id: const Uuid().v4(),
        postId: widget.post.id,
        userId: widget.post.userId,
        text: text,
        createdAt: DateTime.now().toIso8601String(),
        isSynced: false,
      );

      await ref.read(commentDaoProvider).insertComment(comment);
      await CommunitySyncService.syncAllPendingToFirestore(widget.post.userId);
      await CommunitySyncService.fetchPostsFromFirestoreAndCache();

      _commentController.clear();
      HapticFeedback.lightImpact();

      // Refresh the comments provider to show the new comment immediately
      ref.refresh(commentsForPostProvider(widget.post.id));
    } catch (e) {
      // Handle error - maybe show a snackbar
      if (mounted) {
        log('Failed to post comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submittingComment = false);
      }
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoreOptionsBottomSheet(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set _isSaved based on whether the current user has saved this post
    final post = widget.post;
    final userId =
        post.userId; // This should be the current user, not the post owner
    _isSaved = post.savedBy.contains(userId);
  }

  String _formatTimeAgo(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int? count;
  final VoidCallback onTap;
  final Color color;
  final Color activeColor;
  final bool isActive;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.onTap,
    required this.color,
    required this.activeColor,
    required this.isActive,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            loading
                ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                )
                : Icon(
                  isActive ? activeIcon : icon,
                  size: 18,
                  color: isActive ? activeColor : color,
                ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Text(
                count! > 999
                    ? '${(count! / 1000).toStringAsFixed(1)}k'
                    : '$count',
                style: TextStyle(
                  color: isActive ? activeColor : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double? size;
  final bool loading;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.color,
    this.size,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child:
            loading
                ? SizedBox(
                  width: size ?? 20,
                  height: size ?? 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color ?? Colors.grey[600]!,
                    ),
                  ),
                )
                : Icon(
                  icon,
                  size: size ?? 20,
                  color: color ?? Colors.grey[600],
                ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.green[600], size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Color(0xFF14171A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _ShareBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _ShareOption(icon: Icons.copy, title: 'Copy link', onTap: () {}),
          _ShareOption(icon: Icons.share, title: 'Share via...', onTap: () {}),
          _ShareOption(
            icon: Icons.bookmark_border,
            title: 'Bookmark',
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class _MoreOptionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _ShareOption(
            icon: Icons.flag_outlined,
            title: 'Report post',
            onTap: () {},
          ),
          _ShareOption(icon: Icons.block, title: 'Block user', onTap: () {}),
          _ShareOption(
            icon: Icons.volume_off,
            title: 'Mute user',
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
