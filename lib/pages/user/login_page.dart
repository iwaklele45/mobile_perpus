import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/main.dart';
import 'package:mobile_perpus/pages/user/forgot_password.dart';
import 'package:mobile_perpus/pages/user/register_page.dart';
import 'package:mobile_perpus/pages/user/verifycation_email.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailControler = TextEditingController();
  final _passwordController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  final otpMail = EmailOTP();
  bool _obscureText = false;

  @override
  void initState() {
    _obscureText = true;
    super.initState();
  }

  void _toogleObscured() {
    setState(() {
      _obscureText = !_obscureText;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  void _hiddenPassword() {
    setState(() {
      _obscureText = true;
    });
  }

  Future signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userEmail = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: _emailControler.text)
          .get();
      if (_emailControler.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kolom harus di isi semua!')),
        );
      } else {
        if (userEmail.docs.isNotEmpty) {
          final userData = userEmail.docs[0].data();
          final userStatus = userData['status email'];
          if ('$userStatus' == 'true') {
            await _auth.signInWithEmailAndPassword(
              email: _emailControler.text,
              password: _passwordController.text,
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          } else {
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Failed'),
                  content: const Text('Email belum terverifikasi'),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Kembali'),
                        ),
                        TextButton(
                          onPressed: () async {
                            otpMail.setConfig(
                              appEmail: 'moper11223@gmail.com',
                              appName: 'Email OTP',
                              userEmail: _emailControler.text,
                              otpLength: 5,
                              otpType: OTPType.digitsOnly,
                            );
                            try {
                              await otpMail.sendOTP();
                            } catch (e) {
                              print('Error sending OTP email: $e');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Error sending OTP email. Please try again.'),
                              ));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Email verifikasi sudah dikirim!')));
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => VerifyPage(
                                          email: _emailControler.text,
                                          myAuth: otpMail,
                                        )));
                          },
                          child: const Text('Verifikasi'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email tidak ditemukan')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau Password Salah!')),
      );
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailControler.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 350,
              width: 500,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logomoperr.png'),
                  fit: BoxFit.scaleDown,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 25.0,
                    top: 50,
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 60, 57, 57),
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Welcome back',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Login to your account',
              style: GoogleFonts.poppins(
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
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
                    controller: _emailControler,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.email,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
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
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Password',
                      icon: const Icon(
                        Icons.lock_rounded,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: GestureDetector(
                          onTap: _toogleObscured,
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Color.fromARGB(255, 60, 57, 57),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _hiddenPassword();
                      _emailControler.clear();
                      _passwordController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: screenHeight - 650),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SizedBox(
                width: double.infinity,
                height: 40.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signIn,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 60, 57, 57),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeAlign: -4,
                          color: Colors.white,
                        )
                      : Text(
                          'Login',
                          style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: GoogleFonts.poppins(),
                ),
                GestureDetector(
                  onTap: () {
                    _hiddenPassword();
                    _emailControler.clear();
                    _passwordController.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.poppins(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    ));
  }
}
