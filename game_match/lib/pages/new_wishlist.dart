import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ApiService.dart';
import 'game_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShoppingCartProvider(),
      child: MaterialApp(
        title: 'wishlist screen',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WishlistPage(),
      ),
    );
  }
}

class ShoppingCartProvider with ChangeNotifier {
  final List<Product> _cart = [];

  List<Product> get cart => _cart;

  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product);
    notifyListeners();
  }
}

class Product {
  final String name;
  final double price;
  final String platforms;
  final String imageUrl;

  Product({required this.name, required this.price, required this.platforms, required this.imageUrl});
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final ApiService apiService = ApiService();



  String _sortCriteria = 'Sort by Custom';
  List<Product> _filteredProducts = [];

  bool isFree = false;
  bool isBetween0And20 = false;
  bool isBetween20And50 = false;
  bool isBetween50And85 = false;

  final Uri _url = Uri.parse('https://www.google.com');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'counldnt reach site: $_url';
    }
  }

  @override
  void initState() {
    super.initState();
    _filteredProducts = _products;
  }

  void _sortProducts(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (_sortCriteria == 'Price: Low to High') {
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortCriteria == 'Price: High to Low') {
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      } else if (_sortCriteria == 'Name: A - Z') {
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortCriteria == 'Name: Z - A') {
        _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
      }
    });
  }

  void updatePriceFilters(bool free, bool between0And20, bool between20And50, bool between50And85) {
    setState(() {
      isFree = free;
      isBetween0And20 = between0And20;
      isBetween20And50 = between20And50;
      isBetween50And85 = between50And85;
      _applyFilters();
    });
  }

  Map<String, String> _getStoreUrls(String gameName) {
    final encodedName = Uri.encodeComponent(gameName);

    return {
      'Steam': 'https://store.steampowered.com/search/?term=$encodedName',
      'Playstation Store': 'https://store.playstation.com/search/$encodedName',
      'Xbox': 'https://www.xbox.com/en-US/search?q=$encodedName',
      'Nintendo Store': 'https://www.nintendo.com/search/#q=$encodedName',
    };
  }

  void _removeProduct(Product product) {
    setState(() {
      _products.remove(product);
    });
  }

  void _showRemoveDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Game'),
          content: Text('Would you like to remove ${product.name} from the wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeProduct(product);
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showLinkDialog(BuildContext context, Product product) {
    final urls = _getStoreUrls(product.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Visit Store for ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLinkText('Steam', urls['Steam']!),
              _buildLinkText('Playstation Store', urls['Playstation Store']!),
              _buildLinkText('Xbox', urls['Xbox']!),
              _buildLinkText('Nintendo Store', urls['Nintendo Store']!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLinkText(String label, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        if (isFree && product.price == 0.0) return true;
        if (isBetween0And20 && product.price > 0.0 && product.price <= 20.0) return true;
        if (isBetween20And50 && product.price > 20.0 && product.price <= 50.0) return true;
        if (isBetween50And85 && product.price > 50.0 && product.price <= 85.0) return true;
        return false;
      }).toList();
    });
  }



  void _searchProducts(String query) {
    setState(() {
      _filteredProducts = _products
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _sortProducts(_sortCriteria);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<ShoppingCartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        leading: IconButton(
          icon: const Icon(Icons.menu), // Three horizontal lines (hamburger menu icon)
          onPressed: () {
            // Handle menu press
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('')),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xffF1F3F4),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortCriteria,
                  onChanged: (value) {
                    _sortProducts(value!);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'Sort by Custom',
                      child: Text('Sort by Custom'),
                    ),
                    DropdownMenuItem(
                      value: 'Price: Low to High',
                      child: Text('Price: Low to High'),
                    ),
                    DropdownMenuItem(
                      value: 'Price: High to Low',
                      child: Text('Price: High to Low'),
                    ),
                    DropdownMenuItem(
                      value: 'Name: A - Z',
                      child: Text('Name: A - Z'),
                    ),
                    DropdownMenuItem(
                      value: 'Name: Z - A',
                      child: Text('Name: Z - A'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<Game?>(
                                    future: ApiService().fetchGameDetailsTwo(product.name),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError || snapshot.data == null) {
                                        return const Text('Error fetching game details');
                                      } else {
                                        final game = snapshot.data!;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(game.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            Text('Platforms: ${game.platforms.join(', ')}'),
                                            Text('Price: \$${product.price.toStringAsFixed(2)}'),
                                          ],
                                        );
                                      }
                                    },
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: FutureBuilder<Game?>(
                                      future: ApiService().fetchGameDetailsTwo(product.name),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError || snapshot.data == null) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 8),
                                              Text('Platforms: ${product.platforms}'),
                                              const SizedBox(height: 8),

                                              FutureBuilder<String>(
                                                future: apiService.fetchGamePrice(product.name),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const Text('Loading price...');
                                                  } else if (snapshot.hasError) {
                                                    return const Text('Error fetching price');
                                                  } else {
                                                    return Text(
                                                      'Price: ${snapshot.data}',
                                                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        } else {
                                          final game = snapshot.data!;
                                          final platformNames = game.platforms.join(', ');

                                          return Row(
                                            children: [
                                              // Cover Image with specified dimensions
                                              Image.network(
                                                product.imageUrl,
                                                width: 80,
                                                height: 120,
                                                fit: BoxFit.cover, // Ensures the image fills the box without distortion
                                              ),
                                              const SizedBox(width: 16), // Spacing between image and text

                                              // Product details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(game.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                    Text('Platforms: ${game.platforms.join(', ')}'),
                                                    Text('Price: \$${product.price.toStringAsFixed(2)}'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 45),
                            ],
                          ),
                        ),

                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _showLinkDialog(context, product),
                                child: const Text('Buy Now'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () => _showRemoveDialog(context, product),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 45),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  bool isFree = false;
  bool isBetween0And20 = false;
  bool isBetween20And50 = false;
  bool isBetween50And85 = false;
  bool isPC = false;
  bool isPS4 = false;
  bool isXboxOne = false;
  bool isSwitch = false;

  void clearAllFilters() {
    setState(() {
      isFree = false;
      isBetween0And20 = false;
      isBetween20And50 = false;
      isBetween50And85 = false;
      isPC = false;
      isPS4 = false;
      isXboxOne = false;
      isSwitch = false;
    });
  }

  void seeResults() {
    Navigator.pop(context);
    final wishlistState = context.findAncestorStateOfType<_WishlistPageState>();
    if (wishlistState != null) {
      wishlistState.updatePriceFilters(
        isFree,
        isBetween0And20,
        isBetween20And50,
        isBetween50And85,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Filters')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Price'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChoosePricePage(
                    isFree: isFree,
                    isBetween0And20: isBetween0And20,
                    isBetween20And50: isBetween20And50,
                    isBetween50And85: isBetween50And85,
                    onSelectionChanged: (free, between0And20, between20And50, between50And85) {
                      setState(() {
                        isFree = free;
                        isBetween0And20 = between0And20;
                        isBetween20And50 = between20And50;
                        isBetween50And85 = between50And85;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Platform'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChoosePlatformPage(
                    isPC: isPC,
                    isPS4: isPS4,
                    isXboxOne: isXboxOne,
                    isSwitch: isSwitch,
                    onSelectionChanged: (pc, ps4, xboxOne, switchPlatform) {
                      setState(() {
                        isPC = pc;
                        isPS4 = ps4;
                        isXboxOne = xboxOne;
                        isSwitch = switchPlatform;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: clearAllFilters, child: const Text('Clear')),
              ElevatedButton(onPressed: seeResults, child: const Text('See Results')),
            ],
          )
        ],
      ),
    );
  }
}



class ChoosePricePage extends StatefulWidget {
  final bool isFree, isBetween0And20, isBetween20And50, isBetween50And85;
  final Function(bool, bool, bool, bool) onSelectionChanged;

  const ChoosePricePage({super.key, 
    required this.isFree,
    required this.isBetween0And20,
    required this.isBetween20And50,
    required this.isBetween50And85,
    required this.onSelectionChanged,
  });

  @override
  _ChoosePricePageState createState() => _ChoosePricePageState();
}

class _ChoosePricePageState extends State<ChoosePricePage> {
  late bool isFree, isBetween0And20, isBetween20And50, isBetween50And85;

  @override
  void initState() {
    super.initState();
    isFree = widget.isFree;
    isBetween0And20 = widget.isBetween0And20;
    isBetween20And50 = widget.isBetween20And50;
    isBetween50And85 = widget.isBetween50And85;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Price')),
      body: Column(
        children: [
          CheckboxListTile(
            title: const Text('Free'),
            value: isFree,
            onChanged: (value) {
              setState(() => isFree = value ?? false);
              widget.onSelectionChanged(isFree, isBetween0And20, isBetween20And50, isBetween50And85);
            },
          ),
          CheckboxListTile(
            title: const Text('\$0 - \$20'),
            value: isBetween0And20,
            onChanged: (value) {
              setState(() => isBetween0And20 = value ?? false);
              widget.onSelectionChanged(isFree, isBetween0And20, isBetween20And50, isBetween50And85);
            },
          ),
          CheckboxListTile(
            title: const Text('\$20 - \$50'),
            value: isBetween20And50,
            onChanged: (value) {
              setState(() => isBetween20And50 = value ?? false);
              widget.onSelectionChanged(isFree, isBetween0And20, isBetween20And50, isBetween50And85);
            },
          ),
          CheckboxListTile(
            title: const Text('\$50 - \$85'),
            value: isBetween50And85,
            onChanged: (value) {
              setState(() => isBetween50And85 = value ?? false);
              widget.onSelectionChanged(isFree, isBetween0And20, isBetween20And50, isBetween50And85);
            },
          ),
        ],
      ),
    );
  }
}



class ChoosePlatformPage extends StatefulWidget {
  final bool isPC, isPS4, isXboxOne, isSwitch;
  final Function(bool, bool, bool, bool) onSelectionChanged;

  const ChoosePlatformPage({super.key, 
    required this.isPC,
    required this.isPS4,
    required this.isXboxOne,
    required this.isSwitch,
    required this.onSelectionChanged,
  });

  @override
  _ChoosePlatformPageState createState() => _ChoosePlatformPageState();
}

class _ChoosePlatformPageState extends State<ChoosePlatformPage> {
  late bool isPC, isPS4, isXboxOne, isSwitch;

  @override
  void initState() {
    super.initState();
    isPC = widget.isPC;
    isPS4 = widget.isPS4;
    isXboxOne = widget.isXboxOne;
    isSwitch = widget.isSwitch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Platform')),
      body: Column(
        children: [
          CheckboxListTile(
            title: const Text('PC'),
            value: isPC,
            onChanged: (value) {
              setState(() => isPC = value ?? false);
              widget.onSelectionChanged(isPC, isPS4, isXboxOne, isSwitch);
            },
          ),
          CheckboxListTile(
            title: const Text('Playstation 4'),
            value: isPS4,
            onChanged: (value) {
              setState(() => isPS4 = value ?? false);
              widget.onSelectionChanged(isPC, isPS4, isXboxOne, isSwitch);
            },
          ),
          CheckboxListTile(
            title: const Text('Xbox One'),
            value: isXboxOne,
            onChanged: (value) {
              setState(() => isXboxOne = value ?? false);
              widget.onSelectionChanged(isPC, isPS4, isXboxOne, isSwitch);
            },
          ),
          CheckboxListTile(
            title: const Text('Nintendo Switch'),
            value: isSwitch,
            onChanged: (value) {
              setState(() => isSwitch = value ?? false);
              widget.onSelectionChanged(isPC, isPS4, isXboxOne, isSwitch);
            },
          ),
        ],
      ),
    );
  }
}



class ChooseGenresPage extends StatefulWidget {
  final bool isFiction;
  final bool isNonFiction;
  final Function(bool, bool) onSelectionChanged;

  const ChooseGenresPage({super.key, 
    required this.isFiction,
    required this.isNonFiction,
    required this.onSelectionChanged,
  });

  @override
  _ChooseGenresPageState createState() => _ChooseGenresPageState();
}

class _ChooseGenresPageState extends State<ChooseGenresPage> {
  late bool isFiction;
  late bool isNonFiction;

  @override
  void initState() {
    super.initState();
    isFiction = widget.isFiction;
    isNonFiction = widget.isNonFiction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Genres'),
      ),
      body: Column(
        children: [
          CheckboxListTile(
            title: const Text('Fiction'),
            value: isFiction,
            onChanged: (value) {
              setState(() {
                isFiction = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Non-Fiction'),
            value: isNonFiction,
            onChanged: (value) {
              setState(() {
                isNonFiction = value ?? false;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onSelectionChanged(isFiction, isNonFiction);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
