import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// Model class for one download
class DownloadItem {
  final String url;
  final String savePath;
  double progress;
  String status;
  CancelToken cancelToken;

  DownloadItem({
    required this.url,
    required this.savePath,
    this.progress = 0.0,
    this.status = "Pending",
  }) : cancelToken = CancelToken();
}

/// Downloader widget
class DownloadManager extends StatefulWidget {
  const DownloadManager({super.key});

  @override
  State<DownloadManager> createState() => _DownloadManagerState();
}

class _DownloadManagerState extends State<DownloadManager> {
  final List<DownloadItem> downloads = [];
  final Dio dio = Dio();

  void addDownload(String url, String savePath) {
    setState(() {
      downloads.add(DownloadItem(url: url, savePath: savePath));
    });
  }

  Future<void> startDownload(DownloadItem item) async {
    setState(() => item.status = "Downloading...");
    try {
      await dio.download(
        item.url,
        item.savePath,
        cancelToken: item.cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() => item.progress = received / total);
          }
        },
      );
      setState(() => item.status = "Completed");
    } catch (e) {
      if (CancelToken.isCancel(e)) {
        setState(() => item.status = "Cancelled");
      } else {
        setState(() => item.status = "Error");
      }
    }
  }

  void cancelDownload(DownloadItem item) {
    item.cancelToken.cancel();
    setState(() => item.status = "Cancelled");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloader")),
      body: ListView.builder(
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final item = downloads[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item.url, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: item.progress),
                  Text("${(item.progress * 100).toStringAsFixed(0)}% • ${item.status}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.status == "Pending" || item.status == "Cancelled")
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => startDownload(item),
                    ),
                  if (item.status == "Downloading...")
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () => cancelDownload(item),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // for demo: add a test URL
          addDownload(
            "https://speed.hetzner.de/100MB.bin",
            "/storage/emulated/0/Download/testfile.bin",
          );
        },
      ),
    );
  }
}

