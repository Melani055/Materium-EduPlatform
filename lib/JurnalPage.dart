import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProfilePage.dart';
import 'HomePage.dart';
import 'ForumPage.dart';
import 'DetailMateri.dart';

class JurnalPage extends StatefulWidget {
  final String email;

  const JurnalPage({Key? key, required this.email}) : super(key: key);

  @override
  State<JurnalPage> createState() => _JurnalPageState();
}

class _JurnalPageState extends State<JurnalPage> {
  ThemeMode _themeMode = ThemeMode.system;
  int _themeIndex = 1;
  int _selectedIndex = 1;
  String userName = "Loading...";
  List<Map<String, dynamic>> materials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchMaterials();
  }

  void _changeTheme(int index) {
    setState(() {
      _themeIndex = index;
      _themeMode = (index == 0)
          ? ThemeMode.dark
          : (index == 2)
          ? ThemeMode.light
          : ThemeMode.system;
    });
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

  Future<void> _fetchMaterials() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('materials')
          .where('user_email', isEqualTo: widget.email)
          .get();
      final data = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {
        materials = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        materials = [];
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
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
                  Icon(Icons.dark_mode),
                  Icon(Icons.settings),
                  Icon(Icons.light_mode),
                ],
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Materi Terbaru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: materials.isEmpty
                  ? const Center(
                child: Text('No materials found.'),
              )
                  : ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
                  final title = material['judul'] ?? 'No Title';
                  final author = material['author'] ?? 'Unknown Author';
                  final kategori =
                      material['kategori'] ?? 'Uncategorized';
                  final konten = material['konten'] ?? '';
                  final snippet = konten.length > 100
                      ? '${konten.substring(0, 100)}...'
                      : konten;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Author: $author'),
                          Text('Kategori: $kategori'),
                          Text('$snippet'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMateri(
                              judul: title,
                              konten: konten,
                              author: author,
                              kategori: kategori,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
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
