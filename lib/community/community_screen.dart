import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthli/database/dao/dao_providers.dart';
import 'package:uuid/uuid.dart';
import 'providers.dart';
import 'post_card.dart';
import 'create_post_sheet.dart';
import '../database/models/post_model.dart';
import 'sync_service.dart';
import 'notifications_provider.dart';
import '../database/models/notification_model.dart';

class CommunityTab extends ConsumerStatefulWidget {
  final String userId;
  const CommunityTab({super.key, required this.userId});

  @override
  ConsumerState<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<CommunityTab>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isSearching = false;
  bool _isSyncing = false;
  final FocusNode _searchFocusNode = FocusNode();

  final List<Tab> _tabs = const [
    Tab(text: 'For You'),
    Tab(text: 'Saved'),
    //   Tab(text: 'Notifications'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearching = _searchFocusNode.hasFocus;
    });
  }

  void _showCreatePostDialog() async {
    HapticFeedback.mediumImpact();
    final controller = TextEditingController();
    final userDao = ref.read(userDaoProvider);
    final user = await userDao.getUserById(widget.userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => CreatePostSheet(
            controller: controller,
            onPost: () async {
              final content = controller.text.trim();
              if (content.isNotEmpty) {
                final post = Post(
                  id: const Uuid().v4(),
                  userId: user!.id,
                  content: content,
                  likes: 0,
                  comments: const [],
                  savedBy: const [],
                  isSynced: false,
                  createdAt: DateTime.now().toIso8601String(),
                );
                await ref.read(postDaoProvider).insertPost(post);
                await CommunitySyncService.syncAllPendingToFirestore(
                  post.userId,
                );
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              }
            },
          ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isSyncing = true);
    HapticFeedback.mediumImpact();

    try {
      await CommunitySyncService.syncAllPendingToFirestore("currentUserId");
      await CommunitySyncService.fetchPostsFromFirestoreAndCache();

      // Refresh the posts provider to show updated content
      ref.refresh(postsProvider);

      HapticFeedback.mediumImpact();
    } catch (e) {
      HapticFeedback.heavyImpact();
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              toolbarHeight: 60,
              title: _buildSearchBar(),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE1E8ED), width: 0.5),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.green[600],
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.green[600],
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    tabs: _tabs,
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildForYouTab(postsAsync),
            _buildSavedTab(),
            //_buildNotificationsTab(),
          ],
        ),
      ),
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: _showCreatePostDialog,
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.edit, size: 24),
              )
              : null,
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FA),
              borderRadius: BorderRadius.circular(18),
              border:
                  _isSearching
                      ? Border.all(color: Colors.green[600]!, width: 1)
                      : null,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search Community',
                hintStyle: const TextStyle(
                  color: Color(0xFF657786),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color:
                      _isSearching
                          ? Colors.green[600]
                          : const Color(0xFF657786),
                  size: 18,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF657786),
                            size: 18,
                          ),
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF14171A)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _SyncButton(onPressed: _handleRefresh, isSyncing: _isSyncing),
      ],
    );
  }

  Widget _buildForYouTab(AsyncValue<List<Post>> postsAsync) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.green[600],
      backgroundColor: Colors.white,
      child: postsAsync.when(
        data: (posts) {
          final filteredPosts =
              _searchController.text.isEmpty
                  ? posts
                  : posts
                      .where(
                        (p) => p.content.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        ),
                      )
                      .toList();

          if (filteredPosts.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              if (_searchController.text.isEmpty) ...[
                // Stories/Status section (placeholder for future feature)
                //   SliverToBoxAdapter(
                //     child: Container(
                //       height: 80,
                //       padding: const EdgeInsets.symmetric(vertical: 8),
                //       decoration: const BoxDecoration(
                //         color: Colors.white,
                //         border: Border(
                //           bottom: BorderSide(
                //             color: Color(0xFFE1E8ED),
                //             width: 0.5,
                //           ),
                //         ),
                //       ),
                //       child: ListView.builder(
                //         scrollDirection: Axis.horizontal,
                //         padding: const EdgeInsets.symmetric(horizontal: 16),
                //         itemCount: 5,
                //         itemBuilder: (context, index) {
                //           return Container(
                //             width: 64,
                //             margin: const EdgeInsets.only(right: 12),
                //             child: Column(
                //               children: [
                //                 Container(
                //                   width: 56,
                //                   height: 56,
                //                   decoration: BoxDecoration(
                //                     color: Colors.green[100],
                //                     shape: BoxShape.circle,
                //                     border: Border.all(
                //                       color: Colors.green[300]!,
                //                       width: 2,
                //                     ),
                //                   ),
                //                   child: Icon(
                //                     index == 0 ? Icons.add : Icons.person,
                //                     color: Colors.green[600],
                //                     size: 24,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           );
                //         },
                //       ),
                //     ),
                //   ),
              ],

              // Posts list
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return PostCard(
                    post: filteredPosts[index],
                    currentUserId: widget.userId,
                  );
                }, childCount: filteredPosts.length),
              ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildSavedTab() {
    final savedPostsAsync = ref.watch(savedPostsProvider(widget.userId));
    return savedPostsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Save posts for later',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookmark posts to easily find them again in the future.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index], currentUserId: widget.userId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load saved posts: $e')),
    );
  }

  Widget _buildNotificationsTab() {
    return Consumer(
      builder: (context, ref, _) {
        final asyncNotifications = ref.watch(
          notificationsProvider(widget.userId),
        );
        return asyncNotifications.when(
          data:
              (notifications) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE1E8ED),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              // Mark all as read
                              // TODO: implement mark all as read
                            },
                            child: Text(
                              'Mark all as read',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final notification = notifications[index];
                      return _buildNotificationTile(notification);
                    }, childCount: notifications.length),
                  ),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => Center(child: Text('Failed to load notifications: $e')),
        );
      },
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    IconData icon;
    Color color;
    String title = notification.message;
    String subtitle = '';
    if (notification.type == 'like') {
      icon = Icons.favorite;
      color = Colors.red[500]!;
      subtitle = 'Your post was liked';
    } else if (notification.type == 'comment') {
      icon = Icons.chat_bubble;
      color = Colors.green[600]!;
      subtitle = 'New comment on your post';
    } else {
      icon = Icons.notifications;
      color = Colors.blue[500]!;
    }
    return Container(
      decoration: BoxDecoration(
        color: !notification.isRead ? Colors.green[50] : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE1E8ED), width: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                !notification.isRead ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
            color: Colors.grey[900],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimeAgo(notification.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing:
            !notification.isRead
                ? Icon(Icons.circle, color: Colors.green[400], size: 12)
                : null,
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Community',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When people you follow share posts, you\'ll see them here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showCreatePostDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Share your first post',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildShimmerPost();
          }, childCount: 5),
        ),
      ],
    );
  }

  Widget _buildShimmerPost() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE1E8ED), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We couldn\'t load the posts. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SyncButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSyncing;

  const _SyncButton({required this.onPressed, required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: IconButton(
        onPressed: isSyncing ? null : onPressed,
        icon:
            isSyncing
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green[600]!,
                    ),
                  ),
                )
                : Icon(Icons.sync, color: Colors.green[600], size: 18),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isUnread;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.isUnread,
  });
}
