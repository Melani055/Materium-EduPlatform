import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DetailMateri.dart';
import 'AddMaterial.dart';

class MyMaterial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ambil email pengguna yang sedang login
    String emailUser = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Materi Saya',),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('materials')
            .where('user_email', isEqualTo: emailUser) // Filter berdasarkan email pengguna yang sedang login
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Terjadi kesalahan'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Belum ada materi'));
          }

          var materials = snapshot.data!.docs;

          return ListView.separated(
            itemCount: materials.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey), // Garis pembatas
            itemBuilder: (context, index) {
              var material = materials[index];
              return ListTile(
                title: GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman DetailMateri saat judul diklik
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
                  child: Text(material['judul'], style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                subtitle: Text(material['kategori']),
                trailing: TextButton(
                  onPressed: () {
                    // Navigasi ke halaman DetailMateri saat tombol diklik
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
                  child: Text(
                    "Detail Materi",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman TambahMateri
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMaterial()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
