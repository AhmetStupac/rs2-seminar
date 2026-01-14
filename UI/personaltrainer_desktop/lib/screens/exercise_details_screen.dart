// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:personaltrainer_mobile/layouts/navBar.dart';

// class ExerciseDetailsScreen extends StatefulWidget {
//   ExerciseDetailsScreen({super.key});

//   @override
//   State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
// }

// class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
//   final _formKey = GlobalKey<FormBuilderState>();
//   Map<String, dynamic> _initialValue = {};

//   @override
//   Widget build(BuildContext context) {
//     return nav(
//       "Detalji",
//       Column(children: [_buildForm(), _saveRow()]),
//     );
//   }

//   Widget _buildForm() {
//     return FormBuilder(
//       key: _formKey,
//       initialValue: _initialValue,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(child: FormBuilderTextField(name: "id")),
//                 SizedBox(width: 10),
//                 Expanded(child: FormBuilderTextField(name: "naziv")),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _saveRow() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               _formKey.currentState?.saveAndValidate();
//               debugPrint(_formKey.currentState?.value.toString());
//             },
//             child: Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
// }
