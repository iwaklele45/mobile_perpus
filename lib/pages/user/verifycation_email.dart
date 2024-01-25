import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/pages/user/login_page.dart';

class Otp extends StatelessWidget {
  const Otp({
    Key? key,
    required this.otpController,
  }) : super(key: key);

  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: const InputDecoration(),
        onSaved: (value) {},
      ),
    );
  }
}

class VerifyPage extends StatefulWidget {
  final String email;

  const VerifyPage({
    Key? key,
    required this.myAuth,
    required this.email,
  }) : super(key: key);

  final EmailOTP myAuth;

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  final otp5Controller = TextEditingController();

  checkEmailOTP() async {
    try {
      String otp = otp1Controller.text +
          otp2Controller.text +
          otp3Controller.text +
          otp4Controller.text +
          otp5Controller.text;

      // Memverifikasi OTP
      bool isVerified = await widget.myAuth.verifyOTP(otp: otp);

      final emailUser = widget.email;
      print(widget.myAuth.verifyOTP());
      print('email = $emailUser');

      if (isVerified) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: emailUser)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          var statusEmail = querySnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(statusEmail)
              .update({"status email": true});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Email terverifikasi"),
          ));

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: ((context) => const LoginPage())));
        } else {
          // Handle the case when no documents are found
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No user found with the provided email"),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid OTP. Please try again."),
        ));
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Text(
                'We send your email OTP!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                ),
              ),
              Text(
                'Enter the OTP!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Otp(
                      otpController: otp1Controller,
                    ),
                    Otp(
                      otpController: otp2Controller,
                    ),
                    Otp(
                      otpController: otp3Controller,
                    ),
                    Otp(
                      otpController: otp4Controller,
                    ),
                    Otp(
                      otpController: otp5Controller,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: checkEmailOTP,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 60, 57, 57),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Text(
                      'Verify Email',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
