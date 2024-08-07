import 'package:flutter/material.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Container(width: double.infinity, height: 50, child: Text("hi")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Test"))
        ],
      ),
    );
  }
}
