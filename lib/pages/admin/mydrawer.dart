import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_perpus/pages/admin/admin_book.dart';
import 'package:mobile_perpus/pages/admin/admin_denda_user.dart';
import 'package:mobile_perpus/pages/admin/admin_genre.dart';
import 'package:mobile_perpus/pages/admin/admin_peminjaman.dart';
import 'package:mobile_perpus/pages/admin/admin_rak_buku.dart';
import 'package:mobile_perpus/pages/admin/admin_user.dart';
import 'package:mobile_perpus/pages/admin/admin_pengembalian.dart';

class DrawerAdmin extends StatefulWidget {
  const DrawerAdmin({super.key});

  @override
  State<DrawerAdmin> createState() => _DrawerAdminState();
}

class _DrawerAdminState extends State<DrawerAdmin> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Admin'),
            accountEmail: Text(user.email!),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/profile-bg3.jpg')),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logomoperr.png',
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PagePelanggan()));
            },
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('Pelanggan'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PageRakBuku()));
            },
            child: const ListTile(
              leading: Icon(Icons.shelves),
              title: Text('Rak'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PageGenre()));
            },
            child: const ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Kategori'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PageBuku()));
            },
            child: const ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('Buku'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PagePeminjaman()));
            },
            child: const ListTile(
              leading: Icon(Icons.front_hand_sharp),
              title: Text('Peminjaman'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PagePengembalian()));
            },
            child: const ListTile(
              leading: Icon(Icons.restart_alt_rounded),
              title: Text('Pengembalian'),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PageDenda())),
            child: const ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Denda'),
            ),
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.pink,
                ),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(
                    //     builder: (context) => const LoginPage()));
                    setState(() {});
                  },
                  child: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
