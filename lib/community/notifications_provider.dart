import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao/dao_providers.dart';
import '../database/dao/notification_dao.dart';
import '../database/models/notification_model.dart';
import 'package:healthli/database/db_helper.dart';

final notificationsProvider =
    FutureProvider.family<List<NotificationItem>, String>((ref, userId) async {
      final db = await DatabaseHelper().database;
      final dao = NotificationDao(db);
      return await dao.getNotificationsForUser(userId);
    });
