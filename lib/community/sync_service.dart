import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthli/database/db_helper.dart';
import '../database/dao/post_dao.dart';
import '../database/dao/comment_dao.dart';
import '../database/dao/emergency_contact_dao.dart';
import '../database/models/post_model.dart';
import '../database/models/comment_model.dart';
import '../database/models/emergency_contact_model.dart';
import '../database/models/notification_model.dart';
import '../database/dao/notification_dao.dart';

class CommunitySyncService {
  static Future<void> syncAllPendingToFirestore(String userId) async {
    final postDao = PostDao();
    final commentDao = CommentDao();

    // Sync posts
    final posts = await postDao.getAllPosts();
    for (final post in posts.where((p) => !p.isSynced)) {
      // Use Firestore serialization for correct savedBy handling
      final postMap = post.toFirestore();
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .set(postMap);
      await postDao.updatePost(
        Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          likes: post.likes,
          comments: post.comments,
          savedBy: post.savedBy,
          isSynced: true,
          createdAt: post.createdAt,
        ),
      );
    }

    // Sync comments
    final comments = await commentDao.getCommentsForPost(
      '',
    ); // get all comments
    for (final comment in comments.where((c) => !c.isSynced)) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId)
          .collection('comments')
          .doc(comment.id)
          .set(comment.toFirestore());
      await commentDao.updateComment(
        Comment(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          //   username: comment.username,
          text: comment.text,
          createdAt: comment.createdAt,
          isSynced: true,
        ),
      );
    }
  }

  static Future<void> fetchPostsFromFirestoreAndCache() async {
    final postDao = PostDao();
    final snapshot =
        await FirebaseFirestore.instance
            .collection('posts')
            .orderBy('created_at', descending: true)
            .get();
    for (final doc in snapshot.docs) {
      final post = Post.fromFirestore(doc.data());
      await postDao.insertPost(post);
    }
  }

  static Future<void> fetchCommentsFromFirestoreAndCache(String postId) async {
    final commentDao = CommentDao();
    final snapshot =
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .orderBy('created_at', descending: false)
            .get();
    for (final doc in snapshot.docs) {
      final comment = Comment.fromFirestore(doc.data());
      await commentDao.insertComment(comment);
    }
  }

  static Future<void> createLikeNotification({
    required String postId,
    required String postOwnerId,
    required String actorId,
  }) async {
    // Fetch actor name (optional: pass as param or fetch from userDao)
    final actorName = actorId; // Replace with actual name lookup
    final notification = NotificationItem(
      userId: postOwnerId,
      type: 'like',
      postId: postId,
      actorId: actorId,
      actorName: actorName,
      message: '$actorName liked your post',
    );
    // Save to local DB
    final db = await DatabaseHelper().database;
    final notificationDao = NotificationDao(db);
    await notificationDao.insertNotification(notification);
    // Optionally: push to Firestore
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notification.toMap());
  }

  static Future<void> createCommentNotification({
    required String postId,
    required String postOwnerId,
    required String actorId,
    required String commentId,
  }) async {
    final actorName = actorId; // Replace with actual name lookup
    final notification = NotificationItem(
      userId: postOwnerId,
      type: 'comment',
      postId: postId,
      commentId: commentId,
      actorId: actorId,
      actorName: actorName,
      message: '$actorName commented on your post',
    );
    final db = await DatabaseHelper().database;
    final notificationDao = NotificationDao(db);
    await notificationDao.insertNotification(notification);
    // Optionally: push to Firestore
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notification.toMap());
  }
}

class EmergencySyncService {
  static Future<void> syncAllPendingToFirestore(String userId) async {
    final dao = EmergencyContactDao();
    final contacts = await dao.getAllContacts(userId);
    for (final contact in contacts.where((c) => c.isSynced == 0)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .doc(contact.id)
          .set(contact.toFirestore());
      await dao.updateContact(
        EmergencyContact(
          id: contact.id,
          userId: contact.userId,
          name: contact.name,
          phone: contact.phone,
          relationship: contact.relationship,
          isSynced: 1,
        ),
      );
    }
  }

  static Future<void> fetchContactsFromFirestoreAndCache(String userId) async {
    final dao = EmergencyContactDao();
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('emergency_contacts')
            .get();
    for (final doc in snapshot.docs) {
      final contact = EmergencyContact.fromFirestore(doc.data());
      await dao.insertContact(contact);
    }
  }
}
