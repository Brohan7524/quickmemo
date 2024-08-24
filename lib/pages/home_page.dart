import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickmemo/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore initializing
  final FirestoreService firestoreService = FirestoreService();

  // Access the text given by the user in the TextField
  final TextEditingController textController = TextEditingController();

  // Open a dialog box to add/edit/delete a note
  void openNoteBox(String? docID, {String? currentText}) {
    // If editing, initialize the controller with the current text
    if (currentText != null) {
      textController.text = currentText;
    } else {
      textController.clear(); // Clear the controller when adding a new note
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF3C2B45),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "Enter your note",
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(
            color: Colors.white, // Set the entered text color to white
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Add a new note
              if (docID == null) {
                firestoreService.addNote(textController.text);
              } else {
                // Update an existing note
                firestoreService.updateNote(docID, textController.text);
              }

              // Clear textController after adding the note
              textController.clear();

              // Close the dialog box after adding a note
              Navigator.pop(context);

              // Refresh UI
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF23162B), // Set the button color same as the floating action button
            ),
            child: Text(
              docID == null ? "Add" : "Update",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4C3957),
      appBar: AppBar(
        title: const Text(
          "QuickMemo",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF23162B),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(null),
        backgroundColor: Color(0xFF23162B),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // If we have data, get all docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // Display as a list
            return ListView.builder(
              padding: const EdgeInsets.all(8.0), // Padding around the entire list
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // Get individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // Get note from each doc
                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // Display as a card with padding
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding between notes
                  child: Card(
                    color: Color(0xFF3C2B45),
                    elevation: 4.0, // Elevation for floating effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0), // Padding inside the note
                      title: Text(
                        noteText,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Update button
                          IconButton(
                            onPressed: () =>
                                openNoteBox(docID, currentText: noteText),
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                          // Delete button
                          IconButton(
                            onPressed: () {
                              firestoreService.deleteNote(docID);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            // If there is no data, return a placeholder
            return const Center(child: Text("No notes..."));
          }
        },
      ),
    );
  }
}
