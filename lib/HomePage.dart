import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JurnalPage.dart';
import 'ProfilePage.dart';
import 'ForumPage.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({Key? key, required this.email}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedIndex = 0;
  int _themeIndex = 1;
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

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(email: widget.email),
          ),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JurnalPage(email: widget.email),
          ),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForumPage(email: widget.email),
          ),
        );
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(email: widget.email),
          ),
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
                  Icon(Icons.dark_mode),
                  Icon(Icons.settings),
                  Icon(Icons.light_mode),
                ],
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 175,
                height: 175,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
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
              label: 'Journal',
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
