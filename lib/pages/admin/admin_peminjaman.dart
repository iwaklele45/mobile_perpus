import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/pages/admin/user_pinjam_buku.dart';

class PagePeminjaman extends StatefulWidget {
  const PagePeminjaman({Key? key}) : super(key: key);

  @override
  State<PagePeminjaman> createState() => _PagePeminjamanState();
}

class _PagePeminjamanState extends State<PagePeminjaman> {
  late List<DocumentSnapshot> peminjamanList;
  late int _selectedItemIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peminjaman Buku')),
      body: Column(
        children: [
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
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('peminjaman')
                  .where('status peminjaman', isEqualTo: 'belum terkonfirmasi')
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

                  // Filter the list based on the search query
                  List<MapEntry<String, List<DocumentSnapshot>>> filteredList =
                      groupedPeminjaman.entries
                          .where((entry) =>
                              entry.key.contains(_searchController.text))
                          .toList();

                  if (filteredList.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        var entry = filteredList[index];
                        var namaPeminjam = entry.key;
                        var borrowedBooks = entry.value;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedItemIndex = index;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPinjamBuku(
                                  userId: borrowedBooks[0]['id user'],
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
          ),
        ],
      ),
    );
  }
}
