import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
final ApiService apiService = ApiService();

  AddressScreen({super.key});

}

class _AddressScreenState extends State<AddressScreen> {
  String? selectedCountry;
  String? selectedCity;

  void _selectCountry() async {
    final country = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const CountrySelectionScreen(),
    );
    if (country != null) {
      setState(() {
        selectedCountry = country["name"];
        saveData(selectedCountry.toString(), "country");
        selectedCity = null;
      });
    }
  }

  void _selectCity() async {
    if (selectedCountry == null) return;

    final city = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CitySelectionScreen(selectedCountry: selectedCountry!),
    );
    if (city != null) {
      setState(() {
        selectedCity = city;
        saveData(selectedCity.toString(), "city");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNextEnabled = selectedCountry != null && selectedCity != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 29),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "What is your Address?",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                height: 39.2 / 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Enter your country and city.",
              style: TextStyle(fontSize: 14, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _selectCountry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedCountry ?? "Country", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _selectCity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedCity ?? "City", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Spacer(),

            Column(
              children: [
                ElevatedButton(
                 onPressed: isNextEnabled ? () async{
                   final prefs = await SharedPreferences.getInstance();
                     String fname = prefs.getString('fname').toString();
                     String lname = prefs.getString('lname').toString();
                     String bio = prefs.getString('bio').toString();
                     String token = prefs.getString('token').toString();
                     String gender = prefs.getString('gender').toString();
                     String bdate = prefs.getString('dob').toString();
                     String country = prefs.getString('country').toString();
                     String city = prefs.getString('city').toString();

                     Map<String, dynamic> userData = {
                        "firstName": fname,
                        "lastName": lname,
                        "bio": bio,
                        "dateOfBirth":bdate,
                        "gender":gender,
                        "country": country,
                        "city": city,
                        "superviorRole":"Doctor"
                         };
                    await apiService.register(context,token,userData);
                   
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isNextEnabled ? const Color(0xFF204E4C) : Colors.grey[400],
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: ()async {
                     final prefs = await SharedPreferences.getInstance();
                     String fname = prefs.getString('fname').toString();
                     String lname = prefs.getString('lname').toString();
                     String bio = prefs.getString('bio').toString();
                     String token = prefs.getString('token').toString();
                     String gender = prefs.getString('gender').toString();
                     String bdate = prefs.getString('dob').toString();
                    
                     Map<String, dynamic> userData = {
                        "firstName": fname,
                        "lastName": lname,
                        "bio": bio,
                        "DateOfBirth":bdate,
                        "Gender":gender,
                        "Country": "Egypt",
                        "City": "Cairo",
                        "superviorRole":"Doctor"
                         };
                    await apiService.register(context,token,userData);
                   
                  },
                  child: const Text("Skip", style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  _CountrySelectionScreenState createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
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
  try {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        countries = data.map((country) {
          return {
            "name": country["name"]["common"],
            "flag": country["flags"]["png"],
          };
        }).toList();
        filteredCountries = List.from(countries);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load countries")),
      );
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error loading countries: $e")),
    );
  }
}


  void filterCountries(String query) {
    setState(() {
      filteredCountries = countries
          .where((country) => country["name"].toLowerCase().contains(query.toLowerCase()))
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
              hintText: "Search countries",
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
                  leading: Image.network(filteredCountries[index]["flag"], width: 30),
                  title: Text(filteredCountries[index]["name"]),
                  onTap: () => Navigator.pop(context, filteredCountries[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CitySelectionScreen extends StatefulWidget {
  final String selectedCountry;

  const CitySelectionScreen({super.key, required this.selectedCountry});

  @override
  _CitySelectionScreenState createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  List<String> cities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCities(widget.selectedCountry);
  }

  Future<void> fetchCities(String country) async {
    final response = await http.get(Uri.parse('https://countriesnow.space/api/v0.1/countries'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> countries = data["data"];

      for (var item in countries) {
        if (item["country"] == country) {
          setState(() {
            cities = List<String>.from(item["cities"]);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 500,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cities[index]),
            onTap: () => Navigator.pop(context, cities[index]),
          );
        },
      ),
    );
  }
}
