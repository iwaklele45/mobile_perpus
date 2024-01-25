import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/pages/admin/edit_buku.dart';
import 'package:mobile_perpus/pages/admin/add_book.dart';

class PageBuku extends StatefulWidget {
  const PageBuku({super.key});

  @override
  State<PageBuku> createState() => _PageBukuState();
}

class _PageBukuState extends State<PageBuku> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Widget _buildBookList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('buku').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var bukuList = snapshot.data!.docs;

          List<DocumentSnapshot> filteredBukuList = bukuList.where((buku) {
            var judul = buku['judul'].toLowerCase();
            var searchQuery = _searchController.text.toLowerCase();

            return judul.contains(searchQuery);
          }).toList();
          if (filteredBukuList.isEmpty) {
            return const Center(
              child: Text(
                'Tidak Ada Buku',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredBukuList.length,
            itemBuilder: (context, index) {
              var buku = filteredBukuList[index];
              return ListTile(
                onTap: () {
                  _showDetailBukuDialog(context, buku);
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      buku['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    buku['judul'], overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Set the maximum number of lines
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                trailing: Text('Tahun Terbit: ${buku['tahun']}'),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku'),
      ),
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
          const SizedBox(
            height: 10,
          ),
          Expanded(child: _buildBookList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: const Text(
          'Tambah Buku',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: ((context) => const TambahBuku())));
        },
      ),
    );
  }

  void _showDetailBukuDialog(BuildContext context, DocumentSnapshot buku) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Buku'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.network(
                    buku['imageUrl'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Judul: ${buku['judul']}'),
                Text('Stok: ${buku['stokBuku']}'),
                Text('Kategori: ${buku['genre']}'),
                Text('Pengarang: ${buku['pengarang']}'),
                Text('Penerbit: ${buku['penerbit']}'),
                Text('Tahun Terbit: ${buku['tahun']}'),
                Text('Rak: ${buku['rak']}'),
                SizedBox(
                  height: 10,
                ),
                Text('Sinopsis: ${buku['sinopsis']}'),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deleteBuku(buku);
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditBuku(
                              buku: buku,
                            )));
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBuku(DocumentSnapshot buku) async {
    try {
      await FirebaseFirestore.instance.collection('buku').doc(buku.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil di hapus!')));
    } catch (e) {
      print('Error deleting book: $e');
    }
  }
}
