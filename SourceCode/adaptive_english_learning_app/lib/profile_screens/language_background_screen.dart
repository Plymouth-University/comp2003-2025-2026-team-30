import 'package:flutter/material.dart';

class LanguageBackgroundScreen extends StatefulWidget {
  final VoidCallback onNext;

  const LanguageBackgroundScreen({super.key, required this.onNext});

  @override
  State<LanguageBackgroundScreen> createState() =>
      _LanguageBackgroundScreenState();
}

class _LanguageBackgroundScreenState
    extends State<LanguageBackgroundScreen> {

  String? nativeLanguage;
  List<String> selectedLanguages = [];
  String? region;

  final List<String> languages = [
    "Spanish",
    "Mandarin",
    "Hindi",
    "Arabic",
    "French",
    "Portuguese",
    "Russian",
    "Japanese",
    "German"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F8),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),

            /// TITLE
            const Text(
              "Language Background",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Help us understand your linguistic background",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            /// Native Language Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select your native language",
                border: OutlineInputBorder(),
              ),
              initialValue: nativeLanguage,
              items: languages
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  nativeLanguage = value;
                });
              },
            ),

            const SizedBox(height: 25),

            /// Other Languages (Selectable Chips)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: languages.map((lang) {
                final isSelected = selectedLanguages.contains(lang);

                return ChoiceChip(
                  label: Text(lang),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedLanguages.add(lang);
                      } else {
                        selectedLanguages.remove(lang);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const Spacer(),

            /// NEXT BUTTON
            ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
              ),
              child: const Text("Next"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}