import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PageDenda extends StatefulWidget {
  const PageDenda({Key? key}) : super(key: key);

  @override
  State<PageDenda> createState() => _PageDendaState();
}

class _PageDendaState extends State<PageDenda> {
  late List<DocumentSnapshot> userDendaList;
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
      appBar: AppBar(title: const Text('Denda User')),
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
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    userDendaList = snapshot.data!.docs;

                    List<DocumentSnapshot> filteredList =
                        userDendaList.where((document) {
                      var userData = document.data() as Map<String, dynamic>;
                      var namaUser = userData['full name'];
                      var denda = userData['denda'];

                      var namaUserLower = namaUser.toString().toLowerCase();
                      var searchQuery = _searchController.text.toLowerCase();

                      return namaUserLower.contains(searchQuery) &&
                          denda != null &&
                          denda > 0;
                    }).toList();

                    if (filteredList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          var userData = filteredList[index].data()
                              as Map<String, dynamic>;
                          var namaUser = userData['full name'];
                          var denda = userData['denda'];

                          return GestureDetector(
                            onTap: () {
                              _showPaymentDialog(context, namaUser, denda);
                            },
                            child: ListTile(
                              title: Text(namaUser),
                              subtitle: Text('Denda: $denda'),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Tidak ada user yang di denda',
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

  void _showPaymentDialog(BuildContext context, String namaUser, int? denda) {
    TextEditingController _nominalController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pembayaran Denda - $namaUser'),
          content: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Denda: ${denda ?? 0}'),
                TextField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: 15,
                      ),
                      hintText: 'Masukkan Nominal!'),
                )
              ],
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
                int? nominal = int.tryParse(_nominalController.text);
                if (nominal != null && nominal > 0) {
                  _handlePayment(namaUser, denda, nominal);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nominal tidak valid!')),
                  );
                }
              },
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );
  }

  void _handlePayment(String namaUser, int? denda, int nominal) async {
    if (denda != null && denda > 0) {
      if (nominal <= denda) {
        // Perubahan: Memungkinkan pembayaran lebih besar dari atau sama dengan denda
        int remainingBalance = denda - nominal;

        try {
          QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
              .instance
              .collection('users')
              .where('full name', isEqualTo: namaUser)
              .get();

          if (snapshot.docs.isNotEmpty) {
            String userId = snapshot.docs.first.id;

            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'denda': remainingBalance});
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Pembayaran denda oleh $namaUser sejumlah $nominal berhasil!')),
            );

            print(
                'Pembayaran denda oleh $namaUser sejumlah $nominal berhasil!');
          } else {
            print('User $namaUser tidak ditemukan.');
          }
        } catch (e) {
          print('Error updating user data: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Pembayaran denda gagal nominal : $nominal lebih besar dari denda : $denda')),
        );
      }
    }
  }
}
