import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';

// Repository Provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// StateNotifier (notes list)
class NoteListNotifier extends StateNotifier<List<Note>> {
  final Ref ref; // FIX: Reader -> Ref

  NoteListNotifier(this.ref) : super([]) {
    loadNotes();
  }

  NoteRepository get repo => ref.read(noteRepositoryProvider);

  Future<void> loadNotes() async {
    final notes = await repo.getAllNotes();
    state = notes;
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(title: title, content: content);
    final created = await repo.createNote(note);
    state = [created, ...state];
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await repo.updateNote(updated);
    state = [
      for (final n in state)
        if (n.id == updated.id) updated else n
    ];
  }

  Future<void> deleteNote(int id) async {
    await repo.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await loadNotes();
      return;
    }
    final results = await repo.searchNotes(query.trim());
    state = results;
  }
}

// Provider untuk NoteListNotifier
final noteListProvider =
    StateNotifierProvider<NoteListNotifier, List<Note>>((ref) {
  return NoteListNotifier(ref);
});
