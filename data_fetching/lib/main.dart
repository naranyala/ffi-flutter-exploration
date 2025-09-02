import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'naranyala_query.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Data Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = QueryClient.instance;

    // Fetch posts as list of maps
    final postsQuery = client.useQuery<List<Map<String, dynamic>>>(
      key: "posts",
      cacheTime: const Duration(seconds: 20),
      retry: 2,
      fetcher: () async {
        final res = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
        if (res.statusCode == 200) {
          return List<Map<String, dynamic>>.from(jsonDecode(res.body));
        } else {
          throw Exception("Failed to fetch posts");
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => postsQuery.refetch(),
          ),
        ],
      ),
      body: QueryBuilder(
        query: postsQuery,
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text("Error: ${state.error}"));
          final posts = state.data ?? [];
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(post["title"]),
                  subtitle: Text(
                    post["body"].toString().length > 50
                        ? post["body"].toString().substring(0, 50) + "..."
                        : post["body"].toString(),
                  ),
                  onTap: () {
                    // Navigate to detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post["title"])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            post["body"],
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

