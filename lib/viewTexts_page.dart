import 'dart:math';
import 'package:auth/db_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ViewTexts extends StatefulWidget {
  final String topico;

  const ViewTexts({Key? key, required this.topico}) : super(key: key);

  @override
  State<ViewTexts> createState() => _ViewTextsState();
}

class _ViewTextsState extends State<ViewTexts> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController _bodyController = TextEditingController();
  FocusNode _bodyFocusNode = FocusNode();
  bool _isFocused = false;
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _bodyFocusNode.addListener(() {
      if (_bodyFocusNode.hasFocus != _isFocused) {
        setState(() {
          _isFocused = _bodyFocusNode.hasFocus;
        });
      }
    });
    _bodyController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _bodyFocusNode.dispose();
    _bodyController.removeListener(_onTextChanged);
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    final userName = user?.displayName;
    var isCurrentUser;
    var topico = widget.topico;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(topico),
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                    ),
                    if (userName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(userName),
                      ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.blueAccent),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              TextSpan textSpan = TextSpan(
                                text: _bodyController.text,
                                style: const TextStyle(
                                  fontSize:
                                      16, // use o mesmo tamanho de fonte do TextFormField
                                ),
                              );

                              TextPainter textPainter = TextPainter(
                                text: textSpan,
                                maxLines: null,
                                textScaleFactor:
                                    MediaQuery.of(context).textScaleFactor,
                                textAlign: TextAlign.left,
                                textDirection: TextDirection.ltr,
                              );

                              textPainter.layout(
                                  maxWidth: constraints.maxWidth -
                                      24); // subtraia a largura das bordas (10 + 10) e o espaçamento interno (4)
                              double textHeight = textPainter.size.height;
                              double minHeight = 60;
                              double maxHeight = 100;

                              return Container(
                                height:
                                    min(max(minHeight, textHeight), maxHeight),
                                child: TextFormField(
                                  controller: _bodyController,
                                  focusNode: _bodyFocusNode,
                                  maxLines: null,
                                  expands: true,
                                  decoration: InputDecoration(
                                    labelText: 'Digite sua publicação aqui',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 10.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            var topico = widget.topico;
                            Fireservices.addPub(
                              _bodyController,
                              userName,
                              userUid,
                              topico,
                            );
                          },
                          shape: const CircleBorder(),
                          fillColor: Colors.blueAccent,
                          constraints: const BoxConstraints.expand(
                              width: 40, height: 40),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            //size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Tópicos')
                    .doc(widget.topico)
                    .collection('Publicação')
                    .orderBy('Timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final publicacoes = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: publicacoes.length,
                    itemBuilder: (context, index) {
                      final pub = publicacoes[index];
                      final autor = pub['Autor'];
                      final fotoUrl = pub['FotoUrl'];
                      final post = pub['Post'];
                      final pubId = pub.id;
                      final isCurrentUserPost = pub['User uid'];
                      isCurrentUser = userUid;

                      return GestureDetector(
                        onTap: () {},
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: fotoUrl != null
                                        ? NetworkImage(fotoUrl)
                                        : null,
                                  ),
                                  const SizedBox(
                                    width: 13.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          autor,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          post,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            TextButton(
                                              child: const Text(
                                                'Ver publicação',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TextDetailsScreen(
                                                            pub.id,
                                                            widget.topico),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(
                                              height: 10,
                                              width: 20,
                                            ),
                                            if (isCurrentUserPost ==
                                                isCurrentUser)
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      bool? shouldDelete =
                                                          await showConfirmationDialog(
                                                              context);
                                                      if (shouldDelete ??
                                                          false) {
                                                        await Fireservices
                                                            .excluirPublicacao(
                                                                widget.topico,
                                                                pubId);
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Excluir',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ]))));
  }

  void _onTextChanged() {
    String value = _bodyController.text;

    setState(() {
      if (value.isEmpty) {
        _isEmpty = true;
      } else {
        _isEmpty = false;
      }
    });
  }
}

Future<bool?> showConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmação"),
        content: Text("Tem certeza que deseja excluir esta publicação?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text("Excluir"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

class TextDetailsScreen extends StatefulWidget {
  final String documentId;
  final String topico;

  const TextDetailsScreen(this.documentId, this.topico);

  @override
  _TextDetailsScreenState createState() => _TextDetailsScreenState();
}

class _TextDetailsScreenState extends State<TextDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da publicação'),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _db
              .collection('Tópicos')
              .doc(widget.topico) // Adicione o topico aqui
              .collection('Publicação')
              .doc(widget.documentId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            DocumentSnapshot document = snapshot.data!;
            final autor = document['Autor'];
            final post = document['Post'];
            final photoUrl = document['FotoUrl'];

            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            autor,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        post,
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      const SizedBox(height: 16.0),
                      _buildCommentForm(widget.documentId, widget.topico),
                      const SizedBox(height: 16.0),
                      _buildCommentList(),
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildCommentForm(documentId, topico) {
    FocusNode _bodyFocusNode = FocusNode();
    bool _isFocused = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Adicionar Comentário',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  TextSpan textSpan = TextSpan(
                    text: _commentController.text,
                    style: const TextStyle(
                      fontSize:
                          16, // use o mesmo tamanho de fonte do TextFormField
                    ),
                  );

                  TextPainter textPainter = TextPainter(
                    text: textSpan,
                    maxLines: null,
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                  );

                  textPainter.layout(
                      maxWidth: constraints.maxWidth -
                          24); // subtraia a largura das bordas (10 + 10) e o espaçamento interno (4)
                  double textHeight = textPainter.size.height;
                  double minHeight = 60;
                  double maxHeight = 100;

                  return Container(
                    height: min(max(minHeight, textHeight), maxHeight),
                    child: TextFormField(
                      controller: _commentController,
                      focusNode: _bodyFocusNode,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        labelText: 'Digite seu comentário',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            RawMaterialButton(
              onPressed: () {
                _addComment(documentId, topico);
              },
              shape: CircleBorder(),
              fillColor: Colors.blueAccent,
              constraints: const BoxConstraints.expand(width: 40, height: 40),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addComment(documentId, topico) async {
    // Adicionar parâmetro topico aqui
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      final user = await FirebaseAuth.instance.currentUser;
      final photoUrl = user?.photoURL;
      final autor = user?.displayName;
      final uid = user?.uid;
      var id = DateTime.now().microsecondsSinceEpoch.toString();
      await _db
          .collection('Tópicos')
          .doc(topico)
          .collection('Publicação')
          .doc(widget.documentId)
          .collection('Comentários')
          .add({
        'Comentário': comment,
        'Timestamp': Timestamp.now(),
        'Autor': autor,
        'FotoUrl': photoUrl,
        'Id': id,
        'User uid': uid,
      });

      _commentController.clear();
    }
  }

  Widget _buildCommentList() {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('Tópicos')
          .doc(widget.topico)
          .collection('Publicação')
          .doc(widget.documentId)
          .collection('Comentários')
          .orderBy('Timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final comentarios = snapshot.data!.docs;

        if (comentarios.isEmpty) {
          return const Text('Nenhum comentário ainda');
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: comentarios.length,
          itemBuilder: (context, index) {
            final comentario = comentarios[index];
            final comentarioId = comentario.id;
            final isCurrentUserPost = comentario['User uid'];
            final isCurrentUser = userUid;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comentario['FotoUrl'] != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(comentario['FotoUrl']),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${comentario['Autor']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            comentario['Comentário'],
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentUserPost == isCurrentUser)
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              bool? shouldDelete =
                                  await showConfirmationDialog(context);
                              if (shouldDelete ?? false) {
                                await Fireservices.excluirComentario(
                                    widget.topico,
                                    widget.documentId,
                                    comentarioId);
                              }
                            },
                            child: const Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
        );
      },
    ));
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmação"),
          content:
              const Text("Tem certeza que deseja excluir este comentário?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Excluir"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
