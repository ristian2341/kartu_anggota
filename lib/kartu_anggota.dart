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
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.green.shade900, // warna border
            width: 2, // tebal border
          ),
        ),
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
                      Colors.blue.shade300,
                      Colors.blueGrey.shade500,
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
                  backgroundColor: Colors.red.shade600,
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
        Expanded(child:
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
              Expanded(
                child: _tableBody(),
              ),
            ],
          ),
        ),
        )
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
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final ext = file.path.split('.').last.toLowerCase();

    List<Map<String, String>> temp = [];

    if (ext == 'csv') {
      final content = await file.readAsString();
      final lines = content.split(RegExp(r'\r?\n'));
      final delimiter = lines.first.contains(';') ? ';' : ',';
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final cols = lines[i].split(delimiter);

        temp.add({
          'no': cols.length > 0 ? cols[0].trim() : '',
          'nama': cols.length > 1 ? cols[1].trim() : '',
          'no_anggota': cols.length > 2 ? cols[2].trim() : '',
        });
      }
    } else {
      final bytes = await file.readAsBytes();

      final excel = exl.Excel.decodeBytes(bytes);

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];

          temp.add({
            'no': _cell(row, 0),
            'nama': _cell(row, 1),
            'no_anggota': _cell(row, 2),
          });
        }
      }
    }

    setState(() {
      excelData = temp;
    });
  }

  String _cell(List<exl.Data?> row, int index) {
    if (index >= row.length || row[index] == null) return '';
    return row[index]!.value?.toString().trim() ?? '';
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
          _HeaderCell(text: 'Nama', flex: 4),
          _HeaderCell(text: 'Nomor Anggota', flex: 3),
          _HeaderCell(text: 'Generate PDF', flex: 1, isLast: true),
        ],
      ),
    );
  }

  Widget _tableBody() {
    return ListView.builder(
      itemCount: excelData.length,
      itemBuilder: (context, index) {
        final e = excelData[index];
        return Container(
          decoration: BoxDecoration(
            color: index.isEven
                ? Colors.green.shade50
                : Colors.white,
            border: const Border(
              bottom: BorderSide(color: Colors.white54),
            ),
          ),
          child: Row(
            children: [
              _BodyCell(text: e['no'] ?? '', flex: 1),
              _BodyCell(text: e['nama'] ?? '', flex: 4),
              _BodyCell(
                text: '${nomorController.text}-${e['no_anggota'] ?? ''}',
                flex: 3,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide.none,
                      bottom: const BorderSide(color: Colors.black26),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _generateSinglePdf(e),
                  ),
                )
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generatePdf() async {

    // ===== VALIDASI (PUNYA KAMU, TETAP) =====
    if (filegenerateController.text.isEmpty) {
      // dialog gagal
      return;
    }

    if (excelData.isEmpty) {
      // dialog gagal
      return;
    }

    // 🔵 TAMPILKAN SPINNER
    showLoading(context);

    try {
      // === KARTU SIZE (CR80) ===
      final cardSize = PdfPageFormat(
        85.6 * PdfPageFormat.mm,
        54 * PdfPageFormat.mm,
      );

      final bgImage =
      backgroundFromFilePath(backgroundController.text);

      for (final e in excelData) {
        final String nama = e['nama'] ?? '';
        final String idAnggota = e['no_anggota'] ?? '';

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
                  pw.Positioned(
                    top: 47,
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
                  pw.Positioned(
                    top: 67,
                    left: 0,
                    right: 0,
                    child: pw.Center(
                      child: pw.Text(
                        nomorController.text+'-'+idAnggota,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // === BARCODE ===
                  pw.Positioned(
                    top: 85,
                    left: 60,
                    right: 60, // 🔑 batasi lebar barcode
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.code39(),
                        data: idAnggota,
                        drawText: false,
                        height: 28, // 🔑 kontrol tinggi
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        final String dirPath = filegenerateController.text;
        final file = File('$dirPath/$idAnggota.pdf');
        await file.writeAsBytes(await pdf.save());
      }

      // 🟢 TUTUP SPINNER
      hideLoading(context);

      // OPTIONAL: dialog sukses
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sukses'),
          content: const Text('PDF berhasil digenerate'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      // 🔴 TUTUP SPINNER JIKA ERROR
      hideLoading(context);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
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
    String idAnggota = e['no_anggota'] ?? '';

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
                top: 47,   // 🔧 sesuaikan angka ini
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
                top: 67, // 🔧 geser naik/turun
                left: 0,
                right: 0,
                child: pw.Center(
                  child: pw.Text(
                    nomorController.text+'-'+idAnggota,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // === BARCODE ===
              pw.Positioned(
                top: 85,
                left: 60,
                right: 60, // 🔑 batasi lebar barcode
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code39(),
                    data: idAnggota,
                    drawText: false,
                    height: 28, // 🔑 kontrol tinggi
                  ),
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
                : const BorderSide(color: Colors.black26),
            bottom: const BorderSide(color: Colors.black26),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
