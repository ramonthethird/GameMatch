import 'package:flutter/material.dart';

class MoreGenresPage extends StatelessWidget {
  final List<String> selectedGenres;
  final Function(String) onGenresUnselected;

  const MoreGenresPage({super.key, required this.selectedGenres, required this.onGenresUnselected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View All Selected Genres')),
      body: ListView.builder(
        itemCount: selectedGenres.length,
        itemBuilder: (context, index) {
          String genre = selectedGenres[index];
          return ListTile(
            title: Text(genre),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () {
                onGenresUnselected(genre);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removing Genre')));
              },
            ),
          );
        },
      ),
    );
  }
}
