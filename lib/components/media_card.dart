import 'package:flutter/material.dart';
import 'package:wikiwomics/res/app_colors.dart';

class MediaCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const MediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Largeur fixe de la carte
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.blueBlue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect( // rectangle aux bords arrondis
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network( // Image récupérée depuis une URL.
              imageUrl,
              width: double.infinity,
              height: 200, // Hauteur fixe de l'image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.error, color: Colors.white)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
