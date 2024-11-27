import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';
import 'JurnalPage.dart';
import 'ProfilePage.dart';

class ForumPage extends StatefulWidget {
  final String email; // Email pengguna yang sedang login

  const ForumPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  ThemeMode _themeMode = ThemeMode.system;
  int _themeIndex = 1; // 0 = Dark, 1 = System, 2 = Light
  int _selectedIndex = 2; // Menentukan tab aktif pada bottom bar (2 = Forum)
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
        userName = "Error fetching name";
      });
    }
  }

  void _changeTheme(int index) {
    setState(() {
      _themeIndex = index;
      if (index == 0) {
        _themeMode = ThemeMode.dark;
      } else if (index == 1) {
        _themeMode = ThemeMode.system;
      } else if (index == 2) {
        _themeMode = ThemeMode.light;
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
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
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ForumPage(email: widget.email)),
        );
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(email: widget.email)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            userName,
            style: const TextStyle(color: Colors.blue),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(20),
                borderWidth: 1.5,
                selectedBorderColor: Colors.blue,
                borderColor: Colors.grey,
                color: Colors.grey,
                selectedColor: Colors.blue,
                isSelected: [
                  _themeIndex == 0,
                  _themeIndex == 1,
                  _themeIndex == 2,
                ],
                onPressed: (index) {
                  _changeTheme(index);
                },
                children: const [
                  Icon(Icons.dark_mode), // Dark Mode
                  Icon(Icons.settings),  // System Default
                  Icon(Icons.light_mode), // Light Mode
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Forum Diskusi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.question_answer, color: Colors.blue),
                title: Text("Topik 1"),
                subtitle: Text("Diskusi tentang topik 1..."),
                onTap: null,
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.question_answer, color: Colors.blue),
                title: Text("Topik 2"),
                subtitle: Text("Diskusi tentang topik 2..."),
                onTap: null,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTap,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Mater",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: "Forum",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
