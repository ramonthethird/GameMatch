import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GameMatchApp());
}

class GameMatchApp extends StatelessWidget {
  const GameMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameMatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GamingNewsPage(),
    );
  }
}

class GamingNewsPage extends StatefulWidget {
  const GamingNewsPage({super.key});
  @override
  _GamingNewsPageState createState() => _GamingNewsPageState();
}

class _GamingNewsPageState extends State<GamingNewsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List articles = [];

  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  Future<void> loadArticles() async {
    final firebaseArticles = await _firestore.collection('articles').get();

    if (firebaseArticles.docs.isNotEmpty) {
      // Load articles from Firebase
      setState(() {
        articles = firebaseArticles.docs
            .map((doc) => doc.data())
            .where((article) => article['urlToImage']?.isNotEmpty ?? false)
            .toList();
      });
    } else {
      // Fetch articles from NewsAPI and store them in Firebase
      await fetchArticlesFromAPI();
    }
  }

  Future<void> fetchArticlesFromAPI() async {
    final response = await http.get(
      Uri.parse(
          'https://newsapi.org/v2/everything?q="video game"&apiKey=08d497c0490f48d6ab3d6e2f48c5dbe4'),
    );

    if (response.statusCode == 200) {
      List fetchedArticles = json.decode(response.body)['articles'];

      // Filter articles to ensure they have title, author, publishedAt, and urlToImage is not empty
      fetchedArticles = fetchedArticles.where((article) {
        return article['title'] != null &&
               article['author'] != null &&
               article['publishedAt'] != null &&
               article['urlToImage'] != null &&
               article['urlToImage'].isNotEmpty;
      }).toList();

      setState(() {
        articles = fetchedArticles;
      });

      // Store filtered articles in Firebase
      for (var article in fetchedArticles) {
        _firestore.collection('articles').add({
          'title': article['title'],
          'author': article['author'],
          'publishedAt': article['publishedAt'],
          'urlToImage': article['urlToImage'],
        });
      }
    } else {
      throw Exception('Failed to load articles from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaming News', style: TextStyle(fontSize: 18)),
      ),
      body: articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return GamingNewsCard(
                  title: articles[index]['title'] ?? 'No Title',
                  author: articles[index]['author'] ?? 'Unknown Author',
                  date: articles[index]['publishedAt'] ?? 'Unknown Date',
                  imageUrl: articles[index]['urlToImage'] ?? '',
                );
              },
            ),
    );
  }
}

class GamingNewsCard extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String imageUrl;

  const GamingNewsCard({super.key, 
    required this.title,
    required this.author,
    required this.date,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Author: $author',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Date: ${date.substring(0, 10)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
