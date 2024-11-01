import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wishlist_model.dart';
import 'package:url_launcher/url_launcher.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistGame> wishlist = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    final wishlistCollection =
        FirebaseFirestore.instance.collection('wishlist');
    final snapshot = await wishlistCollection.get();
    setState(() {
      wishlist = snapshot.docs
          .map((doc) => WishlistGame(
              id: doc.id,
              name: doc['name'],
              coverUrl: doc['coverUrl'],
              url: doc['url']))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: wishlist.isEmpty
          ? Center(child: Text('No items in wishlist.'))
          : ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final wishlistItem = wishlist[index];
                return ListTile(
                  leading: Image.network(
                    wishlistItem.coverUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported);
                    },
                  ),
                  title: Text(wishlistItem.name),
                  subtitle: TextButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(wishlistItem.url);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text(wishlistItem.url),
                  ),
                );
              },
            ),
    );
  }
}
