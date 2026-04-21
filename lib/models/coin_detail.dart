class CoinDetail {
  final String description;

  CoinDetail({required this.description});

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    String desc = '';
    if (json['description'] != null && json['description']['en'] != null) {
      desc = json['description']['en'];
    }
    // Remove HTML tags for clean display
    desc = desc.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    return CoinDetail(description: desc);
  }
}
