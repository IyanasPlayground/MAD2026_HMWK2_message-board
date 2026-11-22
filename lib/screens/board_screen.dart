import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../board_service.dart';

class BoardScreen extends StatefulWidget {
  final User user;
  final String firstName;
  const BoardScreen({super.key, required this.user, required this.firstName});
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _board = BoardService();
  final _text = TextEditingController();
  bool _sending = false;

  Future<void> _post() async {
    final text = _text.text.trim();
    if (_sending || text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _board.postMessage(
        authorUid: widget.user.uid,
        authorName: widget.firstName,
        text: text,
      );
      _text.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _edit(String id, String oldText) async {
    final controller = TextEditingController(text: oldText);
    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (newText == null || newText.isEmpty || newText == oldText) return;
    try {
      await _board.editMessage(messageId: id, newText: newText);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'You can only edit your own messages.'
              : 'Could not edit. Try again.')));
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this message?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _board.deleteMessage(messageId: id);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'You can only delete your own messages.'
              : 'Could not delete. Try again.')));
    }
  }


  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Message Board'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => AuthService().signOut(),
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _board.messageBoard(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Could not load messages.'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No messages yet.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final id = docs[i].id;
                    final m = docs[i].data();
                    final mine = m['authorUid'] == widget.user.uid;
                    final edited = m['editedAt'] != null;
                    return ListTile(
                      title: Text(m['text'] ?? ''),
                      subtitle: Text(m['authorName'] ?? 'Unknown'),
                      trailing: mine
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _edit(id, m['text'] ?? ''),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(id),
                          ),
                       ])
                      : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  decoration: const InputDecoration(hintText: 'Write a message'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sending ? null : _post,
              ),
            ]),
          ),
        ]),
      );
}