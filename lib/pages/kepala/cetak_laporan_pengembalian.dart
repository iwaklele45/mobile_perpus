import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class CetakPengembalian extends StatefulWidget {
  const CetakPengembalian({Key? key}) : super(key: key);

  @override
  State<CetakPengembalian> createState() => _CetakPengembalianState();
}

class _CetakPengembalianState extends State<CetakPengembalian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Pengembalian'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('peminjaman')
            .where('status peminjaman', isEqualTo: 'telah dikembalikan')
            .snapshots(),
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
                    '${index + 1}. Buku: ${peminjaman['judul buku dipinjam']}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Peminjam: ${peminjaman['nama peminjam']}'),
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

  Future<void> _generatePdfAndSave() async {
    final pdf = pw.Document();

    final data = await fetchData();
    await generatePDF(pdf, data);

    String? directoryPath = await _pickDirectory();
    if (directoryPath != null) {
      await savePDF(pdf, directoryPath);
    }
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

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('peminjaman')
        .where('status peminjaman', isEqualTo: 'telah dikembalikan')
        .get();

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
        orientation: pw.PageOrientation.landscape,
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
            pw.Text('Tabel Pengembalian',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
            pw.SizedBox(
              height: 5,
            ),
            pw.Text(
                'Tanggal Cetak: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                )),
            pw.SizedBox(
              height: 5,
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(20),
                1: const pw.FixedColumnWidth(200),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(100),
                4: const pw.FixedColumnWidth(120),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 5),
                        child: pw.Text('No',
                            textAlign: pw.TextAlign.center,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Judul Buku',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 5),
                        child: pw.Text('Peminjam',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Tanggal Pinjam',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Text('Tanggal Pengembalian',
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
                          child:
                              pw.Text('${data[index]['judul buku dipinjam']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text('${data[index]['nama peminjam']}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text(
                              '${_formatTimestamp(data[index]['tanggal peminjaman'])}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text(
                              '${_formatTimestamp(data[index]['tanggal pengembalian'])}')),
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
      final fileName = 'Cetak-Pengembalian-${DateTime.now()}.pdf';
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
