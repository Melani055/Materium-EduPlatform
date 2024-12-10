import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GroupChatPage.dart';
import 'HomePage.dart';
import 'JurnalPage.dart';
import 'ProfilePage.dart';

class ForumPage extends StatefulWidget {
  final String email;

  const ForumPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  int _selectedIndex = 2;
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userName = snapshot.docs.first['name'];
        });
      } else {
        setState(() {
          userName = "User not found";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error fetching name: $e";
      });
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Navigasi halaman sesuai indeks
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(email: widget.email)),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => JurnalPage(email: widget.email)),
        );
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(email: widget.email)),
        );
      }
    }
  }

  // Fungsi untuk menampilkan pop-up dialog untuk memasukkan nama grup
  void _showCreateGroupDialog() {
    final _groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Group Name'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: 'Group Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String groupName = _groupNameController.text;
                if (groupName.isNotEmpty) {
                  _createGroup(groupName);
                  Navigator.of(context).pop(); // Menutup dialog setelah membuat grup
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membuat grup baru di Firestore
  // Fungsi untuk membuat grup baru di Firestore
  void _createGroup(String groupName) async {
    try {
      // Membuat grup dengan ID otomatis yang dihasilkan Firestore
      DocumentReference groupRef = await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName,
        'admin': widget.email,
        'anggota': [widget.email], // Menambahkan email pengguna sebagai anggota grup
      });

      // Menambahkan ID grup yang dihasilkan oleh Firestore
      await groupRef.update({
        'id': groupRef.id, // Menyimpan ID grup yang dihasilkan
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "$groupName" created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: Text(userName, style: const TextStyle(color: Colors.blue)),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where('anggota', arrayContains: widget.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final groups = snapshot.data?.docs ?? [];
            if (groups.isEmpty) {
              return const Center(child: Text("No groups found"));
            }
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group['name']),
                  subtitle: Text("Admin: ${group['admin']}"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatPage(
                        groupId: group['id'],
                        groupName: group['name'],
                        email: widget.email,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateGroupDialog, // Menampilkan pop-up saat tombol ditekan
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Materi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: 'Forum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
