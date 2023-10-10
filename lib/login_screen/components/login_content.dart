import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:sofrecommood/utils/constants.dart';
import 'dart:convert';

import '../../../home_mg.dart';
import '../../../home_page.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key}) : super(key: key);

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  TextEditingController matriculeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool matriculeError = false;
  bool passwordError = false;
  bool formSubmitted = false;

  Widget inputField(String hint, IconData iconData) {
    String errorMsg = '';

    if (formSubmitted) {
      if (hint == 'Matricule') {
        if (matriculeController.text.isEmpty) {
          errorMsg = 'Matricule is required';
        } else if (matriculeController.text.length != 6) {
          errorMsg = 'Matricule must be 6 characters long';
        }
      } else if (hint == 'Mot De Passe') {
        if (passwordController.text.isEmpty) {
          errorMsg = 'Password is required';
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: SizedBox(
        height: 50,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black87,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            controller:
                hint == 'Matricule' ? matriculeController : passwordController,
            obscureText: hint == 'Mot De Passe',
            textAlignVertical: TextAlignVertical.bottom,
            onChanged: (text) {
              if (formSubmitted) {
                setState(() {
                  matriculeError = false;
                  passwordError = false;
                });
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor:
                  kInputFieldFillColor, // Use the color from constants.dart
              hintText: hint,
              prefixIcon: Icon(iconData),
              errorText: errorMsg.isNotEmpty ? errorMsg : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget logos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(
              width: 16), // Add some space between the line and the image
          Image.asset(
            'assets/images/sofrecom.png',
            height:
                60, // Adjust the height of the image as per your requirement
          ),
          const SizedBox(
              width: 16), // Add some space between the image and the line
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 110),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 130),
                logos(),
                inputField('Matricule', Ionicons.person_outline),
                inputField('Mot De Passe', Ionicons.lock_closed_outline),
                loginButton('Log In'),
                forgotPassword(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButton(String buttonText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 16),
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            formSubmitted = true;
            matriculeError = matriculeController.text.isEmpty ||
                matriculeController.text.length != 6;
            passwordError = passwordController.text.isEmpty;
          });

          if (matriculeError || passwordError) {
            // Show login error message
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please enter valid Matricule and Password.'),
              backgroundColor: Colors.red,
            ));
          } else {
            // Perform login here
            final success = await AuthService().login(
              context,
              matriculeController.text,
              passwordController.text,
            );
            if (!success) {
              // Login failed
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Login failed. Please check your credentials.'),
                backgroundColor: Colors.red,
              ));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const StadiumBorder(),
          backgroundColor: kSecondaryColor, // Use the color from constants.dart
          elevation: 8,
          shadowColor: Colors.black87,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AuthService {
  // Replace these URLs with your actual API endpoints
  static const String baseUrl = 'http://10.0.2.2:8081/Humeur_salarie/api';
  static const String loginUrl =
      'http://10.0.2.2:8081/Humeur_salarie/api/login';

  Future<bool> login(BuildContext context, String matricule, String mdp) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type':
              'application/json', // Specify that you are sending JSON data
        },
        body: json.encode({
          // Use the json.encode method to convert the data to JSON format
          'matricule': matricule,
          'mdp': mdp,
        }),
      );
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200) {
        // Login successful
        final data = json.decode(response.body);
        // Replace 'success' with the key that indicates a successful login in your API response
        bool loginSuccess = data['success'] ?? false;
        if (loginSuccess) {
          // Check the role and navigate accordingly
          String role = data['role'];
          if (role == 'manager') {
            // Navigate to HomeManagerPage for managers
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomeManagerPage(),
              ),
            );
          } else if (role == 'employee') {
            // Navigate to HomePage for employees
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    HomePage(matricule: matricule), // Pass the matricule here
              ),
            );
          }
        }
        return loginSuccess;
      } else {
        // Login failed
        print('Login failed. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Error occurred during login
      print('Error during login: $e');
      return false;
    }
  }
}
