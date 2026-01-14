// import 'package:flutter/material.dart';
// import 'package:personaltrainer_mobile/layouts/navBar.dart';
// import 'package:personaltrainer_mobile/models/exercise.dart';
// import 'package:personaltrainer_mobile/models/search_result.dart';
// import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';
// import 'package:personaltrainer_mobile/screens/exercise_details_screen.dart';
// import 'package:provider/provider.dart';

// class ExerciseListScreen extends StatefulWidget {
//   const ExerciseListScreen({super.key});

//   @override
//   State<ExerciseListScreen> createState() => _ExerciseListScreenState();
// }

// class _ExerciseListScreenState extends State<ExerciseListScreen> {
//   late ExerciseProvider provider;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     provider = context.read<ExerciseProvider>();
//   }

//   SearchResult<Exercise>? result = null;

//   @override
//   Widget build(BuildContext context) {
//     return NavBar(
//       'Lista vjezbi',
//       Container(child: Column(children: [_buildSearch(), _buildResultView()])),
//     );
//   }

//   TextEditingController _ftsEditingController = TextEditingController();
//   TextEditingController _exmgIdController = TextEditingController();

//   Widget _buildSearch() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _ftsEditingController,
//               decoration: InputDecoration(labelText: "Naziv ili sifra"),
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: _exmgIdController,
//               decoration: InputDecoration(labelText: "Sifra"),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               var filter = {
//                 'name': _ftsEditingController.text,
//                 'muscleGroupId': _exmgIdController.text,
//               };
//               result = await provider.get(filter: filter);
//               setState(() {});

//               print(result);
//             },
//             child: Text("Pretaga"),
//           ),
//           SizedBox(width: 8),
//           ElevatedButton(
//             onPressed: () async {
//               // add async logic
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (context) => ExerciseDetailsScreen(),
//                 ),
//               );
//             },
//             child: Text("Dodaj"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultView() {
//     return Expanded(
//       child: SingleChildScrollView(
//         child: DataTable(
//           columns: [
//             DataColumn(label: Text('ID'), numeric: true),
//             DataColumn(label: Text('Naziv')),
//             DataColumn(label: Text("Slika")),
//           ],
//           rows:
//               result?.result
//                   .map(
//                     (e) => DataRow(
//                       cells: [
//                         DataCell(Text(e.id.toString())),
//                         DataCell(Text(e.name.toString())),
//                         DataCell(Text(e.picture.toString())),
//                       ],
//                     ),
//                   )
//                   .toList()
//                   .cast<DataRow>() ??
//               [],
//         ),
//       ),
//     );
//   }
// }
