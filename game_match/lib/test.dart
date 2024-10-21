import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Image')),
      body: Center(
        child: CachedNetworkImage(
          imageUrl:
              'https://images.igdb.com/igdb/image/upload/t_cover_bigco52iy.jpg',
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
