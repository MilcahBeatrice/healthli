import 'package:sqflite/sqflite.dart';
import '../models/post_model.dart';
import '../db_helper.dart';

class PostDao {
  Future<Database> get _db async => await DatabaseHelper().database;

  Future<List<Post>> getAllPosts() async {
    final db = await _db;
    final maps = await db.query('posts', orderBy: 'created_at DESC');
    return maps.map((e) => Post.fromMap(e)).toList();
  }

  Future<void> insertPost(Post post) async {
    final db = await _db;
    await db.insert(
      'posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePost(Post post) async {
    final db = await _db;
    await db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<void> deletePost(String id) async {
    final db = await _db;
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // Get all posts saved by a specific user
  Future<List<Post>> getSavedPosts(String userId) async {
    final db = await _db;
    final maps = await db.query('posts');
    return maps
        .map((e) => Post.fromMap(e))
        .where((post) => post.savedBy.contains(userId))
        .toList();
  }

  // Save a post for a user
  Future<void> savePost(String postId, String userId) async {
    final db = await _db;
    final postMap =
        (await db.query('posts', where: 'id = ?', whereArgs: [postId])).first;
    final post = Post.fromMap(postMap);
    if (!post.savedBy.contains(userId)) {
      await updatePost(
        Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          likes: post.likes,
          comments: post.comments,
          savedBy: [...post.savedBy, userId],
          isSynced: false,
          createdAt: post.createdAt,
        ),
      );
    }
  }

  // Unsave a post for a user
  Future<void> unsavePost(String postId, String userId) async {
    final db = await _db;
    final postMap =
        (await db.query('posts', where: 'id = ?', whereArgs: [postId])).first;
    final post = Post.fromMap(postMap);
    if (post.savedBy.contains(userId)) {
      await updatePost(
        Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          likes: post.likes,
          comments: post.comments,
          savedBy: post.savedBy.where((id) => id != userId).toList(),
          isSynced: false,
          createdAt: post.createdAt,
        ),
      );
    }
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    final db = await _db;
    final postMap =
        (await db.query('posts', where: 'id = ?', whereArgs: [postId])).first;
    final post = Post.fromMap(postMap);
    // Prevent double-like by same user (optional: add likedBy list)
    final updatedPost = Post(
      id: post.id,
      userId: post.userId,
      content: post.content,
      likes: post.likes + 1,
      comments: post.comments,
      savedBy: post.savedBy,
      isSynced: false,
      createdAt: post.createdAt,
    );
    await updatePost(updatedPost);
  }

  // Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    final db = await _db;
    final postMap =
        (await db.query('posts', where: 'id = ?', whereArgs: [postId])).first;
    final post = Post.fromMap(postMap);
    final updatedPost = Post(
      id: post.id,
      userId: post.userId,
      content: post.content,
      likes: post.likes > 0 ? post.likes - 1 : 0,
      comments: post.comments,
      savedBy: post.savedBy,
      isSynced: false,
      createdAt: post.createdAt,
    );
    await updatePost(updatedPost);
  }
}
