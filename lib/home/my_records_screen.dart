import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/models/record_model.dart';
import '../database/dao/dao_providers.dart';
import '../services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:healthli/widgets/bottom_navbar.dart';

class MyRecordsScreen extends ConsumerStatefulWidget {
  final String userId;
  const MyRecordsScreen({required this.userId, super.key});

  @override
  ConsumerState<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends ConsumerState<MyRecordsScreen> {
  late Future<List<Record>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    _recordsFuture = ref.read(recordDaoProvider).getAllRecords(widget.userId);
  }

  void _addRecord() async {
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    final unitController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Record'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(labelText: 'Value'),
                ),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: 'Unit'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final record = Record(
                    id: Uuid().v4(),
                    userId: widget.userId,
                    title: titleController.text,
                    value: valueController.text,
                    unit: unitController.text,
                    timestamp: DateTime.now().toIso8601String(),
                    isSynced: 0,
                  );
                  await ref.read(recordDaoProvider).insertRecord(record);
                  await SyncService.insertRecord(record.toMap(), widget.userId);
                  Navigator.pop(context);
                  setState(_loadRecords);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Records')),
      body: FutureBuilder<List<Record>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final records = snapshot.data!;
          if (records.isEmpty) return Center(child: Text('No records yet.'));
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, i) {
              final r = records[i];
              return ListTile(
                title: Text('${r.title}: ${r.value} ${r.unit}'),
                subtitle: Text(r.timestamp),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await ref.read(recordDaoProvider).deleteRecord(r.id);
                    setState(_loadRecords);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        child: Icon(Icons.add),
      ),
      // bottomNavigationBar: HealthBottomNavBar(
      //   currentIndex: 0,
      //   onTap: (index) {
      //     // Handle navigation
      //   },
      // ),
    );
  }
}
