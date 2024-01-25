import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPinjamBuku extends StatefulWidget {
  final String userId;

  const UserPinjamBuku({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserPinjamBuku> createState() => _UserPinjamBukuState();
}

class _UserPinjamBukuState extends State<UserPinjamBuku> {
  late List<DocumentSnapshot> borrowedBooks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buku Dipinjam')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('peminjaman')
            .where('id user', isEqualTo: widget.userId)
            .where('status peminjaman',
                isEqualTo: 'belum terkonfirmasi') // Exclude confirmed books
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            borrowedBooks = snapshot.data!.docs;

            if (borrowedBooks.isNotEmpty) {
              return ListView.builder(
                itemCount: borrowedBooks.length,
                itemBuilder: (context, index) {
                  var peminjamanData =
                      borrowedBooks[index].data() as Map<String, dynamic>;
                  var judulBuku = peminjamanData['judul buku dipinjam'];
                  return GestureDetector(
                    onTap: () {
                      _showConfirmationDialog(context, judulBuku);
                    },
                    child: ListTile(
                      title: Text('${index + 1}. $judulBuku'),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  'Tidak ada peminjaman buku',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String judulBuku) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Peminjaman'),
          content: Text('Apakah Anda yakin ingin meminjamkan buku ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _konfirmasiPengembalian(judulBuku);
              },
              child: const Text('Konfirmasi'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _konfirmasiPengembalian(String judulBuku) {
    // Assuming you have a 'peminjaman' collection with a field 'judul buku dipinjam'
    // You need to find the document that matches the user ID and the book title
    var peminjamanRef = FirebaseFirestore.instance.collection('peminjaman');

    peminjamanRef
        .where('id user', isEqualTo: widget.userId)
        .where('judul buku dipinjam', isEqualTo: judulBuku)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one matching document, you can adjust the logic
        var documentId = querySnapshot.docs[0].id;

        // Update the status to 'terkonfirmasi'
        peminjamanRef
            .doc(documentId)
            .update({'status peminjaman': 'terkonfirmasi'});

        // Optionally, you can add more logic here based on your requirements
      } else {
        // Handle the case where no matching document is found
        print(
            'Document not found for user ${widget.userId} and book $judulBuku');
      }
    }).catchError((error) {
      // Handle errors
      print('Error updating document: $error');
    });
  }
}
