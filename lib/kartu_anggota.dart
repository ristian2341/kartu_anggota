import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';

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
    List<List<String>> excelData = [];
    
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Kartu Anggota'),
        backgroundColor: Colors.green.shade500,
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
                child: _formContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _formContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: backgroundController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Background',
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
                decoration: const InputDecoration(
                  labelText: 'Format Nomor',
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _simpanData,
              child: const Text('Simpan'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _uploadExcel,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Excel'),
            ),
        ),
    const SizedBox(height: 20),
    // ===== TABLE =====
    Expanded(
      child: excelData.isEmpty
          ? const Center(
          child: Text(
          'Belum ada data Excel',
          style: TextStyle(color: Colors.white),
        ),
      ): SingleChildScrollView(
            scrollDirection: Axis.horizontal,
          child: DataTable(
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('Alamat')),
          ],
          rows: excelData.map((e) {
            return DataRow(cells: [
            DataCell(Text(e['no'])),
            DataCell(Text(e['nama'])),
            DataCell(Text(e['alamat'])),
            ]);
          }).toList(),
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
    final excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> temp = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table]!;
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        temp.add({
          'no': row[0]?.value?.toString() ?? '',
          'nama': row[1]?.value?.toString() ?? '',
          'alamat': row[2]?.value?.toString() ?? '',
        });
      }
    }

    setState(() {
      excelData = temp;
    });
  }
}
