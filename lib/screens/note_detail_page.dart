// lib/screens/note_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'note_edit_page.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final int noteId;
  const NoteDetailPage({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  Note? _note;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    setState(() => _loading = true);
    final repo = ref.read(noteRepositoryProvider);
    final note = await repo.getNoteById(widget.noteId);
    setState(() {
      _note = note;
      _loading = false;
    });
  }

  Future<void> _deleteNote() async {
    if (_note == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: const Text('Catatan akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(noteRepositoryProvider).deleteNote(_note!.id!);
      // update provider list
      await ref.read(noteListProvider.notifier).loadNotes();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _editNote() async {
    if (_note == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteEditPage(note: _note)),
    );
    await _loadNote();
    await ref.read(noteListProvider.notifier).loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteNote),
          IconButton(icon: const Icon(Icons.edit), onPressed: _editNote),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Catatan tidak ditemukan'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _note!.title.isEmpty ? '(Tanpa Judul)' : _note!.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _note!.content,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
