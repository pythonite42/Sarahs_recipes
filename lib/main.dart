import 'package:flutter/material.dart';
import 'package:sarahs_recipes/categories.dart';
import 'package:sarahs_recipes/new_recipe.dart';
import 'colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarahs Recipes',
      themeMode: ThemeMode.light,
      theme: GlobalThemData.lightThemeData,
      darkTheme: GlobalThemData.darkThemeData,
      initialRoute: '/',
      routes: {
        '/': (context) => MyScaffold(body: Categories()),
        '/newRecipe': (context) => MyScaffold(body: NewRecipe()),
      },
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold(
      {super.key, required this.body, this.floatingActionButton = false});

  final Widget body;
  final bool floatingActionButton;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        centerTitle: true,
        title:
            Text("Meine Rezepte", style: GoogleFonts.indieFlower(fontSize: 30)),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newRecipe');
        },
        tooltip: 'Neues Rezept',
        child: Icon(Icons.add),
      ),
    );
  }
}
