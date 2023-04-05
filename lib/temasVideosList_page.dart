import 'package:auth/listVideos.dart';
import 'package:auth/viewTexts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TemasListScreen extends StatefulWidget {
  @override
  _TemasListScreenState createState() => _TemasListScreenState();
}

class _TemasListScreenState extends State<TemasListScreen> {
  List<dynamic> _temas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDesafios();
  }

  Future<void> fetchDesafios() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('Temas dos vídeos').get();

    setState(() {
      _temas = querySnapshot.docs.map((doc) => doc.data()).toList();
      _isLoading = false;
    });
  }

  Widget buildDesafioCard(dynamic tema) {
    return Card(
      child: ListTile(
        title: Text(tema['Tema']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(tema: tema['Tema']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temas'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _temas.length,
        itemBuilder: (context, index) {
          return buildDesafioCard(_temas[index]);
        },
      ),
    );
  }
}
