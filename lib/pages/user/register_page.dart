import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/pages/user/verifycation_email.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailControler = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  final otpMail = EmailOTP();
  bool _passworObsecure = false;
  bool _confirmPasswordObsecure = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailControler.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _passworObsecure = true;
    _confirmPasswordObsecure = true;
    super.initState();
  }

  void _toogleShowPassword() {
    setState(() {
      _passworObsecure = !_passworObsecure;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  void _toogleShowConfirmPassword() {
    setState(() {
      _confirmPasswordObsecure = !_confirmPasswordObsecure;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  Future registerUser(
    String fullName,
    String address,
    int phone,
    String uidUser,
  ) async {
    await FirebaseFirestore.instance.collection('users').add({
      'full name': fullName,
      'address': address,
      'phone': phone,
      'uidUser': uidUser,
      'level': 'pelanggan',
      'denda': 0,
      'email': _emailControler.text,
      'status email': 'false',
    });
  }

  Future signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_fullNameController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _emailControler.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kolom harus di isi semua!')));
      } else if (!passwordConfirmed()) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password tidak sama!')));
      } else if (passwordConfirmed()) {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailControler.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'full name': _fullNameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'level': 'pelanggan',
          'denda': 0,
          'email': _emailControler.text,
          'status email': false,
        });
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verifikasi sudah dikirim!')));
        Future.delayed(const Duration(seconds: 10), () {
          _fullNameController.clear();
          _addressController.clear();
          _phoneController.clear();
          _emailControler.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error sending OTP email. Please try again.'),
          ));
          return;
        }

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => VerifyPage(
                  email: _emailControler.text,
                  myAuth: otpMail,
                )));
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.message) {
        case 'The email address is already in use by another account.':
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Email tersebut sudah terpakai oleh user lain!')));
          _emailControler.clear();
          break;
        case 'The email address is badly formatted.':
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Format email salah!')));
          _emailControler.clear();
          break;
        default:
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(
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
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
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
            Text(
              'Register',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Create your new account',
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
                    controller: _fullNameController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nama',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.person_2,
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
                    controller: _addressController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Address',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.location_on,
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
                    controller: _phoneController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Phone Number',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.phone,
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
                    obscureText: _passworObsecure,
                    controller: _passwordController,
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
                          onTap: _toogleShowPassword,
                          child: Icon(
                            _passworObsecure
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
                    obscureText: _confirmPasswordObsecure,
                    controller: _confirmPasswordController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Confirm Password',
                      icon: const Icon(
                        Icons.key,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: GestureDetector(
                          onTap: _toogleShowConfirmPassword,
                          child: Icon(
                            _confirmPasswordObsecure
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'By signing you agree to our ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text('Team of use')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'and ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text('privacy notice'),
              ],
            ),
            SizedBox(
              height: screenHeight - 650,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SizedBox(
                width: double.infinity,
                height: 40.0,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: const MaterialStatePropertyAll<Color>(
                      Color.fromARGB(255, 60, 57, 57),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  onPressed: _isLoading ? null : signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeAlign: -4,
                          color: Colors.white,
                        )
                      : Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
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
                  'Have an account? ',
                  style: GoogleFonts.poppins(),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    ));
  }
}
