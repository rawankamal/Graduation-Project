import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeCountryBottomSheet extends StatefulWidget {
  final Function(String) onCountrySelected;

  const ChangeCountryBottomSheet({super.key, required this.onCountrySelected});

  @override
  _ChangeCountryBottomSheetState createState() =>
      _ChangeCountryBottomSheetState();
}

class _ChangeCountryBottomSheetState extends State<ChangeCountryBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final response =
    await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        countries = data
            .map((country) => country["name"]["common"].toString())
            .toList();
        countries.sort();
        filteredCountries = List.from(countries);
        isLoading = false;
      });
    }
  }

  void filterCountries(String query) {
    setState(() {
      filteredCountries = countries
          .where((country) =>
          country.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 500,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: filterCountries,
            decoration: InputDecoration(
              hintText: "Search country",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredCountries[index]),
                  onTap: () {
                    widget.onCountrySelected(filteredCountries[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
