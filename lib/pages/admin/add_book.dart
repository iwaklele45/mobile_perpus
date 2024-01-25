import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_area/text_area.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class TambahBuku extends StatefulWidget {
  const TambahBuku({super.key});

  @override
  State<TambahBuku> createState() => _TambahBukuState();
}

class _TambahBukuState extends State<TambahBuku> {
  String dropdownValue1 = list.first;
  String dropdownValue2 = list.first;
  String textAreaValue = '';
  String selectedRak = '0';
  String selectedGenre = '0';
  var reasonValidation = true;
  File? _image;
  TextEditingController _judulBukuController = TextEditingController();
  TextEditingController _penerbitBukuController = TextEditingController();
  TextEditingController _pengarangBukuController = TextEditingController();
  TextEditingController _sinopsisBukuController = TextEditingController();
  TextEditingController _tahunBukuController = TextEditingController();
  TextEditingController _stokBuku = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _saveBook() async {
    setState(() {
      _isLoading = true;
    });
    if (_judulBukuController.text.isEmpty ||
        _penerbitBukuController.text.isEmpty ||
        _pengarangBukuController.text.isEmpty ||
        _tahunBukuController.text.isEmpty ||
        _sinopsisBukuController.text.isEmpty ||
        _stokBuku.text.isEmpty ||
        selectedRak.toString() == '0' ||
        selectedGenre.toString() == '0' ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kolom harus di isi semua!')),
      );
      setState(() {
        _isLoading = false;
      });
      print("kosong");
    } else {
      try {
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('images')
            .child('buku_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_image!);
        String imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('buku').add({
          'judul': _judulBukuController.text,
          'pengarang': _pengarangBukuController.text,
          'penerbit': _penerbitBukuController.text,
          'tahun': _tahunBukuController.text,
          'sinopsis': _sinopsisBukuController.text,
          'stokBuku': int.parse(_stokBuku.text), // Ubah ke tipe data int
          'imageUrl': imageUrl,
          'rak': selectedRak,
          'genre': selectedGenre,
          'statusBuku': 'tidak dipinjam',
        });
        _judulBukuController.clear();
        _pengarangBukuController.clear();
        _penerbitBukuController.clear();
        _tahunBukuController.clear();
        _sinopsisBukuController.clear();
        _stokBuku.clear();

        _image = null;
        setState(() {
          selectedGenre = '0';
          selectedRak = '0';
        });
        print('Buku berhasil ditambahkan: $_judulBukuController');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buku Berhasil Ditambahkan')));
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
      setState(() {});
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Buku'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _judulBukuController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Judul Buku',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _penerbitBukuController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Penerbit Buku',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.other_houses_rounded,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    maxLength: 15,
                    controller: _pengarangBukuController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: 'Pengarang Buku',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    maxLength: 4,
                    controller: _tahunBukuController,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: 'Tahun Terbit Buku',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.numbers_outlined,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    maxLength: 4,
                    controller: _stokBuku,
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: 'Stok Buku',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.format_list_numbered,
                        color: Color.fromARGB(255, 60, 57, 57),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: Colors.grey[200],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rakBuku')
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> rakItems = [];
                        if (!snapshot.hasData) {
                          const CircularProgressIndicator();
                        } else {
                          final raks = snapshot.data?.docs.reversed.toList();
                          rakItems.add(
                            const DropdownMenuItem(
                              value: '0',
                              child: Text(
                                'Pilih Rak',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                          for (var rak in raks!) {
                            rakItems.add(
                              DropdownMenuItem(
                                value: rak['nama'],
                                child: Text(
                                  rak['nama'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return DropdownButtonHideUnderline(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton(
                                value: selectedRak,
                                items: rakItems,
                                onChanged: (rakValue) {
                                  setState(() {
                                    selectedRak = rakValue;
                                  });
                                  print(rakValue);
                                }),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: Colors.grey[200],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('genre')
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> genreItems = [];
                        if (!snapshot.hasData) {
                          const CircularProgressIndicator();
                        } else {
                          final genres = snapshot.data?.docs.reversed.toList();
                          genreItems.add(
                            const DropdownMenuItem(
                              value: '0',
                              child: Text(
                                'Pilih Kategori',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                          for (var genre in genres!) {
                            genreItems.add(
                              DropdownMenuItem(
                                value: genre['nama'],
                                child: Text(
                                  genre['nama'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return DropdownButtonHideUnderline(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton(
                                value: selectedGenre,
                                items: genreItems,
                                onChanged: (rakValue) {
                                  setState(() {
                                    selectedGenre = rakValue;
                                  });
                                  print(rakValue);
                                }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Row(
                    children: [
                      Text('Sinopsis Buku'),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: Colors.grey[200],
                    ),
                    child: TextArea(
                      textEditingController: _sinopsisBukuController,
                      validation: reasonValidation,
                      borderRadius: 10,
                      borderColor: const Color(0xFFCFD6FF),
                      errorText: 'Masukkan Sinopsis Buku',
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(_image == null ? 'Pilih Gambar' : 'Ubah Gambar'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                _pickImage();
              },
              child: Column(
                children: [
                  _image == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(Icons.camera_alt),
                          ),
                        )
                      : Image.file(
                          _image!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: _isLoading
            ? const CircularProgressIndicator(
                strokeAlign: -4,
                color: Colors.white,
              )
            : const Text(
                'Simpan Buku',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
        onPressed: () {
          _isLoading ? null : _saveBook();
        },
      ),
    );
  }
}
