import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart' as exl;
import 'dart:developer'; // Helpful for logging
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class KartuAnggotaPage extends StatefulWidget {
  const KartuAnggotaPage({super.key});

  @override
  State<KartuAnggotaPage> createState() => _KartuAnggotaPageState();
}

class _KartuAnggotaPageState extends State<KartuAnggotaPage> with SingleTickerProviderStateMixin {

    final TextEditingController backgroundController = TextEditingController();
    final TextEditingController nomorController = TextEditingController();
    final TextEditingController filegenerateController = TextEditingController();

    late AnimationController _controller;
    List<Map<String, String>> excelData = [];

    @override
    void initState() {
      super.initState();

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(reverse: true);

      loadData();
    }

  Future<void> loadData() async {
    final data = await DatabaseHelper.instance.getSetting();
    if (data.isNotEmpty) {
      backgroundController.text = data.first['background'] ?? '';
      nomorController.text = data.first['format_nomor'] ?? '';
      filegenerateController.text = data.first['file_generate'] ?? '';
    }
  }

  Future<void> _simpanData() async {
    await DatabaseHelper.instance.saveSetting(
        backgroundController.text,
        nomorController.text,
        filegenerateController.text
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Success',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Data berhasil disimpan',
            style: TextStyle(color: Colors.black),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    backgroundController.dispose();
    nomorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Kartu Anggota'),
        backgroundColor: Colors.green,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SizedBox.expand( // 🔥 FULL SCREEN
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      Colors.green.shade300,
                      Colors.green.shade500,
                      _controller.value,
                    )!,
                    Color.lerp(
                      Colors.blueAccent.shade100,
                      Colors.blueAccent.shade400,
                      _controller.value,
                    )!,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _formContent(screenHeight),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _formContent(screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== FORM ATAS (TETAP) =====
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            border: Border.all(color: Colors.black38, width: 1.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: backgroundController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Background',
                    filled: true,
                    fillColor: Colors.white54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _pickBackground,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: nomorController,
                  decoration: InputDecoration(
                    labelText: 'Format Nomor',
                    filled: true,
                    fillColor: Colors.white54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: filegenerateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'File Generate PDF',
                    filled: true,
                    fillColor: Colors.white54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _pickDirectory,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // ===== BUTTON UPLOAD =====
                  ElevatedButton.icon(
                    onPressed: _uploadExcel,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Excel'),
                  ),

                  const SizedBox(width: 12), // jarak antar tombol

                  // ===== BUTTON GENERATE PDF =====
                  ElevatedButton.icon(
                    onPressed: _generatePdf, // fungsi untuk generate PDF
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate KTA PDF'),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _tableHeader(),
              _tableBody(screenHeight),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickBackground() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        backgroundController.text = result.files.single.path!;
      });
    }
  }

  Future<void> _uploadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = exl.Excel.decodeBytes(bytes);

    List<Map<String, String>> temp = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table]!;
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        temp.add({
          'no': row[0]?.value?.toString() ?? '',
          'nama': row[1]?.value?.toString() ?? '',
          'no_anggota': row[2]?.value?.toString() ?? '',
        });
      }
    }

    setState(() {
      excelData = temp;
    });
  }

  Widget _tableHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        border: const Border(
          bottom: BorderSide(color: Colors.white54),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      child: Row(
        children: const [
          _HeaderCell(text: 'No', flex: 1),
          _HeaderCell(text: 'Nama', flex: 3),
          _HeaderCell(text: 'Nomor Anggota', flex: 3, isLast: true),
          _HeaderCell(text: 'Generate PDF', flex: 1, isLast: true),
        ],
      ),
    );
  }

  Widget _tableBody(double screenHeight) {

    return SizedBox(
      height: screenHeight * 0.69,
      child: ListView.builder(
        itemCount: excelData.length,
        itemBuilder: (context, index) {
          final e = excelData[index];
          return Container(
            decoration: BoxDecoration(
              color: index.isEven
                  ? Colors.green.shade50
                  : Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.white54),
              ),
            ),
            child: Row(
              children: [
                _BodyCell(text: e['no'] ?? '', flex: 1),
                _BodyCell(text: e['nama'] ?? '', flex: 3),
                _BodyCell(text: '${nomorController.text}-${e['no_anggota'] ?? ''}', flex: 3, isLast: true),
                // === BUTTON EXPORT PDF ===
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    tooltip: 'Export PDF',
                    onPressed: () {
                      _generateSinglePdf(e);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _generatePdf() async {
      // cek lokasi simpan file jika kosong ///
    if(filegenerateController.text.isEmpty){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: const [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Gagal',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Lokasi Generate tidak boleh kosong',
              style: TextStyle(color: Colors.black),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    // === VALIDASI DATA ===
    if (excelData.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: const [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Gagal',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Data kosong, Generate PDF Kartu Anggota gagal',
              style: TextStyle(color: Colors.black),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      return;
    }


    // === KARTU SIZE (CR80) ===
    final cardSize = PdfPageFormat(
      85.6 * PdfPageFormat.mm,
      54 * PdfPageFormat.mm,
    );

    // === BACKGROUND DARI TEXT CONTROLLER ===
    final bgImage = backgroundFromFilePath(backgroundController.text);

    for(final e in excelData){
      final String nama = e['nama'] ?? '';
      final String idAnggota ='${nomorController.text}-${e['no_anggota'] ?? ''}';

      // generate to pdr berdasarkan id anggota //
      // 🔴 WAJIB: Document baru setiap anggota
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: cardSize,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(bgImage, fit: pw.BoxFit.cover),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 8),
                      pw.Text(
                        nama,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Divider(),
                      pw.Text(
                        idAnggota,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: idAnggota, // 🔥 pakai idAnggota
                        width: 120,
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // SIMPAN FILE PER ANGGOTA
      final String dirPath = filegenerateController.text;
      final file = File('$dirPath/$idAnggota.pdf');

      await file.writeAsBytes(await pdf.save());
    }
  }

  // Rename this function to _pickDirectory as it's more accurate now
  Future<void> _pickDirectory() async {
    try {
      // Use the getDirectoryPath method from the file_picker package.
      // This function specifically prompts the user to select a folder/directory.
      // The result will be the absolute path as a String, or null if cancelled.
      final String? selectedDirectoryPath = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectoryPath != null) {
        // If the user successfully selected a directory, update the text field controller
        setState(() {
          filegenerateController.text = selectedDirectoryPath;
          log('Selected directory path: $selectedDirectoryPath'); // Optional logging
        });
      } else {
        // Handle the case where the user cancels the selection process
        log('Directory selection cancelled.');
        // You might want to clear the field if a previous path was set
        // filegenerateController.clear();
      }
    } catch (e) {
      // Catch and handle any potential errors during the picking process
      log('Error picking directory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick directory: $e')),
      );
    }
  }

  pw.MemoryImage backgroundFromFilePath(String path) {
    final file = File(path);

    if (!file.existsSync()) {
      throw Exception('Background file tidak ditemukan');
    }

    final bytes = file.readAsBytesSync();
    return pw.MemoryImage(bytes);
  }

  Future<void> _generateSinglePdf(Map<String, dynamic> e) async {
    // VALIDASI DATA
    if ((e['nama'] ?? '').toString().trim().isEmpty ||
        (e['no_anggota'] ?? '').toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data baris tidak lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String nama = e['nama'] ?? '';
    String idAnggota = '${nomorController.text}-${e['no_anggota'] ?? ''}';

    // === KARTU SIZE (CR80) ===
    final cardSize = PdfPageFormat(
      85.6 * PdfPageFormat.mm,
      54 * PdfPageFormat.mm,
    );

    // === BACKGROUND DARI TEXT CONTROLLER ===
    final bgImage = backgroundFromFilePath(backgroundController.text);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: cardSize,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Stack(
            children: [
              // BACKGROUND
              pw.Positioned.fill(
                child: pw.Image(bgImage, fit: pw.BoxFit.cover),
              ),

              // === NAMA ===
              pw.Positioned(
                top: 49,   // 🔧 sesuaikan angka ini
                left: 0,
                right: 0,
                child: pw.Center(
                  child: pw.Text(
                    nama.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // === ID ANGGOTA ===
              pw.Positioned(
                top: 65, // 🔧 geser naik/turun
                left: 0,
                right: 0,
                child: pw.Center(
                  child: pw.Text(
                    idAnggota,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // === BARCODE ===
              pw.Positioned(
                top: 90, // 🔧 naik/turun
                left: 20,
                right: 20,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: idAnggota,
                  height: 24,
                ),
              ),
            ],
          );
        },
      ),
    );
    // SIMPAN FILE PER ANGGOTA
    final String dirPath = filegenerateController.text;
    final file = File('$dirPath/$idAnggota.pdf');

    await file.writeAsBytes(await pdf.save());
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isLast;

  const _HeaderCell({
    required this.text,
    required this.flex,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            right: isLast
                ? BorderSide.none
                : const BorderSide(color: Colors.white54),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isLast;

  const _BodyCell({
    required this.text,
    required this.flex,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            right: isLast
                ? BorderSide.none
                : const BorderSide(color: Colors.white54),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
