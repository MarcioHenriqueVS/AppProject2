import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'db_firestore.dart';

class AddText extends StatefulWidget {
  final String topico;

  const AddText(this.topico, {Key? key}) : super(key: key);
  @override
  State<AddText> createState() => _AddTextState();
}

class _AddTextState extends State<AddText> {
  TextEditingController Title = TextEditingController();
  TextEditingController Body = TextEditingController();
  TextEditingController Author = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;
  String? _uid;
  String? Autor;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publicação de conteúdo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              TextFormField(
                  controller: Body,
                  decoration: InputDecoration(
                      labelText: 'Digite sua publicação aqui',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10,),
              ElevatedButton(onPressed: () {
                var topico = widget.topico;
                Fireservices.addPub(Body, Autor, _uid, topico);
              },
                  child: const Text('Publicar'))
            ],
          ),
        ),
      ),
    );
  }
  void _getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    setState(() {
      _uid = user?.uid;
      Autor = user?.displayName;
    });
  }
}
