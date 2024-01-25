import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class CetakBuku extends StatefulWidget {
  const CetakBuku({Key? key}) : super(key: key);

  @override
  State<CetakBuku> createState() => _CetakBukuState();
}

class _CetakBukuState extends State<CetakBuku> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Buku'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buku').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var peminjamanList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: peminjamanList.length,
              itemBuilder: (context, index) {
                var peminjaman = peminjamanList[index];
                return ListTile(
                  title: Text(
                    '${index + 1}. Buku: ${peminjaman['judul']}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pengarang: ${peminjaman['pengarang']}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pengerbit: ${peminjaman['penerbit']}'),
                          Text('Tahun: ${peminjaman['tahun']}'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _generatePdfAndSave();
        },
        backgroundColor: const Color.fromARGB(255, 60, 57, 57),
        label: const Text(
          'PRINT',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<String?> _pickDirectory() async {
    Directory? directory = await getExternalStorageDirectory();

    if (directory != null) {
      print('Selected Directory: ${directory.path}');
      return directory.path;
    } else {
      print('Failed to pick directory.');
      return null;
    }
  }

  Future<void> _generatePdfAndSave() async {
    String? directoryPath = await _pickDirectory();

    if (directoryPath != null) {
      // Check if the directory exists, create it if not
      Directory directory = Directory(directoryPath);
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }

      final pdf = pw.Document();
      final data = await fetchData();
      await generatePDF(pdf, data);

      await savePDF(pdf, directoryPath);
    } else {
      // Handle the case where the user cancels directory picking
      print('Directory picking canceled.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('buku').get();

    return querySnapshot.docs.map((DocumentSnapshot document) {
      return document.data() as Map<String, dynamic>;
    }).toList();
  }

  Future<void> generatePDF(
      pw.Document pdf, List<Map<String, dynamic>> data) async {
    final ByteData image = await rootBundle.load('assets/images/moper.png');
    Uint8List imageData = (image).buffer.asUint8List();
    String _formatTimestamp(Timestamp timestamp) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
    }

    pdf.addPage(
      pw.Page(
        orientation:
            pw.PageOrientation.landscape, // Set the orientation to landscape
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.Image(pw.MemoryImage(imageData)),
              pw.SizedBox(width: 5),
              pw.Text('Mobile Perpus',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 18)),
            ]),
            pw.SizedBox(height: 10),
            pw.Text('Tabel Buku',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
            pw.SizedBox(height: 5),
            pw.Text(
                'Tanggal Cetak: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}'),
            pw.SizedBox(
              height: 10,
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(20),
                1: const pw.FixedColumnWidth(70),
                2: const pw.FixedColumnWidth(180),
                3: const pw.FixedColumnWidth(100),
                4: const pw.FixedColumnWidth(100),
                5: const pw.FixedColumnWidth(80),
                6: const pw.FixedColumnWidth(60),
                7: const pw.FixedColumnWidth(40),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 3),
                        child: pw.Text('No',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 3),
                        child: pw.Text('Rak',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Judul',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 5),
                        child: pw.Text('Penerbit',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Pengarang',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Kategori',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Tahun',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Stok',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                for (var index = 0; index < data.length; index++)
                  pw.TableRow(
                    children: [
                      pw.Center(child: pw.Text('${index + 1}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['rak']}')),
                      pw.Padding(
                          padding:
                              const pw.EdgeInsets.only(left: 10, right: 10),
                          child: pw.Text('${data[index]['judul']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['penerbit']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['pengarang']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['genre']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['tahun']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['stokBuku']}')),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> savePDF(pw.Document pdf, String directoryPath) async {
    try {
      final fileName = 'Cetak-Buku-${DateTime.now()}.pdf';
      final file = File('$directoryPath/$fileName');
      await file.writeAsBytes(await pdf.save());
      print('${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF disimpan di: ${file.path}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan PDF'),
        ),
      );
      print(e.toString());
    }
  }
}
