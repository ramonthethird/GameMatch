class PriceOffer {
  final String storeName;
  final String storeType;
  final String region;
  final String edition;
  final double price;
  final String currency;
  final String url;

  PriceOffer({
    required this.storeName,
    required this.storeType,
    required this.region,
    required this.edition,
    required this.price,
    required this.currency,
    required this.url,
  });

  // Factory method to create a PriceOffer instance from JSON
  factory PriceOffer.fromJson(Map<String, dynamic> json) {
    return PriceOffer(
      storeName: json['store']['name'] as String? ?? 'Unknown Store',
      storeType: json['store']['type'] as String? ?? 'Unknown Type',
      region: json['region'] as String? ?? 'Unknown Region',
      edition: json['edition'] as String? ?? 'Standard',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      url: json['url'] as String? ?? '',
    );
  }
}