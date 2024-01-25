import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_area/text_area.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class EditBuku extends StatefulWidget {
  final DocumentSnapshot buku;

  const EditBuku({Key? key, required this.buku}) : super(key: key);

  @override
  State<EditBuku> createState() => _EditBukuState();
}

class _EditBukuState extends State<EditBuku> {
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  File? _editImage;
  String? _previousImageUrl;

  Future<void> _loadPreviousImage() async {
    String existingImageUrl = widget.buku['imageUrl'];
    if (existingImageUrl.isNotEmpty) {
      setState(() {
        _editImage = File(existingImageUrl);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreviousImage();
    _judulBukuController.text = widget.buku['judul'];
    _penerbitBukuController.text = widget.buku['penerbit'];
    _pengarangBukuController.text = widget.buku['pengarang'];
    _tahunBukuController.text = widget.buku['tahun'];
    _sinopsisBukuController.text = widget.buku['sinopsis'];
    _stokBuku.text = widget.buku['stokBuku'].toString();
    selectedRak = widget.buku['rak'];
    selectedGenre = widget.buku['genre'];
    String? _editImageUrl = widget.buku['imageUrl'];

    String existingImageUrl = widget.buku['imageUrl'];
    if (existingImageUrl != null && existingImageUrl.isNotEmpty) {}
  }

  Future<String> downloadImage(String imageUrl) async {
    return imageUrl;
  }

  Future<void> _pickEditImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File editedImage = File(pickedFile.path);
        String imageUrl = await _uploadImage(editedImage);

        setState(() {
          _editImage = editedImage;
          _previousImageUrl = imageUrl;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      firebase_storage.UploadTask uploadTask = storageReference.putFile(image);

      await uploadTask.whenComplete(() => null);

      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
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
        selectedRak.toString() == '0' ||
        _stokBuku.text.isEmpty ||
        selectedGenre.toString() == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kolom harus di isi semua!')),
      );
      setState(() {
        _isLoading = false;
      });
      print("kosong");
    } else {
      try {
        final bookRef = _firestore.collection('buku').doc(widget.buku.id);

        String existingImageUrl = widget.buku['imageUrl'] ?? '';

        // Check if a new image is selected
        if (_editImage != null && _editImage!.path != existingImageUrl) {
          String imageUrl = await _uploadImage(_editImage!);

          // Only update the image URL if a new image is selected
          await bookRef.update({
            'imageUrl': imageUrl,
          });
        }

        await bookRef.update({
          'judul': _judulBukuController.text,
          'pengarang': _pengarangBukuController.text,
          'penerbit': _penerbitBukuController.text,
          'tahun': _tahunBukuController.text,
          'sinopsis': _sinopsisBukuController.text,
          'rak': selectedRak,
          'genre': selectedGenre,
          'stokBuku': int.parse(_stokBuku.text),
        });

        _judulBukuController.clear();
        _pengarangBukuController.clear();
        _penerbitBukuController.clear();
        _tahunBukuController.clear();
        _sinopsisBukuController.clear();

        setState(() {
          selectedGenre = '0';
          selectedRak = '0';
          // Reset _editImage after saving
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku Berhasil Diedit')),
        );
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
        title: const Text('Edit Buku'),
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
                        Icons.numbers_outlined,
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
                  Text(_editImage == null ? 'Pilih Gambar' : 'Ubah Gambar'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await _pickEditImage();
              },
              child: Column(
                children: [
                  _editImage == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(Icons.camera_alt),
                          ),
                        )
                      : _editImage!.path.startsWith('https://') ||
                              _editImage!.path.startsWith('http://')
                          ? Image.network(
                              _editImage!.path,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _editImage!,
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
