class Tip {
  final String title;
  final String description;

  Tip({required this.title, required this.description});

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
    );
  }
}

class Inspiration {
  final String title;
  final String story;

  Inspiration({required this.title, required this.story});

  factory Inspiration.fromJson(Map<String, dynamic> json) {
    return Inspiration(
      title: json['title'] ?? 'No Title',
      story: json['body'] ?? 'No Content Available',
    );
  }
}
