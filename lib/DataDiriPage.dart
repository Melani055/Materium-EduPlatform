import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';

class DataDiriPage extends StatefulWidget {
  final String email;

  const DataDiriPage({Key? key, required this.email}) : super(key: key);

  @override
  State<DataDiriPage> createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  DateTime? selectedBirthDate;
  bool isLoading = false;

  Future<void> _saveData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Pengguna sudah login
      if (_formKey.currentState!.validate() && selectedBirthDate != null) {
        setState(() => isLoading = true);
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': nameController.text.trim(),
            'email': widget.email,
            'birthDate': selectedBirthDate!.toIso8601String(),
            'phone': phoneController.text.trim(),
            'createdAt': DateTime.now().toIso8601String(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data Diri Berhasil Disimpan")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage(email: '',)),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data Diri Gagal Disimpan: $e")),
          );
        } finally {
          setState(() => isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda belum login")),
      );
    }
  }


  Future<void> _pickBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedBirthDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Diri")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Field
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field ini harus diisi";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // No HP Field
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "No HP",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field ini harus diisi";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Birth Date Picker
                InkWell(
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Birth Date",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      selectedBirthDate == null
                          ? "Select your birth date"
                          : "${selectedBirthDate!.toLocal()}".split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  initialValue: widget.email,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
