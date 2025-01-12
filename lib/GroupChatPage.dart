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

  void _showGroupMembers(BuildContext context) async {
    DocumentSnapshot groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    List<String> members = List<String>.from(groupDoc['anggota'] ?? []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Members of $groupName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: members.map((member) {
              return ListTile(
                title: Text(member),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    Future<void> _sendMessage() async {
      final message = messageController.text.trim();
      if (message.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You need to log in first.')),
          );
          return;
        }

        try {
          await FirebaseFirestore.instance.collection('messages').add({
            'groupId': groupId,
            'sender': user.email,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
          });
          messageController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message.')),
          );
        }
      }
    }

    Future<void> _addMember() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController newMemberController = TextEditingController();

          return AlertDialog(
            title: Text('Add Member to $groupName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newMemberController,
                  decoration: InputDecoration(hintText: 'New Member Email'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final newMemberEmail = newMemberController.text.trim();
                    if (newMemberEmail.isNotEmpty) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('groups')
                            .doc(groupId)
                            .update({
                          'anggota': FieldValue.arrayUnion([newMemberEmail]),
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Member added successfully.')),
                        );
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add member.')),
                        );
                      }
                    }
                  },
                  child: Text('Add Member'),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> _leaveGroup() async {
      try {
        await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
          'anggota': FieldValue.arrayRemove([email]),
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have left the group.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave group.')),
        );
      }
    }

    Future<void> _confirmLeaveGroup() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Leave Group'),
            content: Text('Are you sure you want to leave the group?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _leaveGroup();
                },
                child: Text('Leave'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showGroupMembers(context),
          child: Text(groupName),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _confirmLeaveGroup,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addMember,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .snapshots(),
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
                  '${members.length} Members',
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
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final timestamp = (message['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (message['sender'] == email)
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('messages')
                                            .doc(message.id)
                                            .delete();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Message deleted.')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to delete message.')),
                                        );
                                      }
                                    },
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['sender'] ?? 'Unknown',
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
                                        message['message'] ?? '',
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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