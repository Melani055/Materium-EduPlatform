import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'HomePage.dart';
import 'RegisterPage.dart';
import 'DataDiriPage.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title, required void Function(ThemeMode themeMode) onThemeChange});

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  ThemeMode _themeMode = ThemeMode.system;
  int _themeIndex = 1;

  Future<void> _loginWithEmailPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _showLoginSuccessDialog();
    } on FirebaseAuthException catch (e) {
      _showLoginFailedDialog(e.message);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(credential);
      _showLoginSuccessDialog();
    } on FirebaseAuthException catch (e) {
      _showLoginFailedDialog(e.message);
    }
  }

  void _showLoginSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Successful'),
        content: const Text('You have successfully logged in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHomePage(emailController.text);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoginFailedDialog(String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(errorMessage ?? 'An unknown error occurred.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToHomePage(String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(email: email),
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
          title: Text(
            'Materium App',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                },
                children: const [
                  Icon(Icons.dark_mode),
                  Icon(Icons.settings),
                  Icon(Icons.light_mode),
                ],
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',  // Pastikan file gambar ada di folder ini
                  width: 100,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.blue),
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
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.blue),
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
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _loginWithEmailPassword();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Login with Email',
                        style: TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/images/google.png',  // Pastikan file gambar ada di folder ini
                        width: 24,
                        height: 24,
                      ),
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      label: const Text(
                        'Login with Google',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Register here',
                      style: TextStyle(color: Colors.blue),
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
