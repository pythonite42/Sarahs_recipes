import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarahs_recipes/database.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key, required this.category});
  final String category;

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  var titleController = TextEditingController();
  var amountTECs = <int, TextEditingController>{};
  var unitTECs = <int, TextEditingController>{};
  var nameTECs = <int, TextEditingController>{};
  var instructionsController = TextEditingController();
  Uint8List? image;

  List<Ingredient> ingredients = [];

  var item = <int, Widget>{};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    item.addAll({0: newMethod(context, 0)});
  }

  newMethod(
    BuildContext context,
    int index,
  ) {
    var amountController = TextEditingController();
    var unitController = TextEditingController();
    var nameController = TextEditingController();
    amountTECs.addAll({index: amountController});
    unitTECs.addAll({index: unitController});
    nameTECs.addAll({index: nameController});
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 8,
              child: TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  hintText: 'Menge',
                  hintStyle: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 8,
              child: TextFormField(
                controller: unitController,
                decoration: InputDecoration(
                  hintText: 'Einheit',
                  hintStyle: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 2.5,
              child: TextFormField(
                controller: nameController,
                validator: (value) {
                  return value!.isEmpty &&
                          (amountController.value.text.isNotEmpty || unitController.value.text.isNotEmpty)
                      ? 'Zutat eingeben'
                      : null;
                },
                onFieldSubmitted: (value) {
                  item.addAll({item.keys.last + 1: newMethod(context, item.keys.last + 1)});
                  setState(() {});
                },
                decoration: InputDecoration(hintText: 'Zutat', hintStyle: TextStyle(fontWeight: FontWeight.w300)),
              ),
            ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: nameTECs.keys.length > 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    item.removeWhere((key, value) => key == index);
                    amountTECs.removeWhere((key, value) => key == index);
                    unitTECs.removeWhere((key, value) => key == index);
                    nameTECs.removeWhere((key, value) => key == index);
                  });
                },
                child: Icon(
                  Icons.delete,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    for (int i = 0; i <= nameTECs.keys.last; i++) {
      amountTECs[i]?.dispose();
      unitTECs[i]?.dispose();
      nameTECs[i]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              Text(
                "Neues Rezept in ${widget.category}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              ),
              SizedBox(height: 30),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: titleController,
                style: GoogleFonts.indieFlower(fontSize: 30),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Titel',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Füge einen Titel hinzu';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              Column(children: [
                GestureDetector(
                  onTap: () async {
                    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    Uint8List? bytes = await pickedImage?.readAsBytes();
                    setState(() {
                      image = bytes;
                    });
                  },
                  child: (image != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            image!,
                            fit: BoxFit.cover,
                          ))
                      : Container(
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          height: MediaQuery.sizeOf(context).width * 0.3,
                          decoration: ShapeDecoration(
                              color: Colors.black12,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: Icon(
                            Icons.photo,
                            size: MediaQuery.sizeOf(context).width * 0.15,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ]),
              SizedBox(height: 30),
              Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.surfaceDim,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Zutaten",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: item.length,
                          itemBuilder: (context, index) {
                            return item.values.elementAt(index);
                          }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.surfaceDim,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    Text(
                      "Zubereitung",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: instructionsController,
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 15,
                    ),
                  ]),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ingredients.clear();
                    Recipe recipe =
                        Recipe(titleController.value.text, image, widget.category, instructionsController.value.text);
                    var title = titleController.value.text;
                    print("recipe: $recipe");
                    for (int i = 0; i <= nameTECs.keys.last; i++) {
                      var amount = amountTECs[i]?.value.text;
                      var unit = unitTECs[i]?.value.text;
                      var name = nameTECs[i]?.value.text;

                      if (name != null) {
                        ingredients.add(Ingredient(amount, unit, name));
                      }
                    }
                    print(ingredients);
                    for (int a = 0; a < ingredients.length; a++) {
                      print(ingredients[a].amount);
                      print(ingredients[a].unit);
                      print(ingredients[a].name);
                    }
                    // _formKey.currentState!.save();
                    MySQL().recipeEntry(recipe);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Ingredient {
  final String? amount;
  final String? unit;
  final String name;

  Ingredient(
    this.amount,
    this.unit,
    this.name,
  );
}

class Recipe {
  final String name;
  final Uint8List? image;
  final String category;
  final String? instructions;

  Recipe(this.name, this.image, this.category, this.instructions);
}
