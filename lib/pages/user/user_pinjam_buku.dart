import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListPinjamBuku extends StatefulWidget {
  const ListPinjamBuku({super.key});

  @override
  State<ListPinjamBuku> createState() => _ListPinjamBukuState();
}

class _ListPinjamBukuState extends State<ListPinjamBuku> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pinjam Buku'),
      ),
      body: Column(
        children: [
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('peminjaman')
                    .where('id user', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Center(child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var peminjamanList = snapshot.data?.docs;

                    if (peminjamanList == null || peminjamanList.isEmpty) {
                      return const Center(
                        child: Text('Anda belum meminjam buku.'),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: peminjamanList.length,
                      itemBuilder: (context, index) {
                        var peminjaman = peminjamanList[index].data()
                            as Map<String, dynamic>;
                        var judulBukuDipinjam =
                            peminjaman['judul buku dipinjam'];

                        return ListTile(
                          title: Text(judulBukuDipinjam),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
