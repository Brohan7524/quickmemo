import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Get collection of notes
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');

  // CREATE: Create a note
  Future<void> addNote(String note) {
    return notes.add({'note': note, 'timestamp': Timestamp.now()});
  }

  // READ: Getting notes from DB
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
    notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  // UPDATE: Updating a note given a doc id
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: Deleting a note given a doc id
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
