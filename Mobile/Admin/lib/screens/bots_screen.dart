import 'package:admin/services/admin_services.dart';
import 'package:admin/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_settings/account_screen.dart';
import 'add_bot_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'home_notifications/home_screen.dart';
import 'patients/patients_screen.dart';
import 'supervisors/supervisors_screen.dart';


final ApiService apiService = ApiService();
final adminService adminservice = adminService();
var admin =adminService();

class BotsScreen extends StatefulWidget {
  @override
  _BotsScreenState createState() => _BotsScreenState();
}

class _BotsScreenState extends State<BotsScreen> {
  List<Map<String, dynamic>> bots = [];
  Future<void> loadBots() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    try {
      final botData = await admin.getBots(token);
      if(botData != null){
       setState(() {
 
       bots = (botData as List)
      .map((item) => {
        'id': item['id'].toString(),
        'name': item['name'].toString(),
        'icon': item['image'].toString(),
        'bio' :item['bio'].toString(),
          })
      .toList();
});
      }
      else{print("No bots found!");}
    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load bots: ${e.toString()}")),
);
    }
  }

 @override
  void initState() {
    super.initState();
    loadBots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Bots',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Color(0xff333333),
            letterSpacing: 0.001,
          ),
        ),
      ),
      body: bots.isEmpty
          ? Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/total bots.svg',
                  height: 20,
                  width: 20,
                  color: const Color(0xFF666666),
                ),
                const SizedBox(width: 8),
                Text(
                  '${bots.length} Total Bots',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/no bots.png',
                  height: 170,
                ),
                const SizedBox(height: 20),
                const Text(
                  "No Bots",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Please click + to add new bot",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                    letterSpacing: 0.001,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/total bots.svg',
                    height: 20,
                    width: 20,
                    color: const Color(0xFF666666),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bots.length} Total Bots',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF204E4C),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bots.length,
              itemBuilder: (context, index) {
                return _buildBotCard(bots[index]);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF204E4C),
        shape: const CircleBorder(),
        onPressed: () async {
          await showDialog(
            context: context,
            barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
            builder: (context) => AddBotScreen(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        selectedLabelStyle: const TextStyle(fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()),);
          }
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientsScreen()),);
          }
          if (index == 3) {
            Navigator.push(context,MaterialPageRoute(builder: (context) => SupervisorsScreen()),);
          }
          if (index == 4) {
            Navigator.push(context,MaterialPageRoute(builder: (context) => const AccountScreen()),);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'Bots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Supervisors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildBotCard(Map<String, dynamic> bot) {
    return Slidable(
      key: ValueKey(bot['name']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.30,
        children: [
          CustomSlidableAction(
            onPressed: (_) {},
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showEditBotDialog(context, bot);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF204E4C),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.edit_outlined, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Delete button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showDeleteConfirmationDialog(context, bot);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4B4B),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(bot['image'] ?? 'assets/bots/bot4.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bot['name'],
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: Color(0xff333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bot['bio'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Color(0xff666666),
                          letterSpacing: 0.001,
                        ),
                      ),
                      const SizedBox(height: 0),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(
              height: 24,
              color: Color(0xffCCCCCC),
              thickness: 1,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  _showBotDetailsDialog(context, bot);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details ',
                      style: TextStyle(
                        color: Color(0xFF204E4C),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF204E4C),
                      size: 15,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context,
      Map<String, dynamic> bot) {
      final String botId = bot['id'];
    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Vector.svg',
                        width: 40,
                        height: 40,
                      ),
                      SvgPicture.asset(
                        'assets/images/trash.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xff333333),
                          fontSize: 14,
                          height: 1,
                        ),
                        children: [
                          const TextSpan(
                            text: "Are you sure you want to delete ",
                            style: TextStyle(
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          TextSpan(
                            text: "${bot['name']}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text: "? This can not be undone",
                            style: TextStyle(
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Column(
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4B4B),
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                             onPressed: () async{
                              final prefs = await SharedPreferences.getInstance();
                              String token =prefs.getString("token").toString();
                              await apiService.deleteBot(context, token, botId);
                              Navigator.of(context).pop();
                            
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                  color: Color(0xffFBFBFB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBotDialog(BuildContext context, Map<String, dynamic> bot) {
    final String botId = bot['id'];
    final TextEditingController nameController = TextEditingController(text: bot['name']);
    final TextEditingController bioController = TextEditingController(text: bot['bio']);
    final TextEditingController guidelinesController = TextEditingController(text: bot['guidelines'] ?? 'No guidelines allowed for this bot');
    String? selectedImage = bot['image'] ?? 'assets/bots/bot4.png';

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                        Text(
                          bot['name'],
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            height: 1.2,
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
                              showBotPicturePicker(context, (imagePath) {
                                setDialogState(() {
                                  selectedImage = imagePath;
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
                                    borderRadius: BorderRadius.circular(31.58),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(31.58),
                                    child: Image.asset(
                                      selectedImage ?? bot['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Change Picture',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF204E4C),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          selectedImage = null;
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
                          const Text(
                            'Bot Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Bot Name',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bot Bio',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bioController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Bot Bio',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bot Guidelines',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: guidelinesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Bot Guidelines',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                              ),
                            ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: ()async {
                            final prefs = await SharedPreferences.getInstance();
                            String token =prefs.getString("token").toString();
                            final botData ={
                            "name": nameController.text,
                            "context": guidelinesController.text,
                            "bio": bioController.text
                            };
                         await apiService.editBot(context, token,botId,botData);

                            setState(() {
                              bot['name'] = nameController.text;
                              bot['bio'] = bioController.text;
                              bot['guidelines'] = guidelinesController.text;
                              if (selectedImage != null) {
                                bot['image'] = selectedImage;
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF204E4C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xffFBFBFB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
    );
  }

  void _showBotDetailsDialog(BuildContext context, Map<String, dynamic> bot) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (context) {
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      bot['name'],
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        height: 1.2,
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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bot Picture Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bot Picture',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showEditBotDialog(context, bot);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: SvgPicture.asset(
                              'assets/images/edit.svg',
                              width: 16,
                              height: 16,
                            ),
                            label: const Text(
                              'Edit Bot',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Bot Picture
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                             bot['image'] ?? 'assets/bots/bot4.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bot Name
                      const Text(
                        'Bot Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bot['name'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bot Bio
                      const Text(
                        'Bot Bio',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bot['bio'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bot Guidelines
                      const Text(
                        'Bot Guidelines',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bot['guidelines'] ?? 'No guidelines provided',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}