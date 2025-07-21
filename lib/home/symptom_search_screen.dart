// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../database/dao/dao_providers.dart';
// import '../database/models/symptom_model.dart';

// class SymptomSearchScreen extends ConsumerStatefulWidget {
//   const SymptomSearchScreen({super.key});
//   @override
//   ConsumerState<SymptomSearchScreen> createState() =>
//       _SymptomSearchScreenState();
// }

// class _SymptomSearchScreenState extends ConsumerState<SymptomSearchScreen> {
//   String query = '';
//   List<Symptom> results = [];

//   void _search() async {
//     final dao = ref.read(symptomDaoProvider);
//     results = await dao.searchSymptoms(query);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Search Symptoms')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               onChanged: (v) => query = v,
//               decoration: InputDecoration(labelText: 'Search symptoms'),
//             ),
//           ),
//           ElevatedButton(onPressed: _search, child: Text('Search')),
//           Expanded(
//             child: ListView.builder(
//               itemCount: results.length,
//               itemBuilder:
//                   (context, i) => ListTile(
//                     title: Text(results[i].name),
//                     subtitle: Text(results[i].description),
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
