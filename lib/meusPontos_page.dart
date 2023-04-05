import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeusPontos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;
    String? autor;
    String? uid;
    autor = user?.displayName;
    uid = user?.uid;

    final CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('Pontuação dos desafios')
        .doc('Pontuação dos usuários')
        .collection('$uid');

    return Scaffold(
      appBar: AppBar(
        title: Text("Pontos"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Erro ao carregar dados");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Contagem total de documentos
          int totalDocs = snapshot.data!.docs.length;

          return Center(
            child: Text(
              "Você tem $totalDocs ponto(s).",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
    );
  }
}
