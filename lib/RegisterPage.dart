import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variabel untuk menyimpan tanggal lahir
  DateTime? selectedBirthDate;

  ThemeMode _themeMode = ThemeMode.system;
  int _themeIndex = 1; // 0 = Dark, 1 = System, 2 = Light

  // Fungsi untuk mendaftarkan user dan menyimpan data ke Firestore
  Future<void> _registerWithEmailPassword() async {
    if (_formKey.currentState!.validate() && selectedBirthDate != null) {
      try {
        // Buat user di Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Simpan data tambahan ke Firestore
        try {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': nameController.text,
            'phone': phoneController.text,
            'birthDate': selectedBirthDate!.toIso8601String(),
            'email': emailController.text,
            'createdAt': DateTime.now().toIso8601String(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
        } catch (e) {
          // Log kesalahan yang lebih rinci
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data to Firestore: $e')),
          );
          print('Error: $e'); // Cetak error ke konsol debug
        }



        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pop(context); // Kembali ke halaman login
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.message}')),
        );
      }
    } else if (selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birth date')),
      );
    }
  }

  // Fungsi untuk mengubah tema
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

  // Fungsi untuk memilih tanggal lahir
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

  // Fungsi untuk membuat TextFormField
  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blue),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Materium App',
            style: TextStyle(color: Colors.blue),
          ),
          actions: [
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
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Input untuk nama
                  _buildTextField(nameController, "Full Name"),
                  // Input untuk nomor telepon
                  _buildTextField(phoneController, "Phone Number"),
                  // Input untuk tanggal lahir dengan DatePicker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: InkWell(
                      onTap: _pickBirthDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Birth Date",
                          labelStyle: const TextStyle(color: Colors.blue),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        child: Text(
                          selectedBirthDate == null
                              ? 'Select your birth date'
                              : "${selectedBirthDate!.toLocal()}".split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  // Input untuk email
                  _buildTextField(emailController, "Email"),
                  // Input untuk password
                  _buildTextField(passwordController, "Password", obscureText: true),
                  // Tombol register
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _registerWithEmailPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                  ),
                  // Tombol kembali ke login
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman login
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
