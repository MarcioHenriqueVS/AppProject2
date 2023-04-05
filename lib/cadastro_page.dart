import 'dart:typed_data';
import 'package:auth/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'checagem_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Faça seu cadastro'),
      ),
      body: ListView(
        padding: EdgeInsets.all(40),
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(label: Text('Nome completo')),
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(label: Text('Email')),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(label: Text('Senha')),
          ),
          ElevatedButton(
            onPressed: () {
              cadastrar();
            },
            child: Text('Cadastrar'),
          ),
        ],
      ),
    );
  }


  cadastrar() async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      if (userCredential != null) {
        await userCredential.user!.updateDisplayName(_nomeController.text);
        await userCredential.user!.updateEmail(_emailController.text);

        // Carregue a imagem como um Uint8List
        Uint8List imageData = (await rootBundle.load(
            'assets/images/fotoDePerfilNull.jpg')).buffer.asUint8List();

        // Crie uma referência no Firebase Storage com o uid do usuário
        final uid = userCredential.user!.uid;
        final storageReference = FirebaseStorage.instance.ref().child(
            'profileImages/$uid');

        // Envie a imagem para o Firebase Storage
        final uploadTask = storageReference.putData(
            imageData, SettableMetadata(contentType: 'image/jpeg'));

        // Obtenha a URL de download após o upload ser concluído
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Atualize a foto do perfil do usuário
        await userCredential.user!.updatePhotoURL(downloadUrl);

        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
                (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A senha deve conter no mínimo 6 caracteres'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este email já está cadastrado'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}