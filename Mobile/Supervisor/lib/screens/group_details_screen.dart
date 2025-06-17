import 'package:autine1/services/chat_services.dart';
import 'package:autine1/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


final ChatService chatService= ChatService();
final SuperService superService = SuperService();

class GroupDetailsScreen extends StatefulWidget {
  final String groupName;
  final String superUsername;
  final String userUsername;
  final String memUsername;

  const GroupDetailsScreen({
    Key? key,
    required this.groupName,
    required this.superUsername,
    required this.userUsername,
    required this.memUsername,
  }) : super(key: key);

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
late List<Map<String , dynamic>> groupMembers=[];
List<Map<String, dynamic>> users = [];
 List<Map<String, dynamic>> supers = [];
 String token ='';
 String? _profileImageUrl ='';
 String fname='';
 String lname='';


    Future<void> loadusers() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    fname=prefs.getString("fname") ?? "";
    lname=prefs.getString("lname") ?? "";

    try {
      final userData = await chatService.getSupers();
      if(userData != null){
      setState(() {
            users = (userData['supervisors'] as List)
      .map((item) => {
        'id': item['supervisor_username'].toString(),
        'email': item['supervisor_email'].toString(),
        'fname': item['supervisor_fname'].toString(),
        'lname' :item['supervisor_lname'].toString(),
          })
      .toList();
      supers= users;

      });
      }
  
    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load supervisors: ${e.toString()}")),
);
    }
  }

Future<void> loadMembers() async {
    String sessionId='1';

    try {
     final mems = await chatService.getMembers(widget.superUsername, sessionId,widget.userUsername);
      if (mems != null) {
          setState(() {
       groupMembers = (mems['thread_members'] as List)
      .map((item) => {
        'memUsername': item['member_username'].toString(),
        'fname': item['member_fname'].toString(),
        'lname': item['member_lname'].toString(),
          })
      .toList();
}); 
      }
      else{print("No members found!");}
    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load members: ${e.toString()}")),
);
    }
  }

  @override
  void initState() {
    super.initState();
    loadMembers();
    loadusers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(widget.groupName,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff333333))),
                const SizedBox(height: 4),
                const Text('Thread Chat',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff999999))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Members",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showAddMemberBottomSheet(context);
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF204E4C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: groupMembers.length,
              itemBuilder: (context, index) {
                final member = groupMembers[index];
                final isCurrentUser = "${member['fname']} ${member['lname']}" == "$fname $lname";
               _profileImageUrl ='';

                return ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
  radius: 22,
  backgroundColor: const Color(0xFF204E4C),
  child: ClipOval(
    child: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
        ? Image.network(
            _profileImageUrl!,
            headers: {
              'Authorization': 'Bearer $token',
            },
            fit: BoxFit.cover,
            width: 44, // match diameter of avatar (radius * 2)
            height: 44,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  "${member['fname'].isNotEmpty ? member['fname'][0] : ''}${member['lname'].isNotEmpty ? member['lname'][0] : ''}",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    height: 1.4,
                    letterSpacing: 0.001,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(
              "${member['fname'].isNotEmpty ? member['fname'][0] : ''}${member['lname'].isNotEmpty ? member['lname'][0] : ''}",
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                height: 1.4,
                letterSpacing: 0.001,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
  ),
),
                  title: Text("${member['fname']} ${member['lname']}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito')),
                  trailing: isCurrentUser
                      ? const Text("you",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400))
                      : const Icon(Icons.chat_outlined,
                      size: 20, color: Color(0xff666666)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberBottomSheet(BuildContext context) {
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            List<Map<String, dynamic>> filteredMembers = supers
                .where((member) => member['email']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
                .toList();

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
                    'Add Member',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      setStateDialog(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Members',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  filteredMembers.isEmpty
                      ? const Text('No members found')
                      : SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return ListTile(
                          leading:  CircleAvatar(
  radius: 20,
  backgroundColor: const Color(0xFF204E4C),
  child: ClipOval(
    child: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
        ? Image.network(
            _profileImageUrl!,
            headers: {
              'Authorization': 'Bearer $token',
            },
            fit: BoxFit.cover,
            width: 40, // match diameter of avatar (radius * 2)
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  "${member['fname'].isNotEmpty ? member['fname'][0] : ''}${member['lname'].isNotEmpty ? member['lname'][0] : ''}",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    height: 1.4,
                    letterSpacing: 0.001,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(
              "${member['fname'].isNotEmpty ? member['fname'][0] : ''}${member['lname'].isNotEmpty ? member['lname'][0] : ''}",
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                height: 1.4,
                letterSpacing: 0.001,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
  ),
),
                          title: Text("${member['fname']} ${member['lname']}"),
                          trailing: TextButton(
                            onPressed: () async {
                              String sessionId='1';
                              await chatService.addMember(context,widget.superUsername,widget.userUsername,member['id'],sessionId);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                color: Color(0xFF204E4C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}

class Member {
  final String fname;
  final String lname;
  final String imagePath;

  Member({required this.fname, required this.lname, required this.imagePath});
}
