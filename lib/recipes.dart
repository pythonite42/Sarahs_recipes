import 'package:flutter/material.dart';
import 'package:sarahs_recipes/database.dart';
import 'package:sarahs_recipes/new_recipe.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key, required this.category});
  final String category;

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  List<Recipe> recipes = [];
  late Future<void> initRecipesData;

  Future<void> initRecipes() async {
    var queryResult = await MySQL().getRecipes();
    if (queryResult is List) {
      recipes = List<Recipe>.from(queryResult);
    }
  }

  @override
  void initState() {
    super.initState();
    initRecipesData = initRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initRecipesData,
        builder: (BuildContext context, snapshot) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Text("TEst"),
                for (var recipe in recipes)
                  Row(
                    children: [
                      if (recipe.image != null)
                        Image.file(
                          recipe.image!,
                          width: 200,
                          height: 50,
                        ),
                      Text(recipe.name),
                      Text(recipe.category),
                      Text(recipe.instructions ?? "")
                    ],
                  )
              ],
            ),
          );
        });
  }
}
