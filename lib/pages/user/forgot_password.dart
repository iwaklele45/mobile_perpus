// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _forgotPasswordController = TextEditingController();

  Future passworReset() async {
    if (_forgotPasswordController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Kolom email tidak boleh kosong!'),
            );
          });
    } else {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _forgotPasswordController.text.trim());
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Email verifikasi sudah dikirim'),
              );
            });
        _forgotPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        String badly = "The email address is badly formatted.";
        if (badly == e.message) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text('Format email harus : @gmail.com'),
                  ));
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text(e.message.toString()),
                  ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color.fromARGB(255, 60, 57, 57),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Forgot Password',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Enter your email account',
            style: GoogleFonts.poppins(
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),

          // Email textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(
                  10,
                ),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextField(
                  controller: _forgotPasswordController,
                  style: GoogleFonts.poppins(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                    icon: Icon(
                      Icons.email,
                      color: Color.fromARGB(255, 60, 57, 57),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 10,
          ),

          // Sign button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
                width: double.infinity,
                height: 40.0,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 60, 57, 57),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  onPressed: passworReset,
                  child: Text(
                    'Send Email',
                    style: GoogleFonts.poppins(
                        fontSize: 18.0, color: Colors.white),
                  ),
                )),
          ),
        ],
      )),
    );
  }
}
