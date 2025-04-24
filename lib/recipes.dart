import 'package:flutter/material.dart';
import 'package:sarahs_recipes/database.dart';
import 'package:sarahs_recipes/main.dart';

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
    var queryResult = await MySQL().getRecipesByCategory(widget.category);
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
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Theme.of(context).primaryColor),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Loading ..."),
                  ],
                ));
              }
            case ConnectionState.done:
              {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        for (var recipe in recipes)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/recipePage',
                                      arguments: ScreenArguments(recipe: recipe));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Material(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        child: (recipe.image != null)
                                            ? Image.file(
                                                recipe.image!,
                                                fit: BoxFit.cover,
                                              )
                                            : Ink.image(
                                                image: AssetImage('assets/missing_image.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Text(
                                        recipe.name,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if (recipes.last.name != recipe.name)
                                Divider(
                                  height: 30,
                                  thickness: 0.3,
                                )
                            ],
                          )
                      ],
                    ),
                  ),
                );
              }
          }
        });
  }
}
