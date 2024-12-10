import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatPage extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String email;

  const GroupChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    Future<void> _sendMessage() async {
      final message = messageController.text.trim();
      if (message.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Pengguna belum login
          // Anda bisa memberi tahu pengguna untuk login terlebih dahulu
          return;
        }

        await FirebaseFirestore.instance.collection('messages').add({
          'groupId': groupId,
          'sender': user.email,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        messageController.clear();
      }
    }

    Future<void> _addMember() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController newMemberController = TextEditingController();

          return AlertDialog(
            title: Text('Tambah Anggota ke $groupName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newMemberController,
                  decoration: InputDecoration(hintText: 'Email Anggota Baru'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final newMemberEmail = newMemberController.text.trim();
                    if (newMemberEmail.isNotEmpty) {
                      try {
                        // Menambahkan anggota baru ke dalam group
                        await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
                          'anggota': FieldValue.arrayUnion([newMemberEmail]),
                        });

                        // Tutup dialog terlebih dahulu
                        Navigator.of(context).pop();

                        // Tunggu frame berikutnya untuk menampilkan SnackBar
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Anggota berhasil ditambahkan')),
                          );
                        });
                      } catch (e) {
                        // Menampilkan pesan error jika gagal
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menambahkan anggota')),
                          );
                        });
                      }
                    }
                  },
                  child: Text('Tambah Anggota'),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addMember,
          ),
        ],
      ),
      body: Column(
        children: [
          // Menampilkan jumlah anggota di bawah judul grup
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Text('Group not found');
                }

                final groupData = snapshot.data!;
                final members = List<String>.from(groupData['anggota'] ?? []);
                return Text(
                  '${members.length} Anggota',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('groupId', isEqualTo: groupId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                // Log snapshot data untuk debugging
                print("Snapshot data: ${snapshot.data!.docs}");

                final messages = snapshot.data!.docs;
                print("Messages: $messages"); // Debugging output

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    print("Message $index: ${message.data()}"); // Menampilkan setiap message

                    final timestamp = (message['timestamp'] as Timestamp).toDate();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: message['sender'] == email
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: message['sender'] == email
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['sender'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: message['sender'] == email
                                    ? Colors.blue
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                message['message'],
                                style: TextStyle(
                                  color: message['sender'] == email
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${timestamp.hour}:${timestamp.minute}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )

          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(hintText: "Enter message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
