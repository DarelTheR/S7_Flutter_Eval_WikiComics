import 'package:flutter/material.dart';
import 'package:wikiwomics/pages/comics_page.dart';
import 'package:wikiwomics/pages/home_page.dart';
import 'package:wikiwomics/pages/movies_page.dart';
import 'package:wikiwomics/pages/search_page.dart';
import 'package:wikiwomics/pages/series_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String series = '/series';
  static const String comics = '/comics';
  static const String movies = '/movies';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case series:
        return MaterialPageRoute(builder: (_) => const SeriesPage());
      case comics:
        return MaterialPageRoute(builder: (_) => const ComicsPage());
      case movies:
        return MaterialPageRoute(builder: (_) => const MoviesPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
