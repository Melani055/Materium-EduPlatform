import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMaterial extends StatefulWidget {
  @override
  _AddMaterialState createState() => _AddMaterialState();
}

class _AddMaterialState extends State<AddMaterial> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _kontenController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String? _kategori;

  Future<void> _saveToFirebase() async {
    String judul = _judulController.text.trim();
    String konten = _kontenController.text.trim();
    String author = _authorController.text.trim();

    if (judul.isEmpty || konten.isEmpty || author.isEmpty || _kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua kolom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('materials').add({
          'judul': judul,
          'konten': konten,
          'author': author,
          'kategori': _kategori,
          'user_email': user.email,
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Materi berhasil disimpan', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: Anda belum login'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Materi'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul Materi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: ['SD', 'SMP', 'SMK/SMA', 'Umum']
                  .map((kategori) => DropdownMenuItem<String>(
                value: kategori,
                child: Text(kategori),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _kategori = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _kontenController,
              decoration: InputDecoration(
                labelText: 'Konten Materi',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _saveToFirebase,
                child: Text('Simpan Materi', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
