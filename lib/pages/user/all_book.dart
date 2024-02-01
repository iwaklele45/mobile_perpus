import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/pages/user/user_book_pinjam.dart';

class PageAllBook extends StatefulWidget {
  const PageAllBook({Key? key}) : super(key: key);

  @override
  State<PageAllBook> createState() => _PageAllBookState();
}

class _PageAllBookState extends State<PageAllBook> {
  late List<DocumentSnapshot> bookList;
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
      appBar: AppBar(title: const Text('All Books')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Container(
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
                    hintText: 'Search by Author or Title',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('buku')
                    .orderBy('judul', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    bookList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        bookList.where((document) {
                      var bookData = document.data() as Map<String, dynamic>;
                      var author =
                          bookData['pengarang'].toString().toLowerCase();
                      var title = bookData['judul'].toString().toLowerCase();
                      var searchQuery = _searchController.text.toLowerCase();

                      return author.contains(searchQuery) ||
                          title.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var bookData = filteredList[index].data()
                              as Map<String, dynamic>;
                          bookList.length;
                          var book =
                              bookList[index].data() as Map<String, dynamic>;
                          var author = bookData['pengarang'];
                          var coverUrl = bookData['imageUrl'];
                          var titleBook = bookData['judul'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PinjamBuku(
                                    buku: bookList[index],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      coverUrl,
                                      width: 80,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(titleBook),
                                      subtitle: Text(
                                        'Pengarang: $author',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Tidak ada buku',
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
    );
  }
}
