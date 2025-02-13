import 'package:flutter/material.dart';
import 'package:sarahs_recipes/categories.dart';
import 'package:sarahs_recipes/new_recipe.dart';
import 'package:sarahs_recipes/recipe_page.dart';
import 'package:sarahs_recipes/recipes.dart';
import 'colors.dart';
import 'dart:io';
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
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: GlobalThemData.lightThemeData,
      darkTheme: GlobalThemData.darkThemeData,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) {
              return MyScaffold(pageTitle: "Meine Rezepte", body: Categories());
            },
          );
        } else if (settings.name == '/newRecipe') {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return MyScaffold(
                  pageTitle: args.newRecipeTitle ?? "Neues Rezept", body: NewRecipe(category: args.category!));
            },
          );
        } else if (settings.name == '/recipes') {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return MyScaffold(pageTitle: args.category!, body: Recipes(category: args.category!));
            },
          );
        } else if (settings.name == '/recipePage') {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return MyScaffold(pageTitle: args.recipe!.name, body: RecipePage(recipe: args.recipe!));
            },
          );
        }
        return null;
      },
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.body, required this.pageTitle, this.floatingActionButton = false});

  final Widget body;
  final String pageTitle;
  final bool floatingActionButton;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        centerTitle: true,
        title: Text(pageTitle, style: GoogleFonts.indieFlower(fontSize: 30)),
      ),
      body: body,
    );
  }
}

class ScreenArguments {
  final String? category;
  final String? newRecipeTitle;
  final Recipe? recipe;

  ScreenArguments({this.category, this.newRecipeTitle, this.recipe});
}

class Ingredient {
  final int? entryNumber;
  final double? amount;
  final String? unit;
  final String name;

  Ingredient(
    this.entryNumber,
    this.amount,
    this.unit,
    this.name,
  );
}

class Recipe {
  final int? id;
  final String name;
  final File? image;
  final String category;
  final double? quantity;
  final String? quantityName;
  final List<Ingredient> ingredients;
  final String? instructions;

  Recipe(this.id, this.name, this.image, this.category, this.quantity, this.quantityName, this.ingredients,
      this.instructions);
}
