import 'package:sqflite/sqflite.dart';
import '../models/comment_model.dart';
import '../db_helper.dart';

class CommentDao {
  Future<Database> get _db async => await DatabaseHelper().database;

  Future<List<Comment>> getCommentsForPost(String postId) async {
    final db = await _db;
    final maps = await db.query(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at ASC',
    );
    return maps.map((e) => Comment.fromMap(e)).toList();
  }

  Future<void> insertComment(Comment comment) async {
    final db = await _db;
    await db.insert(
      'comments',
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteComment(String id) async {
    final db = await _db;
    await db.delete('comments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateComment(Comment comment) async {
    final db = await _db;
    await db.update(
      'comments',
      comment.toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  // Firestore sync helpers (pseudo, to be implemented in sync_service)
  // Future<void> syncCommentsToFirestore(List<Comment> comments) async { ... }
  // Future<List<Comment>> fetchCommentsFromFirestore(String postId) async { ... }
}
