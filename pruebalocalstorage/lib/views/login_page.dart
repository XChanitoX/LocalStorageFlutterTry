import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  File _imageFile = File('');
  bool _fotoTomada = false;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      if (Platform.isAndroid) {
        await saveImageToGallery(_imageFile);
      }
    }
  }

  Future<void> saveImageToGallery(File imageFile) async {
    final directory = await getExternalStorageDirectory();
    var newPath = "";
    List<String> paths = directory!.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }

    final imagePath =
        path.join(newPath, 'DCIM', 'CriaderosCompetitivos', 'Imagenes');
    await Directory(imagePath).create(recursive: true);
    final fileName = path.basename(imageFile.path);
    await imageFile.copy('$imagePath/$fileName').then((value) => setState(() {
          _fotoTomada = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar foto y guardar localmente'),
      ),
      body: Center(
        child: _fotoTomada
            ? Image.file(_imageFile)
            : const Text('No se ha tomado ninguna foto'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
