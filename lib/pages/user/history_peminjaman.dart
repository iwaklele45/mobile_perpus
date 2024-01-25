import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPeminjamanUser extends StatefulWidget {
  const HistoryPeminjamanUser({Key? key}) : super(key: key);

  @override
  State<HistoryPeminjamanUser> createState() => _HistoryPeminjamanUserState();
}

class _HistoryPeminjamanUserState extends State<HistoryPeminjamanUser> {
  List<DocumentSnapshot>? loanHistory; // Provide an initial value
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchLoanHistory();
  }

  Future<void> fetchLoanHistory() async {
    try {
      if (user != null) {
        QuerySnapshot loanSnapshot = await FirebaseFirestore.instance
            .collection('peminjaman')
            .where('id user', isEqualTo: user?.uid)
            .where('status peminjaman', isEqualTo: 'telah dikembalikan')
            .get();

        setState(() {
          loanHistory = loanSnapshot.docs;
        });
      }
    } catch (e) {
      print('Error fetching loan history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Peminjaman'),
      ),
      body: loanHistory != null && loanHistory!.isNotEmpty
          ? ListView.builder(
              itemCount: loanHistory!.length,
              itemBuilder: (context, index) {
                var loanData =
                    loanHistory![index].data() as Map<String, dynamic>;
                var bookTitle = loanData['judul buku dipinjam'];
                var tglPinjam = loanData['tanggal peminjaman'];
                var tglPengembalian = loanData['tanggal pengembalian'];
                Timestamp timePinjam = tglPinjam;
                DateTime datePinjam = timePinjam.toDate();
                Timestamp timePengembalian = tglPengembalian;
                DateTime datePengembalian = timePengembalian.toDate();

                return ListTile(
                  title: Text('${index + 1}. $bookTitle'),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Peminjaman: $datePinjam',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Waktu Pengembalian: $datePengembalian',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  // Add more details or customize the ListTile as needed
                );
              },
            )
          : Center(
              child: loanHistory == null
                  ? CircularProgressIndicator()
                  : Text('Tidak ada history peminjaman.'),
            ),
    );
  }
}
