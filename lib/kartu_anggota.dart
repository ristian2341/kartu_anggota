import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart' as exl;

class KartuAnggotaPage extends StatefulWidget {
  const KartuAnggotaPage({super.key});

  @override
  State<KartuAnggotaPage> createState() => _KartuAnggotaPageState();
}

class _KartuAnggotaPageState extends State<KartuAnggotaPage>
    with SingleTickerProviderStateMixin {

    final TextEditingController backgroundController = TextEditingController();
    final TextEditingController nomorController = TextEditingController();
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
    }
  }

  Future<void> _simpanData() async {
    await DatabaseHelper.instance.saveSetting(
      backgroundController.text,
      nomorController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan')),
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
                const SizedBox(width: 20),
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
                      onPressed: _genratePdf, // fungsi untuk generate PDF
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate PDF'),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _uploadExcel() async {

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
