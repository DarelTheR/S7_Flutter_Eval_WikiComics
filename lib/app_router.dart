import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wikiwomics/pages/comics_page.dart';
import 'package:wikiwomics/pages/detail_page.dart';
import 'package:wikiwomics/pages/home_page.dart';
import 'package:wikiwomics/pages/movies_page.dart';
import 'package:wikiwomics/pages/search_page.dart';
import 'package:wikiwomics/pages/series_page.dart';
import 'package:wikiwomics/app_routes.dart';

final GoRouter appRouter = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <GoRoute>[
        GoRoute(
          path: AppRoutes.home,
          builder: (BuildContext context, GoRouterState state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.series,
          builder: (context, state) {
            return SeriesPage();
          },
        ),
        GoRoute(
          path: AppRoutes.comics,
          builder: (BuildContext context, GoRouterState state) => const ComicsPage(),
        ),
        GoRoute(
          path: AppRoutes.movies,
          builder: (BuildContext context, GoRouterState state) => const MoviesPage(),
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (BuildContext context, GoRouterState state) => const SearchPage(),
        ),
        GoRoute(
          path: AppRoutes.detail,
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>; // Récupération des arguments
            final media = extra['media'] as Map<String, dynamic>;
            final mediaType = extra['mediaType'] as String;
            return DetailPage(media: media, mediaType: mediaType);
          },
        ),
      ],
    ),
  ],
);
