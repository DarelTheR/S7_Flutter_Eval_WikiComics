import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Comic {
  final String id;
  final String title;
  final String studio;
  final String releaseDate;
  final String issueNumber;
  final String description;
  final String imageUrl;

  Comic({
    required this.id,
    required this.title,
    required this.studio,
    required this.releaseDate,
    required this.issueNumber,
    required this.description,
    required this.imageUrl,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    String formattedDate = "Date inconnue";
    if (json["cover_date"] != null && json["cover_date"].isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(json["cover_date"]);
        formattedDate = DateFormat("MMMM yyyy", "fr_FR").format(parsedDate);
      } catch (e) {
        debugPrint("Erreur lors du parsing de la date: $e");
        formattedDate = "Date invalide";
      }
    }

    return Comic(
      id: json["id"]?.toString() ?? "0",
      title: json["name"] ?? "Titre inconnu",
      studio: json["publisher"]?["name"] ?? "Studio inconnu",
      releaseDate: formattedDate,
      issueNumber: json["issue_number"]?.toString() ?? "Inconnu",
      description: json["description"] ?? "Aucune description disponible",
      imageUrl:
          json["image"]?["medium_url"] ?? "https://via.placeholder.com/150",
    );
  }
}
