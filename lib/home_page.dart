import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'image_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String imageLink =
      'https://images.unsplash.com/photo-1707159432991-ac67eace0014?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw1fHx8ZW58MHx8fHx8';
  File? _edited;
  File? _edited2;
  File? _original;

  @override
  void initState() {
    super.initState();
    _networkToFile();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: [
            TextButton(
                onPressed: () => _toEditor(_edited!.path),
                child: const Text('Edit')),
            TextButton(
              onPressed: () {
                setState(() {
                  _edited = _original;
                });
              },
              child: const Text("Reset"),
            ),
            if (_original == null) const CircularProgressIndicator(),
            if (_edited != null) Image.file(_edited!),
            if (_edited2 != null) Image.file(_edited2!),
          ],
        ),
      )),
    );
  }

  void _networkToFile() async {
    final response = await http.get(Uri.parse(imageLink));
    final bytes = response.bodyBytes;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/image.jpg');
    await file.writeAsBytes(bytes);
    setState(() {
      _original = file;
    });
    if (mounted) {
      _toEditor(file.path);
    }
  }

  void _toEditor(String path) async {
    dynamic edited = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ImageEditorPage(imagePath: path),
      ),
    );
    if (edited != null && edited is Map<String, dynamic>) {
      setState(() {
        _edited = edited['image'];
        _edited2 = edited['image2'];
      });
    }
  }
}
