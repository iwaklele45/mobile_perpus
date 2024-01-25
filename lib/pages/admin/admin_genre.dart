import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PageGenre extends StatefulWidget {
  const PageGenre({Key? key}) : super(key: key);

  @override
  State<PageGenre> createState() => _PageGenreState();
}

class _PageGenreState extends State<PageGenre> {
  final TextEditingController _rakController = TextEditingController();
  late int _selectedItemIndex;
  late List<DocumentSnapshot> genreBukuList;
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
      appBar: AppBar(title: const Text('Kategori Buku')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
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
                stream:
                    FirebaseFirestore.instance.collection('genre').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    genreBukuList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        genreBukuList.where((document) {
                      var rakData = document.data() as Map<String, dynamic>;
                      var namaRak = rakData['nama'].toString().toLowerCase();
                      var searchQuery = _searchController.text.toLowerCase();

                      return namaRak.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var rakData = filteredList[index].data()
                              as Map<String, dynamic>;
                          var namaRak = rakData['nama'];

                          return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _selectedItemIndex =
                                    genreBukuList.indexOf(filteredList[index]);
                              });
                              _showOptionsDialog(context);
                            },
                            child: ListTile(
                              title: Text(namaRak),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Tidak ada genre buku',
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: const Text(
          'Tambah Kategori',
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
          _showTambahGenreDialog(context);
        },
      ),
    );
  }

  void _showTambahGenreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Buku'),
          content: TextField(
            controller: _rakController,
            decoration: const InputDecoration(labelText: 'Nama Kategori Buku'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _tambahGenreBuku();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _tambahGenreBuku() async {
    try {
      String namaRak = _rakController.text;

      if (namaRak.isNotEmpty) {
        await FirebaseFirestore.instance.collection('genre').add({
          'nama': namaRak,
        });

        _rakController.clear();

        print('Genre Buku berhasil ditambahkan: $namaRak');
      } else {
        print('Genre Rak Buku tidak boleh kosong');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilihan'),
          content: const Text('Pilih opsi untuk item terpilih'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editGenreBuku();
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _hapusGenreBuku();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _editGenreBuku() {
    String currentNamaRak = genreBukuList[_selectedItemIndex]['nama'];

    TextEditingController _editController =
        TextEditingController(text: currentNamaRak);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Kategori Buku'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori Buku',
              hintText: 'Kategori Baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_editController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Kolom tidak boleh kosong!')));
                } else {
                  _simpanEditGenreBuku(currentNamaRak, _editController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _simpanEditGenreBuku(String currentNamaRak, String editedNamaRak) async {
    try {
      if (currentNamaRak != editedNamaRak) {
        await FirebaseFirestore.instance
            .collection('genre')
            .doc(genreBukuList[_selectedItemIndex].id)
            .update({'nama': editedNamaRak});

        print('Genre Buku berhasil diedit: $currentNamaRak -> $editedNamaRak');
      } else {
        print('Tidak ada perubahan pada nama genre');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _hapusGenreBuku() async {
    try {
      bool isGenreTerpakai = await _cekGenreTerpakai();

      if (isGenreTerpakai) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Genre Buku masih terpakai oleh beberapa buku.'),
          ),
        );
      } else {
        FirebaseFirestore.instance
            .collection('genre')
            .doc(genreBukuList[_selectedItemIndex].id)
            .delete();

        print('Genre Buku berhasil dihapus');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> _cekGenreTerpakai() async {
    try {
      String namaGenre = genreBukuList[_selectedItemIndex]['nama'];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buku')
          .where('genre', isEqualTo: namaGenre)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
