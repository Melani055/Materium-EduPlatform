import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AddMaterial extends StatefulWidget {
  @override
  _AddMaterialState createState() => _AddMaterialState();
}

class _AddMaterialState extends State<AddMaterial> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _kontenController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String? _kategori;
  TextAlign _textAlign = TextAlign.left;
  String? _selectedFilePath;

  Future<void> _pickFile() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File picker tidak didukung di web'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak ada file yang dipilih'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          'text_align': _textAlign.toString(),
          'user_email': user.email,
          'file_path': _selectedFilePath,
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
          content: Text('Terjadi kesalahan: $e', style: TextStyle(color: Colors.white)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.format_align_left),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.left;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_align_center),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.center;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_align_right),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.right;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_align_justify),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.justify;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _kontenController,
              decoration: InputDecoration(
                labelText: 'Konten Materi',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
              textAlign: _textAlign,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pilih File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            if (_selectedFilePath != null) ...[
              SizedBox(height: 8),
              Text('File terpilih: ${_selectedFilePath!.split('/').last}'),
            ],
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
