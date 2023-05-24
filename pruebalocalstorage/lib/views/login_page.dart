import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //bool loading = false;
  //double progress = 0.0;
  //final Dio dio = Dio();

  Future<bool> saveFile(File foto, String fileName) async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          List<String> folders = directory!.path.split("/");
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += '/$folder';
            } else {
              break;
            }
          }
          newPath = '$newPath/DCIM/GallosVideos';
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      directory.create(recursive: true);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (await directory.exists()) {
        File saveFile = File("${directory.path}/$fileName");
        await saveFile.writeAsBytes(foto.readAsBytesSync());

        if (Platform.isAndroid) {
          await ImageGallerySaver.saveFile(saveFile.path);
        } else {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<File> getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    // Obtener la ruta de la imagen capturada
    final String picturePath = image!.path;

    // Crear un objeto File a partir de la ruta
    final File picture = File(picturePath);

    return picture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              File foto = await getImage();
              String fileName = "gallito.jpg";
              saveFile(foto, fileName);
            },
            child: const Text('Download Video'),
          )
        ],
      ),
    ));
  }
}
