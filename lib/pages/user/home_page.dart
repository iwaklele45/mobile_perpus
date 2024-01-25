import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_perpus/pages/user/all_book.dart';
import 'package:mobile_perpus/pages/user/all_book_genre.dart';
import 'package:mobile_perpus/pages/user/change_profile_user.dart';
import 'package:mobile_perpus/pages/user/history_peminjaman.dart';
import 'package:mobile_perpus/pages/user/login_page.dart';
import 'package:mobile_perpus/pages/user/user_book_pinjam.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  int dendaUser = 0;
  int currentPageIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController searchController = TextEditingController();
  late List<DocumentSnapshot> genreList;

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userName = userSnapshot['full name'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fectDendaUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          dendaUser = userSnapshot['denda'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fectDendaUser();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Image.asset('assets/images/moper.png'),
        ),
        title: const Text(
          'Mobile Perpus',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 60, 57, 57),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.book,
              color: Colors.white,
            ),
            icon: Icon(Icons.book_outlined),
            label: 'Kategori',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.bookmark_add,
              color: Colors.white,
            ),
            icon: Icon(Icons.bookmark_added_outlined),
            label: 'Dipinjam',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        // Home Page
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Selamat Datang, ',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: const Color.fromARGB(255, 60, 57, 57),
                        ),
                      ),
                      Text(
                        '$userName!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 60, 57, 57),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const PageAllBook())),
                            child: const Text(
                              'Semua Buku',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 190,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('buku')
                          .where('stok buku')
                          .orderBy('judul',
                              descending:
                                  false) // Menambahkan pengurutan berdasarkan judul
                          .limit(8)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var books = snapshot.data?.docs;

                        return ListView.builder(
                          itemCount: books?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var book =
                                books?[index].data() as Map<String, dynamic>;
                            var imageUrl = book['imageUrl'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PinjamBuku(
                                      buku: books![index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    imageUrl,
                                    width: 120,
                                    height: 180,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'Rekomendasi Buku',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight - 420,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('buku')
                          .where('stok buku')
                          .limit(10)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var recommendedBooks = snapshot.data?.docs;

                        // Mengacak daftar buku
                        recommendedBooks?.shuffle();

                        return SizedBox(
                          height: 190,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: List.generate(
                                recommendedBooks?.length ?? 0,
                                (index) {
                                  var book = recommendedBooks?[index].data()
                                      as Map<String, dynamic>;
                                  var imageUrl = book['imageUrl'] ?? '';
                                  var author =
                                      book['pengarang'] ?? 'Unknown Author';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PinjamBuku(
                                            buku: recommendedBooks![index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 80,
                                                  height: 100,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        book['judul'],
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '$author',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Tahun : ' +
                                                                book['tahun'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Genre Page
        Column(
          children: [
            const SizedBox(height: 5),
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
                    controller: searchController,
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
                          searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(Icons.clear),
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
                    .collection('genre')
                    .orderBy('nama', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    genreList = snapshot.data!.docs;

                    // Filter the list based on the search query
                    List<DocumentSnapshot> filteredList =
                        genreList.where((document) {
                      var namaGenre = document.data() as Map<String, dynamic>;
                      var namaRak = namaGenre['nama'].toString().toLowerCase();
                      var searchQuery = searchController.text.toLowerCase();

                      return namaRak.contains(searchQuery);
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var namaGenre = filteredList[index].data()
                              as Map<String, dynamic>;
                          var namaRak = namaGenre['nama'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AllGenreBukuPage(
                                    genreName: namaRak,
                                  ),
                                ),
                              );
                            },
                            child: SingleChildScrollView(
                              child: ListTile(
                                title: Text(namaRak),
                              ),
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
        // Pinjam Page
        Column(
          children: [
            const SizedBox(height: 5),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('peminjaman')
                    .where('id user', isEqualTo: user?.uid)
                    .where('status peminjaman', whereIn: [
                  'terkonfirmasi',
                  'belum terkonfirmasi'
                ]).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var peminjamanList = snapshot.data?.docs;

                    if (peminjamanList == null || peminjamanList.isEmpty) {
                      return const Center(
                        child: Text('Anda belum meminjam buku.'),
                      );
                    }

                    var filteredPeminjamanList =
                        peminjamanList.where((peminjaman) {
                      var judulBukuDipinjam =
                          peminjaman['judul buku dipinjam'] as String;
                      return judulBukuDipinjam
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredPeminjamanList.length,
                      itemBuilder: (context, index) {
                        var peminjaman = filteredPeminjamanList[index].data()
                            as Map<String, dynamic>;
                        var judulBukuDipinjam =
                            peminjaman['judul buku dipinjam'];
                        var statusPeminjaman = peminjaman['status peminjaman'];

                        var isConfirmed = statusPeminjaman == 'terkonfirmasi';

                        var isLongTitle =
                            judulBukuDipinjam.split(' ').length > 2;

                        return ListTile(
                          title: Text(
                            '${index + 1}. $judulBukuDipinjam',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: () {
                            switch (statusPeminjaman) {
                              case 'telah dikembalikan':
                                return const Text('Selesai',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700));
                              case 'terkonfirmasi':
                                return const Text('Terkonfirmasi',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700));
                              default:
                                return const Text('Belum Terkonfirmasi',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700));
                            }
                          }(),
                          onTap: () {
                            if (isLongTitle) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Judul Buku'),
                                    content: SizedBox(
                                      height: 120,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(judulBukuDipinjam),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            () {
                                              switch (statusPeminjaman) {
                                                case 'telah dikembalikan':
                                                  return const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Selesai',
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                          'Buku telah dikembalikan.'),
                                                    ],
                                                  );
                                                case 'terkonfirmasi':
                                                  return const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Terkonfirmasi',
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                          'Silahkan Pergi Ke Perpustakaan Untuk Menggambil Buku')
                                                    ],
                                                  );
                                                default:
                                                  return const Text(
                                                    'Belum Terkonfirmas',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  );
                                              }
                                            }(),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Tutup'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        // Settings Page
        Center(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 203, 203, 203),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    bottom: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 55,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Denda : ' + dendaUser.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.red),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const UbahProfile()));
                        },
                        child: const Text(
                          'UBAH PROFIL',
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const HistoryPeminjamanUser()));
                      },
                      child: const SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.settings_backup_restore_rounded,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'History',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Cek history buku yang dipinjam',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 203, 203, 203),
                      height: 2.0,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 25,
                              color: Colors.deepOrange,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.deepOrange,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ][currentPageIndex],
    );
  }
}
