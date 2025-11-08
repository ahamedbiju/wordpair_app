import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/favourites_page.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ).surface,
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.interTextTheme(),
        ),

        home: HomePage(),
        routes: {'/favorites': (context) => FavoritesPage()},
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  WordPair current = WordPair.random();
  final List<WordPair> favorites = [];
  final List<WordPair> recent = [];

  static const String _kFavoritesKey = 'favorites_v1';
  static const String _sep = '||'; // separator used for serialization

  MyAppState() {
    _loadFavorites();
  }

  // --- Persistence ------------
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_kFavoritesKey) ?? [];
      favorites.clear();
      for (final s in saved) {
        final parts = s.split(_sep);
        if (parts.length == 2) {
          favorites.add(WordPair(parts[0], parts[1]));
        } else {
          // fallback: if somebody saved "first second" before, try to split on space
          final fallback = s.split(' ');
          if (fallback.length >= 2) {
            favorites.add(WordPair(fallback[0], fallback[1]));
          }
        }
      }
      notifyListeners();
    } catch (e) {
      // optional: handle load error (log it)
      debugPrint('Failed to load favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = favorites
          .map((wp) => '${wp.first}$_sep${wp.second}')
          .toList();
      await prefs.setStringList(_kFavoritesKey, serialized);
    } catch (e) {
      debugPrint('Failed to save favorites: $e');
    }
  }

  // --- App logic--------
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void addRecent() {
    recent.insert(0, current);
    if (recent.length > 3) recent.removeLast();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.any(
      (wp) => wp.first == current.first && wp.second == current.second,
    )) {
      favorites.removeWhere(
        (wp) => wp.first == current.first && wp.second == current.second,
      );
    } else {
      favorites.add(WordPair(current.first, current.second));
    }
    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.removeWhere(
      (wp) => wp.first == pair.first && wp.second == pair.second,
    );
    _saveFavorites();
    notifyListeners();
  }
}
