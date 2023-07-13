import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_new_note_screen.dart';
import 'edit_note_screen.dart';
import 'notes_login_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Map<String, dynamic>> notes = [];


  final firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    getNotesFromFirebaseFirestore();
    // getRealtimeNotesFromFirebaseFirestore();
  }

  void getNotesFromFirebaseFirestore() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    firestore.collection("notes").where("userId", isEqualTo: userId)
        .get().then((value) {
      notes.clear();
      for (var document in value.docs) {
        final note = document.data();
        notes.add(note);
      }
      setState(() {});
    });
  }

  void getRealtimeNotesFromFirebaseFirestore() {
    firestore.collection("notes").snapshots().listen((event) {
      notes.clear();
      for (var document in event.docs) {
        final note = document.data();
        notes.add(note);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesLoginScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddNewNoteScreen();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return noteItem(index);
        },
      ),
    );
  }

  Widget noteItem(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              notes[index]['note'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              navigateToEditNoteScreen(index);
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () => deleteNote(index),
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void navigateToAddNewNoteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const AddNewNoteScreen(),
      ),
    ).then((value) {
      getNotesFromFirebaseFirestore();
    });
  }

  void navigateToEditNoteScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          note: notes[index]['note'],
          id: notes[index]['id'],
        ),
      ),
    ).then((value) {
      getNotesFromFirebaseFirestore();
    });
  }

  deleteNote(int index) async {
    await firestore.collection("notes").doc(notes[index]['id']).delete();
    notes.removeAt(index);
    setState(() {});


  }
}