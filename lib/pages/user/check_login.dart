import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_perpus/pages/admin/admin_page.dart';
import 'package:mobile_perpus/pages/kepala/kepala_laporan.dart';
import 'package:mobile_perpus/pages/user/home_page.dart';
import 'package:mobile_perpus/pages/user/login_page.dart';

class CheckLogin extends StatelessWidget {
  const CheckLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // Set the background color to white
      child: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final User? currentUser = authSnapshot.data;
          final String? currentUserEmail = currentUser?.email;

          if (currentUserEmail != null) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: currentUserEmail)
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasData) {
                  if (userSnapshot.data!.docs.isNotEmpty) {
                    final Map<String, dynamic> userData =
                        userSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                    final String userLevel = userData['level'];

                    switch (userLevel) {
                      case 'pelanggan':
                        return const HomePage();
                      case 'admin':
                        return const AdminPage();
                      case 'kepala':
                        return const LaporanPage();
                      default:
                        return const LoginPage();
                    }
                  } else {
                    return const LoginPage();
                  }
                } else {
                  return const Center(
                      child: Text("Data pengguna tidak ditemukan"));
                }
              },
            );
          } else {
            return const Center(child: Text("Email pengguna tidak ditemukan"));
          }
        },
      ),
    );
  }
}
