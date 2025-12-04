class AdminProduct {
  final int id;
  final String title;
  final String text;
  final int price;
  final String? image;
  final String? imageUrl;
  final String? alamat;
  final String? nomorHp;
  final DateTime? createdAt;

  AdminProduct({
    required this.id,
    required this.title,
    required this.text,
    required this.price,
    this.image,
    this.imageUrl,
    this.alamat,
    this.nomorHp,
    this.createdAt,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['nama'] as String? ?? '',
      text: json['text'] as String? ?? json['deskripsi'] as String? ?? '',
      price: json['price'] as int? ?? json['harga'] as int? ?? 0,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      alamat: json['alamat'] as String?,
      nomorHp: json['nomor_hp'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'price': price,
      'image': image,
      'image_url': imageUrl,
      'alamat': alamat,
      'nomor_hp': nomorHp,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AdminProduct copyWith({
    int? id,
    String? title,
    String? text,
    int? price,
    String? image,
    String? imageUrl,
    String? alamat,
    String? nomorHp,
    DateTime? createdAt,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      price: price ?? this.price,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      alamat: alamat ?? this.alamat,
      nomorHp: nomorHp ?? this.nomorHp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedPrice {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}
