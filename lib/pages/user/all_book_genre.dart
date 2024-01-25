import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_perpus/pages/user/user_book_pinjam.dart';

class AllGenreBukuPage extends StatefulWidget {
  final String genreName;

  const AllGenreBukuPage({Key? key, required this.genreName}) : super(key: key);

  @override
  State<AllGenreBukuPage> createState() => _AllGenreBukuPageState();
}

class _AllGenreBukuPageState extends State<AllGenreBukuPage> {
  late List<DocumentSnapshot> books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buku Genre ${widget.genreName}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buku')
            .where('genre', isEqualTo: widget.genreName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada buku untuk genre ini',
                style: TextStyle(fontSize: 15),
              ),
            );
          } else {
            books = snapshot.data!.docs;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                var bookData = books[index].data() as Map<String, dynamic>;
                var title = bookData['judul'];
                var author = bookData['pengarang'];
                var coverUrl = bookData['imageUrl'];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PinjamBuku(
                          buku: books[index],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
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
                            title: Text(title),
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
          }
        },
      ),
    );
  }
}
