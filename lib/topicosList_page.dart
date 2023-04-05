import 'package:auth/viewTexts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopicosListScreen extends StatefulWidget {
  @override
  _TopicosListScreenState createState() => _TopicosListScreenState();
}

class _TopicosListScreenState extends State<TopicosListScreen> {
  List<dynamic> _topicos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDesafios();
  }

  Future<void> fetchDesafios() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('Tópicos').get();

    setState(() {
      _topicos = querySnapshot.docs.map((doc) => doc.data()).toList();
      _isLoading = false;
    });
  }

  Widget buildDesafioCard(dynamic topico) {
    return Card(
      child: ListTile(
        title: Text(topico['Tópico']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewTexts(topico: topico['Tópico']),
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
        title: Text('Tópicos'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _topicos.length,
        itemBuilder: (context, index) {
          return buildDesafioCard(_topicos[index]);
        },
      ),
    );
  }
}
