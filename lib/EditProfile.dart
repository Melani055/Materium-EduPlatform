import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  TextEditingController birthDateController = TextEditingController(); // Controller untuk TextField

  // Mengambil data user dari Firebase
  void _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? "";
          emailController.text = userDoc['email'] ?? "";
          phoneController.text = userDoc['phone'] ?? "";
          passwordController.text = ""; // Kosongkan password untuk keamanan

          // Cek apakah birthDate ada dan sudah dalam format yang benar
          if (userDoc['birthDate'] != null) {
            birthDateController.text = userDoc['birthDate']; // Set text ke controller birthDate
          }
        });
      }
    }
  }

  // Fungsi untuk menyimpan data ke Firebase
  Future<void> _saveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'birthDate': birthDateController.text.isNotEmpty
              ? birthDateController.text
              : null, // Simpan tanggal lahir dalam format string
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profil berhasil diperbarui")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Memanggil data pengguna saat halaman dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Tanggal Lahir (sekarang menggunakan TextField)
            TextField(
              controller: birthDateController,
              decoration: InputDecoration(
                labelText: "Tanggal Lahir",
                hintText: "yyyy-MM-dd", // Format yang akan ditampilkan di hint
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: birthDateController.text.isNotEmpty
                          ? DateTime.parse(birthDateController.text)
                          : DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                border: OutlineInputBorder(),
              ),
              readOnly: true, // Tidak bisa langsung diedit, hanya melalui date picker
            ),
            SizedBox(height: 16),

            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // No HP
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "No HP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Password (biar tidak menampilkan password sebelumnya)
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // Tombol simpan
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
