import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class EnviarVideo extends StatefulWidget {
  final String tema;

  const EnviarVideo(this.tema, {Key? key}) : super(key: key);

  @override
  State<EnviarVideo> createState() => _EnviarVideoState();
}

class _EnviarVideoState extends State<EnviarVideo> {
  PlatformFile? pickedFile;
  PlatformFile? thumbnailFile;
  String? nomeDoVideo;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future selectThumbnail() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    setState(() {
      thumbnailFile = result.files.first;
    });
  }

  Future<void> uploadFile(String? nomeDoVideo) async {
    if (nomeDoVideo == null || nomeDoVideo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, insira um nome para o vídeo'),
        duration: Duration(seconds: 3),
      ));
      return;
    }

    if (pickedFile == null || thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
        Text('Por favor, selecione um arquivo de vídeo e uma thumbnail'),
        duration: Duration(seconds: 3),
      ));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final nome = user?.displayName ?? 'unknown';
    final videoPath = 'videos/$nome/$nomeDoVideo.mp4';
    final thumbnailPath = 'videos/$nome/thumbnails/$nomeDoVideo.jpg';

    final videoRef = FirebaseStorage.instance.ref().child(videoPath);
    final thumbnailRef = FirebaseStorage.instance.ref().child(thumbnailPath);

    TaskSnapshot videoSnapshot;
    TaskSnapshot thumbnailSnapshot;

    if (kIsWeb) {
      videoSnapshot = await videoRef.putData(pickedFile!.bytes!);
      thumbnailSnapshot = await thumbnailRef.putData(thumbnailFile!.bytes!);
    } else {
      final videoFile = File(pickedFile!.path!);
      final thumbnail = File(thumbnailFile!.path!);
      videoSnapshot = await videoRef.putFile(videoFile);
      thumbnailSnapshot = await thumbnailRef.putFile(thumbnail);
    }

    final videoDownloadUrl = await videoSnapshot.ref.getDownloadURL();
    final thumbnailDownloadUrl = await thumbnailSnapshot.ref.getDownloadURL();

    if (videoDownloadUrl.isEmpty || thumbnailDownloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ocorreu um erro ao enviar o arquivo'),
        duration: Duration(seconds: 3),
      ));
      return;
    }

    var id = DateTime.now().microsecondsSinceEpoch.toString();
    final documentRef = FirebaseFirestore.instance.collection('Temas dos vídeos').doc(widget.tema).collection('Vídeos').doc(id);
    await documentRef.set({
      'url': videoDownloadUrl,
      'thumbnailUrl': thumbnailDownloadUrl,
      'nomeDoVideo': nomeDoVideo,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Arquivo enviado com sucesso'),
      duration: Duration(seconds: 3),
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar vídeos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Text(
                'Arquivo: ${pickedFile!.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            if (thumbnailFile != null)
              Text(
                'Thumbnail: ${thumbnailFile!.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            const SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nome do vídeo'),
              onChanged: (value) => nomeDoVideo = value,
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: selectFile, child: Text('Selecionar arquivo')),
            ElevatedButton(
                onPressed: selectThumbnail,
                child: Text('Selecionar thumbnail')),
            ElevatedButton(
              onPressed: () {
                uploadFile(nomeDoVideo);
              },
              child: Text('Enviar arquivo'),
            ),
          ],
        ),
      ),
    );
  }
}
