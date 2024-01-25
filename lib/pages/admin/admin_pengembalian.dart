import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/pages/admin/user_pengembalian_buku.dart';

class PagePengembalian extends StatefulWidget {
  const PagePengembalian({Key? key}) : super(key: key);

  @override
  State<PagePengembalian> createState() => _PagePengembalianState();
}

class _PagePengembalianState extends State<PagePengembalian> {
  late List<DocumentSnapshot> peminjamanList;
  int _selectedItemIndex = -1;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengembalian Buku')),
      body: Column(
        children: [
          SizedBox(
            height: 10,
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
                  keyboardType: TextInputType.text,
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
                      child: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('peminjaman')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  peminjamanList = snapshot.data!.docs;

                  // Group the borrowed books by user's name
                  Map<String, List<DocumentSnapshot>> groupedPeminjaman = {};
                  for (var peminjaman in peminjamanList) {
                    var namaPeminjam = peminjaman['nama peminjam'].toString();
                    if (!groupedPeminjaman.containsKey(namaPeminjam)) {
                      groupedPeminjaman[namaPeminjam] = [];
                    }
                    groupedPeminjaman[namaPeminjam]!.add(peminjaman);
                  }

                  // Filter the list based on the search query and confirmed status
                  List<MapEntry<String, List<DocumentSnapshot>>> filteredList =
                      groupedPeminjaman.entries
                          .where((entry) =>
                              entry.key.contains(_searchController.text) &&
                              entry.value.any((peminjaman) =>
                                  peminjaman['status peminjaman'] ==
                                  'terkonfirmasi'))
                          .toList();

                  if (filteredList.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        var entry = filteredList[index];
                        var namaPeminjam = entry.key;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedItemIndex = index;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPengembalianBuku(
                                  userId: entry.value[0]['id user'],
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text('${index + 1}. $namaPeminjam'),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Tidak ada peminjaman buku terkonfirmasi',
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
}
