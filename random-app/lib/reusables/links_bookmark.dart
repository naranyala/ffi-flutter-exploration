import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BookmarkLinksApp(),
  ));
}

class BookmarkLinksApp extends StatefulWidget {
  @override
  _BookmarkLinksAppState createState() => _BookmarkLinksAppState();
}

class _BookmarkLinksAppState extends State<BookmarkLinksApp> {
  final List<Map<String, String>> _bookmarks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _addBookmark() {
    String title = _titleController.text.trim();
    String url = _urlController.text.trim();

    if (title.isNotEmpty && url.isNotEmpty) {
      // Auto-prepend https:// if missing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      setState(() {
        _bookmarks.add({"title": title, "url": url});
      });
      _titleController.clear();
      _urlController.clear();
      Navigator.pop(context);
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar("Could not launch $url");
      }
    } catch (e) {
      _showSnackBar("Invalid URL");
    }
  }

  void _copyUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    _showSnackBar("Link copied to clipboard");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddBookmarkDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Bookmark"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: "URL"),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addBookmark,
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _removeBookmark(int index) {
    setState(() {
      _bookmarks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bookmark Links")),
      body: _bookmarks.isEmpty
          ? Center(child: Text("No bookmarks yet. Add one!"))
          : ListView.builder(
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _bookmarks[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(bookmark["title"] ?? ""),
                    subtitle: Text(bookmark["url"] ?? ""),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'open') {
                          _openUrl(bookmark["url"] ?? "");
                        } else if (value == 'copy') {
                          _copyUrl(bookmark["url"] ?? "");
                        } else if (value == 'delete') {
                          _removeBookmark(index);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'open', child: Text("Open in Browser")),
                        PopupMenuItem(value: 'copy', child: Text("Copy Link")),
                        PopupMenuItem(value: 'delete', child: Text("Delete")),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookmarkDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

