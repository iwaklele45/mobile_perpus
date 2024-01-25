import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PageRakBuku extends StatefulWidget {
  const PageRakBuku({Key? key}) : super(key: key);

  @override
  State<PageRakBuku> createState() => _PageRakBukuState();
}

class _PageRakBukuState extends State<PageRakBuku> {
  final TextEditingController _rakController = TextEditingController();
  late int _selectedItemIndex;
  late List<DocumentSnapshot> rakBukuList;
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
      appBar: AppBar(title: const Text('Rak Buku')),
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
                stream: FirebaseFirestore.instance
                    .collection('rakBuku')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    rakBukuList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        rakBukuList.where((document) {
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
                                    rakBukuList.indexOf(filteredList[index]);
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
                          'Tidak ada rak buku',
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
          'Tambah Rak',
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
          _showTambahRakDialog(context);
        },
      ),
    );
  }

  void _showTambahRakDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Rak Buku'),
          content: TextField(
            controller: _rakController,
            decoration: const InputDecoration(labelText: 'Nama Rak Buku'),
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
                _tambahRakBuku();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _tambahRakBuku() async {
    try {
      String namaRak = _rakController.text;

      if (namaRak.isNotEmpty) {
        await FirebaseFirestore.instance.collection('rakBuku').add({
          'nama': namaRak,
        });

        _rakController.clear();

        print('Rak Buku berhasil ditambahkan: $namaRak');
      } else {
        print('Nama Rak Buku tidak boleh kosong');
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
                    _editRakBuku();
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _hapusRakBuku();
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

  void _editRakBuku() {
    String currentNamaRak = rakBukuList[_selectedItemIndex]['nama'];
    print('edit rak');

    TextEditingController _editController =
        TextEditingController(text: currentNamaRak);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Rak Buku'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              labelText: 'Nama Rak Buku',
              hintText: 'Rak Baru',
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
                  _simpanEditRakBuku(currentNamaRak, _editController.text);
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

  void _simpanEditRakBuku(String currentNamaRak, String editedNamaRak) async {
    try {
      if (currentNamaRak != editedNamaRak) {
        await FirebaseFirestore.instance
            .collection('rakBuku')
            .doc(rakBukuList[_selectedItemIndex].id)
            .update({'nama': editedNamaRak});

        print('Rak Buku berhasil diedit: $currentNamaRak -> $editedNamaRak');
      } else {
        print('Tidak ada perubahan pada nama rak');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _hapusRakBuku() async {
    try {
      bool isRakTerpakai = await _cekRakTerpakai();

      if (isRakTerpakai) {
        // Jika rak buku masih terpakai, tampilkan pesan peringatan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rak Buku masih terpakai oleh beberapa buku.'),
          ),
        );
      } else {
        // Jika rak buku tidak terpakai, hapus rak buku
        FirebaseFirestore.instance
            .collection('rakBuku')
            .doc(rakBukuList[_selectedItemIndex].id)
            .delete();

        print('Rak Buku berhasil dihapus');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> _cekRakTerpakai() async {
    try {
      String namaRak = rakBukuList[_selectedItemIndex]['nama'];

      // Periksa apakah ada buku yang menggunakan rak ini
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buku')
          .where('rak', isEqualTo: namaRak)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error: $e');
      return true; // Anggap rak terpakai jika terjadi kesalahan
    }
  }
}
