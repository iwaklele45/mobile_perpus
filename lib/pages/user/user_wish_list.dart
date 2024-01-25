import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PageUserWishList extends StatefulWidget {
  const PageUserWishList({super.key});

  @override
  State<PageUserWishList> createState() => _PageUserWishListState();
}

class _PageUserWishListState extends State<PageUserWishList> {
  String userName = '';
  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userName = userSnapshot['full name'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist : $userName',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
