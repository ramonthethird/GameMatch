import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final String username;

  const WelcomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Game Match!'),
        backgroundColor: const Color(0xFF74ACD5),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/Side_bar');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Welcome, $username!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Discover new games and connect with other gamers!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildFeatureCard(
              context,
              title: 'Top Rated Games',
              description: 'Check out the best games available right now.',
              icon: Icons.star,
              routeName: '/top_games',
            ),
            _buildFeatureCard(
              context,
              title: 'Upcoming Releases',
              description: 'Stay updated with the latest game releases.',
              icon: Icons.new_releases,
              routeName: '/upcoming_releases',
            ),
            _buildFeatureCard(
              context,
              title: 'Community Events',
              description: 'Join events and connect with other gamers.',
              icon: Icons.people,
              routeName: '/community_events',
            ),
            _buildFeatureCard(
              context,
              title: 'Game Reviews',
              description: 'Read and write reviews for your favorite games.',
              icon: Icons.rate_review,
              routeName: '/game_reviews',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required String routeName}) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF74ACD5)),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
