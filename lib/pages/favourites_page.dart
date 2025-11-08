import 'package:flutter/material.dart';
import 'package:mixy_app/main.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    if (appState.favorites.isEmpty) {
      return Scaffold(body: Center(child: Text('No favorites yet.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView.builder(
          itemCount: appState.favorites.length,
          itemBuilder: (context, index) {
            final pair = appState.favorites[index];

            return Dismissible(
              key: ValueKey(pair.asLowerCase),
              direction: DismissDirection.horizontal, // right to left
              background: Container(
                color: theme.colorScheme.surface,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              onDismissed: (direction) {
                appState.removeFavorite(pair);
              },
              child: ListTile(
                leading: Icon(Icons.favorite, color: theme.colorScheme.primary),
                title: Text(pair.asLowerCase),
              ),
            );
          },
        ),
      ),
    );
  }
}
