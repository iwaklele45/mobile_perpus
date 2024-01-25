import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPengembalianBuku extends StatefulWidget {
  final String userId;

  const UserPengembalianBuku({Key? key, required this.userId})
      : super(key: key);

  @override
  State<UserPengembalianBuku> createState() => _UserPengembalianBukuState();
}

class _UserPengembalianBukuState extends State<UserPengembalianBuku> {
  List<DocumentSnapshot> borrowedBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Buku Dipinjam')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('peminjaman')
            .where('id user', isEqualTo: widget.userId)
            .where('status peminjaman', isEqualTo: 'terkonfirmasi')
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
                  var bookData =
                      borrowedBooks[index].data() as Map<String, dynamic>;
                  var judulBuku = bookData['judul buku dipinjam'];
                  var tanggalPeminjaman =
                      bookData['tanggal peminjaman'].toDate();
                  var tanggalPengembalian =
                      bookData['tanggal pengembalian'].toDate();

                  return ListTile(
                    title: Text('${index + 1}. $judulBuku'),
                    subtitle: Text(
                      'Tanggal Peminjaman: $tanggalPeminjaman\nTanggal Pengembalian: $tanggalPengembalian',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () {
                      _showConfirmationDialog(index, tanggalPengembalian);
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Tidak ada buku yang sedang dipinjam'),
              );
            }
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(int index, DateTime tanggalPengembalian) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengembalian'),
          content: const Text(
              'Apakah Anda yakin ingin mengkonfirmasi pengembalian?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _confirmReturn(index, tanggalPengembalian);
              },
              child: const Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _handleBookLost(index, tanggalPengembalian);
              },
              child: const Text(
                'Buku Hilang',
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

  void _confirmReturn(int index, DateTime tanggalPengembalian) {
    var currentDate = DateTime.now();
    var latePenaltyRate = 2000; // Penalty rate per day

    var daysLate = currentDate.difference(tanggalPengembalian).inDays;
    var latePenalty = daysLate * latePenaltyRate;

    // Mencegah nilai denda menjadi negatif jika buku dikembalikan lebih awal
    latePenalty = latePenalty < 0 ? 0 : latePenalty;

    // Mengupdate status peminjaman
    FirebaseFirestore.instance
        .collection('peminjaman')
        .doc(borrowedBooks[index].id)
        .update({'status peminjaman': 'telah dikembalikan'});

    // Menambahkan denda jika pengembalian terlambat
    if (daysLate > 0) {
      _applyPenalty(latePenalty);
    }

    // Mengupdate stok buku ketika buku dikembalikan
    _updateBookStock(borrowedBooks[index]['id buku dipinjam']);
  }

  void _updateBookStock(String bookId) {
    // Menambah stok buku sebanyak 1
    FirebaseFirestore.instance
        .collection('buku')
        .doc(bookId)
        .update({'stokBuku': FieldValue.increment(1)});
  }

  void _handleBookLost(int index, DateTime tanggalPengembalian) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Buku Hilang'),
          content:
              const Text('Apakah Anda yakin ingin konfirmasi buku hilang?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _confirmBookLost(index, tanggalPengembalian);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  void _confirmBookLost(int index, DateTime tanggalPengembalian) {
    var lostPenaltyAmount = 25000; // Penalty for lost book

    // Set confirmation status in 'peminjaman' collection
    FirebaseFirestore.instance
        .collection('peminjaman')
        .doc(borrowedBooks[index].id)
        .update({'status peminjaman': 'buku hilang'});

    // Set confirmation status in 'user' collection
    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(widget.userId)
    //     .update({'konfirmasi buku hilang': true});

    // Apply lost book penalty to user's account
    _applyPenalty(lostPenaltyAmount);
  }

  void _applyPenalty(int penaltyAmount) {
    // Anda dapat mengimplementasikan logika untuk menambahkan denda ke akun pengguna
    // Misalnya, memperbarui field 'denda' di koleksi 'users'
    FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'denda': FieldValue.increment(penaltyAmount),
    });
  }
}
