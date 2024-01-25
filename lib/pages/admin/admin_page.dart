import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_perpus/pages/admin/mydrawer.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Stream<int> getPeminjamanStatusStream(String status) {
    return FirebaseFirestore.instance
        .collection('peminjaman')
        .where('status peminjaman', isEqualTo: status)
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.size);
  }

  Stream<String> getTotalDendaStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      num totalDenda = 0;
      for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
          in snapshot.docs) {
        totalDenda += userSnapshot['denda'] ?? 0;
      }
      return totalDenda.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      drawer: const DrawerAdmin(),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (userSnapshot.hasError) {
              return Text('Error: ${userSnapshot.error}');
            } else {
              int totalUsers = userSnapshot.data!.docs.length;

              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('buku').snapshots(),
                builder: (context, bookSnapshot) {
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (bookSnapshot.hasError) {
                    return Text('Error: ${bookSnapshot.error}');
                  } else {
                    int totalBooks = bookSnapshot.data!.docs.length;

                    return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      padding: const EdgeInsets.all(10.0),
                      children: [
                        GestureDetector(
                          onTap: () => print('Laporan Jumlah Pelanggan'),
                          child: _buildStatCard('Jumlah Pelanggan',
                              Icons.person, totalUsers.toString()),
                        ),
                        _buildStatCard('Jumlah \Jenis Buku', Icons.book,
                            totalBooks.toString()),
                        StreamBuilder<int>(
                          stream: getPeminjamanStatusStream('terkonfirmasi'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return _buildStatCard(
                                  'Jumlah Buku Yang Sedang Dipinjam',
                                  Icons.bookmark_remove_rounded,
                                  snapshot.data.toString());
                            }
                          },
                        ),
                        StreamBuilder<int>(
                          stream:
                              getPeminjamanStatusStream('telah dikembalikan'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return _buildStatCard(
                                  'Jumlah Buku Dikembalikan',
                                  Icons.bookmark_added_sharp,
                                  snapshot.data.toString());
                            }
                          },
                        ),
                        StreamBuilder<int>(
                          stream: getPeminjamanStatusStream('buku hilang'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return _buildStatCard(
                                  'Jumlah Buku Hilang',
                                  Icons.disabled_by_default,
                                  snapshot.data.toString());
                            }
                          },
                        ),
                        StreamBuilder<String>(
                          stream: getTotalDendaStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return _buildStatCard(
                                  'Total Denda Semua Pengguna',
                                  Icons.attach_money_outlined,
                                  snapshot.data.toString());
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, String value) {
    return Card(
      color: Color.fromARGB(255, 226, 226, 226),
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 60, 57, 57),
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Color.fromARGB(255, 60, 57, 57),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 60, 57, 57),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
