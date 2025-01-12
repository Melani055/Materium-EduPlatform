import 'package:flutter/material.dart';

class DetailMateri extends StatelessWidget {
  final String judul;
  final String konten;
  final String author;
  final String kategori;

  DetailMateri({
    required this.judul,
    required this.konten,
    required this.author,
    required this.kategori,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Materi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Kategori: $kategori',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Author: $author',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 8),
              Text(
                konten,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
