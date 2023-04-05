import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'desafios.dart';

class DesafioListScreen extends StatefulWidget {
  @override
  _DesafioListScreenState createState() => _DesafioListScreenState();
}

class _DesafioListScreenState extends State<DesafioListScreen> {
  List<dynamic> _desafios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDesafios();
  }

  Future<void> fetchDesafios() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('Desafios').get();

    setState(() {
      _desafios = querySnapshot.docs.map((doc) => doc.data()).toList();
      _isLoading = false;
    });
  }

  Widget buildDesafioCard(dynamic desafio) {
    return Card(
      child: ListTile(
        title: Text(desafio['Nome do desafio']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Desafios(desafioNome: desafio['Nome do desafio']),
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
        title: Text('Lista de Desafios'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _desafios.length,
        itemBuilder: (context, index) {
          return buildDesafioCard(_desafios[index]);
        },
      ),
    );
  }
}
