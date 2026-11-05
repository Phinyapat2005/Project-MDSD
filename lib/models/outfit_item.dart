class OutfitItem {
  final String id;
  final String title;
  final String category;
  final int price;
  final String imageUrl;
  final String? description;
  final String gender; // 'ชาย', 'หญิง', 'Unisex'

  const OutfitItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.description,
    this.gender = 'Unisex',
  });

  String get formattedPrice => '฿${_formatNumber(price)}';

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
