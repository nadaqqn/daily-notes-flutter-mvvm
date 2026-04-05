// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'note_detail_page.dart';
import 'note_edit_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor({Note? note}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NoteEditPage(note: note),
    ));
    // reload (note provider already updates on save, but ensure list)
    await ref.read(noteListProvider.notifier).loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyNotes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref.read(noteListProvider.notifier).search(v),
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(noteListProvider.notifier).loadNotes();
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text('Belum ada catatan. Tekan + untuk menambah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      note.title.isEmpty ? '(Tanpa Judul)' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NoteDetailPage(noteId: note.id!),
                        ),
                      );
                      // reload when coming back
                      await ref.read(noteListProvider.notifier).loadNotes();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openEditor(note: note),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
