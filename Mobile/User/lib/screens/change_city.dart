import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeCityBottomSheet extends StatefulWidget {
  final String selectedCountry;
  final Function(String) onCitySelected;

  const ChangeCityBottomSheet({super.key, required this.selectedCountry, required this.onCitySelected});

  @override
  _ChangeCityBottomSheetState createState() => _ChangeCityBottomSheetState();
}

class _ChangeCityBottomSheetState extends State<ChangeCityBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  List<String> cities = [];
  List<String> filteredCities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final response = await http.get(Uri.parse('https://countriesnow.space/api/v0.1/countries'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> countries = data["data"];

      for (var country in countries) {
        if (country["country"] == widget.selectedCountry) {
          setState(() {
            cities = List<String>.from(country["cities"]);
            filteredCities = List.from(cities);
            isLoading = false;
          });
          return;
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void filterCities(String query) {
    setState(() {
      filteredCities = cities.where((city) => city.toLowerCase().contains(query.toLowerCase())).toList();
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
            onChanged: filterCities,
            decoration: InputDecoration(
              hintText: "Search city",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredCities[index]),
                  onTap: () {
                    widget.onCitySelected(filteredCities[index]);
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
