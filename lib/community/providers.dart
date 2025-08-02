import '../database/models/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao/post_dao.dart';
import '../database/dao/comment_dao.dart';
import '../database/models/post_model.dart';
import 'dart:async';
import 'sync_service.dart';
import '../database/dao/emergency_contact_dao.dart';
import '../database/models/emergency_contact_model.dart';

// Comments provider: fetches all comments for a given post
final commentsForPostProvider = FutureProvider.family<List<Comment>, String>((
  ref,
  postId,
) async {
  // Fetch from Firestore and cache locally before returning
  await CommunitySyncService.fetchCommentsFromFirestoreAndCache(postId);
  final dao = ref.watch(commentDaoProvider);
  return await dao.getCommentsForPost(postId);
});

final postDaoProvider = Provider((ref) => PostDao());
final commentDaoProvider = Provider((ref) => CommentDao());
final emergencyContactDaoProvider = Provider((ref) => EmergencyContactDao());

final postsProvider = StreamProvider.autoDispose((ref) {
  // Fetch from Firestore every minute
  final controller = StreamController<List<Post>>();
  Timer? timer;

  Future<void> fetchAndEmit() async {
    await CommunitySyncService.fetchPostsFromFirestoreAndCache();
    final dao = ref.read(postDaoProvider);
    final posts = await dao.getAllPosts();
    controller.add(posts);
  }

  fetchAndEmit();
  timer = Timer.periodic(const Duration(minutes: 1), (_) => fetchAndEmit());

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

// Provider for saved posts for a user
final savedPostsProvider = FutureProvider.family<List<Post>, String>((
  ref,
  userId,
) async {
  final dao = ref.watch(postDaoProvider);
  return await dao.getSavedPosts(userId);
});

final emergencyContactsProvider =
    FutureProvider.family<List<EmergencyContact>, String>((ref, userId) async {
      final dao = ref.watch(emergencyContactDaoProvider);
      return await dao.getAllContacts(userId);
    });
