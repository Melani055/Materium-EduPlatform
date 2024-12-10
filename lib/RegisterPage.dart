import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DataDiriPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _registerWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Register user
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Push notification and navigate to DataDiriPage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil Register, Silahkan Masukan Data Diri")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DataDiriPage(email: emailController.text.trim())),
        );
      } on FirebaseAuthException catch (e) {
        // Show error alert and notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Register (${e.message})")),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
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
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(emailController, "Email"),
                _buildTextField(passwordController, "Password", obscureText: true),
                ElevatedButton(
                  onPressed: _registerWithEmailPassword,
                  child: const Text("Register",style: TextStyle(color: Color(0xFFFFFFFF)),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
