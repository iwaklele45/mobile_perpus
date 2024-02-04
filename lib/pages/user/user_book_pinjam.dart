import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class PinjamBuku extends StatefulWidget {
  final DocumentSnapshot buku;

  const PinjamBuku({Key? key, required this.buku}) : super(key: key);

  @override
  State<PinjamBuku> createState() => _PinjamBukuState();
}

class _PinjamBukuState extends State<PinjamBuku> {
  StreamSubscription<QuerySnapshot>? _favBookSubscription;
  String dropdownValue1 = list.first;
  String userName = '';
  bool favBook = false;
  File? coverBook;
  User? user = FirebaseAuth.instance.currentUser;
  StreamSubscription<DocumentSnapshot>? wishlistSubscription;
  Future<void> fetchUserData() async {
    try {
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();

        setState(() {
          userName = userSnapshot['full name'] ?? 'Username';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreviousImage();
    fetchUserData();
    _listenToFavBookChanges();
  }

  void _listenToFavBookChanges() {
    try {
      _favBookSubscription = FirebaseFirestore.instance
          .collection('favBook')
          .where('id book fav', isEqualTo: widget.buku.id)
          .where('id user fav', isEqualTo: user?.uid)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        setState(() {
          favBook = snapshot.docs.isNotEmpty;
        });
      });
    } catch (e) {
      setState(() {
        favBook = false;
      });
      print('Error: ${e.toString()}');
    }
  }

  void _dispose() {
    _favBookSubscription?.cancel();
  }

  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _addFavoriteBook() async {
    try {
      await FirebaseFirestore.instance.collection('favBook').add({
        'id book fav': widget.buku.id,
        'id user fav': user?.uid,
        'judul buku': widget.buku['judul'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menambahkan buku ke favorite')),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _removeFavoriteBook() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('favBook')
          .where('id book fav', isEqualTo: widget.buku.id)
          .where('id user fav', isEqualTo: user?.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentReference = querySnapshot.docs.first.reference;
        await documentReference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menghapus buku dari favorite')),
        );
        Navigator.pop(context);
      } else {
        print('Dokumen tidak ditemukan untuk dihapus');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _checkFavBook() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('favBook')
          .where('id book fav', isEqualTo: widget.buku.id)
          .where('id user fav', isEqualTo: user?.uid)
          .get();

      setState(() {
        favBook = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        favBook = false;
      });
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _loadPreviousImage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    void _showFineAlertDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tidak Bisa Meminjam Buku!'),
            content: const Text(
                'Karena anda masih memiliki denda, anda tidak bisa meminjam buku, silahkan lagkukan pembayaran!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    }

    Future<bool> _hasFine() async {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          int userFine = userSnapshot['denda'] ?? 0;

          return userFine > 0;
        }
        return false;
      } catch (e) {
        print('Error checking for fine: $e');
        return true;
      }
    }

    void _addPeminjaman(int days) async {
      try {
        bool hasFine = await _hasFine();
        if (hasFine) {
          _showFineAlertDialog();
          return;
        }

        int currentStok = widget.buku['stokBuku'];
        int updatedStok = currentStok - 1;

        DateTime now = DateTime.now();
        DateTime tanggalPengembalian = now.add(Duration(days: days));

        if (updatedStok >= 0) {
          await FirebaseFirestore.instance
              .collection('buku')
              .doc(widget.buku.id)
              .update({
            'stokBuku': updatedStok,
          });

          User? user = FirebaseAuth.instance.currentUser;

          await FirebaseFirestore.instance.collection('peminjaman').add({
            'id user': user?.uid,
            'nama peminjam': userName,
            'tanggal peminjaman': now,
            'tanggal pengembalian': tanggalPengembalian,
            'id buku dipinjam': widget.buku.id,
            'judul buku dipinjam': widget.buku['judul'],
            'status peminjaman': 'belum terkonfirmasi',
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Berhasil Meminjam Buku'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Maaf, stok buku tidak mencukupi'),
          ));
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error adding peminjaman: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal Meminjam Buku'),
        ));
        return;
      }
    }

    void _showDateDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pilih Lama Peminjaman : '),
            content: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _addPeminjaman(3);
                      Navigator.of(context).pop();
                    },
                    child: const Text('3 Hari'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addPeminjaman(7);
                      Navigator.of(context).pop();
                    },
                    child: const Text('7 Hari'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addPeminjaman(30);
                      Navigator.of(context).pop();
                    },
                    child: const Text('30 Hari'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            size: 25,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: favBook
                ? GestureDetector(
                    onTap: _removeFavoriteBook,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 30,
                    ),
                  )
                : GestureDetector(
                    onTap: _addFavoriteBook,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      widget.buku['imageUrl'],
                      width: 200,
                      height: 220,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.buku['judul'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'By : ' + widget.buku['pengarang'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Rak Buku : ' + widget.buku['rak'],
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Tahun : ' + widget.buku['tahun'],
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Stok Buku : ${widget.buku['stokBuku'].toString()}',
                              style: const TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Sinopsis :',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(widget.buku['sinopsis']),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 60, 57, 57),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: Text(
                          widget.buku['genre'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showDateDialog();
          print(user?.uid);
        },
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: const Text(
          'Pinjam Buku',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
