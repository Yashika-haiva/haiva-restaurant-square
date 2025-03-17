// import 'package:language_picker/language_picker_dropdown_controller.dart';
// import 'package:language_picker/languages.dart';
// import 'package:language_picker/utils/typedefs.dart';
// import 'package:flutter/material.dart';
//
// /// A customizable [DropdownButton] for selecting multiple languages.
// class LanguagePicker extends StatefulWidget {
//   LanguagePicker({
//     this.itemBuilder,
//     this.controller,
//     this.initialValues,
//     this.onValuePicked,
//     this.languages,
//   });
//
//   final ItemBuilder? itemBuilder;
//   final List<Language>? initialValues;
//   final ValueChanged<List<Language>>? onValuePicked;
//   final LanguagePickerDropdownController? controller;
//   final List<Language>? languages;
//
//   @override
//   _LanguagePickerState createState() => _LanguagePickerState();
// }
//
// class _LanguagePickerState extends State<LanguagePicker> {
//   late List<Language> _languages;
//   late Set<String> _selectedLanguages;
//
//   @override
//   void initState() {
//     _languages = widget.languages ?? Languages.defaultLanguages;
//     _selectedLanguages =
//         widget.initialValues?.map((e) => e.isoCode).toSet() ?? {};
//
//     widget.controller?.addListener(() {
//       setState(() {
//         final currentIsoCode = widget.controller!.value.isoCode;
//         if (!_selectedLanguages.contains(currentIsoCode)) {
//           _selectedLanguages.add(currentIsoCode);
//         }
//       });
//     });
//
//     super.initState();
//   }
//
//   void _toggleSelection(Language language) {
//     setState(() {
//       if (_selectedLanguages.contains(language.isoCode)) {
//         _selectedLanguages.remove(language.isoCode);
//       } else {
//         _selectedLanguages.add(language.isoCode);
//       }
//       widget.onValuePicked?.call(
//         _languages
//             .where((l) => _selectedLanguages.contains(l.isoCode))
//             .toList(),
//       );
//     });
//   }
//
//   String _getSelectedLanguagesText() {
//     List<String> selectedLanguageNames =
//         _languages
//             .where((language) => _selectedLanguages.contains(language.isoCode))
//             .map((language) => language.name)
//             .toList();
//     return selectedLanguageNames.join(', ');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<DropdownMenuItem<Language>> items =
//         _languages.map((language) {
//           return DropdownMenuItem<Language>(
//             value: language,
//             child: CheckboxListTile(
//               title: Text("${language.name} (${language.isoCode})"),
//               value: _selectedLanguages.contains(language.isoCode),
//               onChanged: (_) => _toggleSelection(language),
//             ),
//           );
//         }).toList();
//
//     return DropdownButtonHideUnderline(
//       child: DropdownButton<Language>(
//         isExpanded: true,
//         onChanged: (_) {},
//         items: items,
//         value: null,
//         hint: Text(
//           _getSelectedLanguagesText(),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }
