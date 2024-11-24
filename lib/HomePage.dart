import 'package:flutter/material.dart';
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
  int _selectedIndex = 0; // Indeks untuk tab aktif (0 = Home)
  int _themeIndex = 1; // 0 = Dark, 1 = System, 2 = Light

  // Method untuk mengubah mode tema berdasarkan indeks
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

  // Method untuk navigasi pada bottom bar
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        // Tetap di halaman Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(email: widget.email),
          ),
        );
      } else if (index == 1) {
        // Pindah ke halaman Journal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JurnalPage(email: widget.email),
          ),
        );
      } else if (index == 2) {
        // Pindah ke halaman Forum
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForumPage(email: widget.email),
          ),
        );
      } else if (index == 3) {
        // Pindah ke halaman Profile
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
            widget.email, // Menampilkan email pengguna
            style: const TextStyle(color: Colors.blue), // Warna teks biru
          ),
          actions: [
            // Toggle button untuk tema
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar di atas TextField
              Image.asset(
                'assets/images/logo.png', // Ganti dengan path gambar Anda
                width: 175,
                height: 175,
              ),
              // Search field
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
                onPressed: () {
                  // Fungsi untuk mencari data
                },
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
          currentIndex: _selectedIndex, // Menjaga tab yang aktif
          onTap: _onItemTapped, // Fungsi navigasi saat item diklik
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
