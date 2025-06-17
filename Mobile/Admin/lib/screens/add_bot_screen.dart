import 'package:admin/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adminService adminservice = adminService();
var admin =adminService();

class AddBotScreen extends StatefulWidget {
  @override
  _AddBotScreenState createState() => _AddBotScreenState();
}

class _AddBotScreenState extends State<AddBotScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _guidelinesController = TextEditingController();
  bool _fieldsFilled = false;
  String? _selectedBotImagePath;


  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkFields);
    _bioController.addListener(_checkFields);
    _guidelinesController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _guidelinesController.dispose();
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _fieldsFilled = _nameController.text.isNotEmpty &&
          _bioController.text.isNotEmpty &&
          _guidelinesController.text.isNotEmpty;
    });
  }

  void showBotPicturePicker(BuildContext context, Function(String) onImageSelected) {
    final List<String> pngImages = List.generate(28, (i) => 'assets/bots/bot${i + 1}.png');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bot Picture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  itemCount: pngImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onImageSelected(pngImages[index]);
                        Navigator.pop(context);
                      },
                      child: Image.asset(pngImages[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF204E4C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: MediaQuery.of(context).size.height * 0.07,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Add New Bot',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF333333)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showBotPicturePicker(context, (selectedImagePath) {
                        setState(() {
                          _selectedBotImagePath = selectedImagePath;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: _selectedBotImagePath != null
                                ? Image.asset(
                              _selectedBotImagePath!,
                              fit: BoxFit.cover,
                            )
                                : SvgPicture.asset(
                              "assets/images/mdi_robot.svg",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Choose Picture',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF204E4C),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBotImagePath = null;
                                });
                              },
                               child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.6,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFFFF4B4B),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextInput(
                    label: 'Bot Name',
                    hint: 'Bot Name',
                    controller: _nameController,
                  ),
                  CustomTextInput(
                    label: 'Bot Bio',
                    hint: 'Write a short introduction about the bot\'s personality and role.',
                    controller: _bioController,
                    maxLines: 3,
                  ),
                  CustomTextInput(
                    label: 'Bot Guidelines',
                    hint: 'Define how this bot should interact with users.',
                    controller: _guidelinesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _fieldsFilled
                      ? ()async {
                    final prefs = await SharedPreferences.getInstance();
                    String token =prefs.getString("token").toString();
                    final botData ={
                      "name": _nameController.text,
                      "context": _guidelinesController.text,
                      "bio": _bioController.text
                    };
                    await admin.addBot(context, botData, token);
                    Navigator.of(context).pop();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _fieldsFilled ? const Color(0xFF204E4C) : const Color(0xFFB3B3B3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontSize: 16, color: Color(0xffFBFBFB)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const CustomTextInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
