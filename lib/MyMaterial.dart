import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DetailMateri.dart';
import 'AddMaterial.dart';

class MyMaterial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String emailUser = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Materi Saya'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('materials')
            .where('user_email', isEqualTo: emailUser)
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
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              var material = materials[index];
              return ListTile(
                title: GestureDetector(
                  onTap: () {
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        _editMaterialDialog(context, material);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Konfirmasi'),
                            content: Text('Apakah Anda yakin ingin menghapus materi ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Ya'),
                              ),
                            ],
                          ),
                        );
                        if (confirmDelete == true) {
                          await FirebaseFirestore.instance
                              .collection('materials')
                              .doc(material.id)
                              .delete();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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

  void _editMaterialDialog(BuildContext context, QueryDocumentSnapshot material) {
    final TextEditingController judulController = TextEditingController(text: material['judul']);
    final TextEditingController kontenController = TextEditingController(text: material['konten']);
    final TextEditingController kategoriController = TextEditingController(text: material['kategori']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Materi'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: kontenController,
                  decoration: InputDecoration(labelText: 'Konten'),
                  maxLines: 6,
                ),
                TextField(
                  controller: kategoriController,
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('materials')
                    .doc(material.id)
                    .update({
                  'judul': judulController.text,
                  'konten': kontenController.text,
                  'kategori': kategoriController.text,
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
