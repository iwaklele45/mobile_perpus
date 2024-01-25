import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagePelanggan extends StatefulWidget {
  const PagePelanggan({Key? key}) : super(key: key);

  @override
  State<PagePelanggan> createState() => _PagePelangganState();
}

class _PagePelangganState extends State<PagePelanggan> {
  final TextEditingController _searchController = TextEditingController();
  late StreamController<List<DocumentSnapshot>> _searchControllerStream;
  List<DocumentSnapshot> _userList = [];

  @override
  void initState() {
    super.initState();
    _searchControllerStream = StreamController<List<DocumentSnapshot>>();
    _searchController.addListener(_onSearchChanged);
    _initializeUserListStream();
  }

  void _onSearchChanged() {
    var searchText = _searchController.text.toLowerCase();
    var filteredList = _filterUsers(searchText);
    _searchControllerStream.add(filteredList);
  }

  List<DocumentSnapshot> _filterUsers(String searchText) {
    return _userList.where((userDoc) {
      var user = userDoc.data() as Map<String, dynamic>;
      var fullName = user['full name'].toLowerCase();
      return fullName.contains(searchText);
    }).toList();
  }

  void _initializeUserListStream() {
    FirebaseFirestore.instance
        .collection('users')
        .where('level', isEqualTo: 'pelanggan') // Filter berdasarkan level
        .snapshots()
        .listen((snapshot) {
      _userList = snapshot.docs;
      _searchControllerStream.add(_userList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {});
                        },
                        child: const Icon(Icons.search)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _searchControllerStream.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var users = snapshot.data ?? [];

                  if (users.isNotEmpty) {
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index].data() as Map<String, dynamic>;
                        var email = user['email'];
                        var address = user['address'];
                        var phone = user['phone'];
                        var statusEmail = user['status email'];
                        var denda = user['denda'];
                        var fullName = user['full name'];

                        return ListTile(
                          title: Text(fullName),
                          onTap: () {
                            _showUserDetails(context, email, address, phone,
                                statusEmail, denda);
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Tidak Ada User',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    String email,
    String address,
    String phone,
    bool statusEmail,
    int denda,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Pelanggan'),
          content: Container(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: $email'),
                Text('Alamat: $address'),
                Text('Nomor: $phone'),
                Text(
                    'Status Email: ${statusEmail ? 'Verified' : 'Not Verified'}'),
                Text('Denda: $denda'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context, email);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userEmail) async {
    try {
      // Membuat pengguna dengan email dan password
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: userEmail, password: "temporary");

      var user = userCredential.user;

      if (user != null) {
        // Hapus pengguna
        await user.delete();
        print('User deleted successfully from Firebase Authentication!');
        print('Email: $userEmail');
      } else {
        print('User not found in Firebase Authentication');
        print('Email: $userEmail');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }

    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userQuery.docs.isNotEmpty) {
      var userDoc = userQuery.docs.first;
      await userDoc.reference.delete();
      print('User data deleted successfully from Firestore!');
      print('Email: $userEmail');
    } else {
      print('User data not found in Firestore');
      print('Email: $userEmail');
    }
  }

  void _showDeleteConfirmation(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
              'Apakah kamu yakin ingin menghapus user ini (User akan Diblokir)!'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    _deleteUser(email);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
