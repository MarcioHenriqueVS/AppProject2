import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Desafios extends StatefulWidget {
  final String desafioNome;

  Desafios({required this.desafioNome});

  @override
  State<Desafios> createState() => _DesafiosState();
}

class _DesafiosState extends State<Desafios> {
  final _firebaseAuth = FirebaseAuth.instance;
  String? autor;
  String? _uid;
  late List<DateTime> _weekDays;
  late Map<String, dynamic> _documentData = {};
  late DateTime _today;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initWeekDays();
    _fetchDocumentData();
    _today = DateTime.now();
  }

  void _initWeekDays() {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local).toLocal();
    _weekDays = List.generate(
        7,
        (i) => tz.TZDateTime(
            tz.local, now.year, now.month, now.day - now.weekday + i));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().subtract(Duration(days: 1));
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: Text(widget.desafioNome),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      Text(''),
                    ],
                  ),
                ),
                floatingActionButton: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    7,
                    (index) {
                      final date = _weekDays[index].toLocal();
                      final idString = DateFormat('yyyy-MM-dd').format(date);
                      final hasDocument = _documentData.containsKey(idString);
                      final isBefore =
                          date.add(Duration(days: 1)).isBefore(today) &&
                              !hasDocument;
                      final isEnabled =
                          date.add(Duration(days: 1)).isBefore(today) &&
                              date.isAfter(today);
                      final backgroundColor =
                          _documentData.containsKey(idString)
                              ? Colors.green
                              : isBefore
                                  ? Colors.red
                                  : Colors.grey;
                      return FloatingActionButton(
                        heroTag: idString,
                        onPressed: !isEnabled && !hasDocument ? () {} : null,
                        tooltip: idString,
                        backgroundColor: backgroundColor,
                        child: Text(
                          DateFormat.E('pt_BR').format(date),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 100,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () async {
                    var nomeDoDesafio = widget.desafioNome;
                    await Fireservices.addData(nomeDoDesafio, autor);
                    await _fetchDocumentData();
                    await Fireservices.addPonto();
                    Fireservices.addFeed();
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          );
  }

  void _getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    setState(() {
      _uid = user?.uid;
      autor = user?.displayName;
    });
  }

  Future<void> _fetchDocumentData() async {
    var nomeDoDesafio = widget.desafioNome;
    final snapshot = await FirebaseFirestore.instance
        .collection('Desafios')
        .doc(nomeDoDesafio)
        .collection('$_uid')
        .get();
    final data = Map<String, dynamic>.fromEntries(snapshot.docs
        .map((doc) => MapEntry(doc.id, doc.data()))
        .where((entry) => entry.value is Map));
    setState(() {
      _documentData = data;
    });
    setState(() {
      _isLoading = false;
    });
  }
}
