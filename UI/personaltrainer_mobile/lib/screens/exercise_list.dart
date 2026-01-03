import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/master_screen.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  ExerciseProvider provider = ExerciseProvider();
  SearchResult<Exercise>? result = null;

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Lista vjezbi',
      Container(child: Column(children: [_buildSearch(), _buildResultView()])),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Naziv ili sifra"),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(decoration: InputDecoration(labelText: "Sifra")),
          ),
          ElevatedButton(
            onPressed: () async {
              
                result = await provider.get();
              setState(() {
              });

              print(result);
            },
            child: Text("Pretaga"),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              // add async logic
            },
            child: Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID'), numeric: true),
            DataColumn(label: Text('Naziv')),
          ],
          rows: result?.result.map((e) =>
          DataRow(cells: [
            DataCell(Text(e.id.toString())),
            DataCell(Text(e.name.toString())),
          ])).toList().cast<DataRow>() ?? [],
        ),
      ),
    );
  }
}
