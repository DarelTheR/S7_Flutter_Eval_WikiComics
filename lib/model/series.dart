class Series {
  final String id;
  final String title;
  final String studio;
  final int episodes;
  final String year;
  final String imageUrl;

  const Series({
    required this.id,
    required this.title,
    required this.studio,
    required this.episodes,
    required this.year,
    required this.imageUrl,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id']?.toString() ?? '',
      title: json["name"] ?? "Titre inconnu",
      studio: json["publisher"]?["name"] ?? "Studio inconnu",
      episodes: json["count_of_episodes"] ?? 0,
      year: json["start_year"]?.toString() ?? "Année inconnue",
      imageUrl:
          json["image"]?["medium_url"] ?? "https://via.placeholder.com/150",
    );
  }
}
