import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JurnalPage.dart';
import 'ProfilePage.dart';
import 'ForumPage.dart';
import 'DetailMateri.dart';

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
  String searchQuery = "";
  List<QueryDocumentSnapshot> searchResults = [];

  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _search() async {
    setState(() {
      searchQuery = _searchController.text;
    });

    if (searchQuery.isNotEmpty) {
      try {
        final results = await FirebaseFirestore.instance
            .collection('materials')
            .where('judul', isGreaterThanOrEqualTo: searchQuery)
            .where('judul', isLessThanOrEqualTo: searchQuery + '\uf8ff')
            .get();

        setState(() {
          searchResults = results.docs;
        });

        if (results.docs.isEmpty) {
          print("No results found");
        } else {
          results.docs.forEach((doc) {
            print("Found material: ${doc['judul']}");
          });
        }
      } catch (e) {
        print("Error fetching search results: $e");
        setState(() {
          searchResults = [];
        });
      }
    } else {
      setState(() {
        searchResults = [];
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
                  controller: _searchController,
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
                onPressed: _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    var material = searchResults[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(material['judul']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Author: ${material['author']}"),
                            Text("Kategori: ${material['kategori']}"),
                            Text(
                              "${material['konten']}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailMateri(
                                      judul: material['judul'],
                                      konten: material['konten'],
                                      author: material['author'],
                                      kategori: material['kategori'],
                                    ),
                                  ),
                                );
                              },
                              child: Text("Lihat selengkapnya"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
