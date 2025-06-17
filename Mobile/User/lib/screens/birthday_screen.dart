import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_sign_up/screens/gender_screen.dart';
import '../services/api_services.dart';

class BirthdayScreen extends StatefulWidget {
  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
final ApiService apiService = ApiService();

  BirthdayScreen({super.key});

}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime(2000, 1, 1);

  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      barrierColor: const Color(0x80204E4C),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF204E4C),
            colorScheme: const ColorScheme.light(primary: Color(0xFF204E4C)),
            dialogBackgroundColor: Colors.white,
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState((){
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
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
                    value: 0.33,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "What is your birthday?",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                height: 39.2 / 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your date of birth.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                height: 22.4 / 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: "yyyy/MM/dd",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: _showDatePicker,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                ElevatedButton(
                  onPressed: _dateController.text.isEmpty
                      ? null
                      : () async{
                    String bdate = _dateController.text.trim();
                    DateFormat inputFormat = DateFormat('yyyy/MM/dd');
                    DateTime pickedDate = inputFormat.parse(bdate);
                    DateTime utcDate = DateTime.utc(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      0, 0, 0,
                      );
                    String rfc3339Date = utcDate.toIso8601String(); // This includes the Z
                    await saveData(rfc3339Date, "dob");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GenderScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dateController.text.isEmpty ? const Color(0xFFCCCCCC) : const Color(0xFF204E4C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

