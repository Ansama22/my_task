import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditNoteScreen extends StatefulWidget {
  EditNoteScreen({
    Key? key,
    required this.note,
    required this.id,
  }) : super(key: key);

  final String note;
  final String id;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    noteController.text = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Note",
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                onPressed: () => updateNote(),
                child: const Text("Update"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateNote() {
    String note = noteController.text;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> data = {
      "note": note,
    };

    firestore.collection("notes").doc(widget.id).update(data);

    Navigator.pop(context, note);
  }
}