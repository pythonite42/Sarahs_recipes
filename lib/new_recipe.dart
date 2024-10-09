import 'dart:io';
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
  File? image;

  List<Ingredient> ingredients = [];

  var item = <int, Widget>{};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    item.addAll({0: newMethod(context, 0, FocusNode())});
  }

  newMethod(BuildContext context, int index, FocusNode focusNode) {
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
                focusNode: focusNode,
                controller: amountController,
                decoration: InputDecoration(
                  hintText: 'Menge',
                  hintStyle: TextStyle(fontWeight: FontWeight.w300),
                ),
                textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 8,
              child: TextFormField(
                controller: unitController,
                decoration: InputDecoration(
                  hintText: 'Einheit',
                  hintStyle: TextStyle(fontWeight: FontWeight.w300),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
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
                  var newFocusNode = FocusNode();
                  item.addAll({item.keys.last + 1: newMethod(context, item.keys.last + 1, newFocusNode)});
                  setState(() {});
                  newFocusNode.requestFocus();
                },
                decoration: InputDecoration(hintText: 'Zutat', hintStyle: TextStyle(fontWeight: FontWeight.w300)),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: true,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    item.removeWhere((key, value) => key == index);
                    amountTECs.removeWhere((key, value) => key == index);
                    unitTECs.removeWhere((key, value) => key == index);
                    nameTECs.removeWhere((key, value) => key == index);
                  });
                  if (item.isEmpty) {
                    item.addAll({0: newMethod(context, 0, FocusNode())});
                  }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (titleController.value.text.isNotEmpty ||
            image != null ||
            (nameTECs.keys.isNotEmpty && nameTECs[0]!.value.text.isNotEmpty) ||
            instructionsController.value.text.isNotEmpty) {
          showDialog(
            useRootNavigator: false,
            context: context,
            builder: (_) {
              return AlertDialog(
                content: Text("Willst du alle Eingaben löschen?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Ja, alles löschen")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Abbrechen")),
                ],
              );
            },
            barrierDismissible: false,
          );
        } else {
          Navigator.pop(context);
        }
      },
      child: SingleChildScrollView(
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
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 15),
                Column(children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                      final pathVar = pickedImage?.path;
                      if (pathVar == null) {
                        return;
                      }
                      File file = File(pathVar);
                      setState(() {
                        image = file;
                      });
                    },
                    child: (image != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
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
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ingredients.clear();

                      for (int i = 0; i <= nameTECs.keys.last; i++) {
                        var amount = amountTECs[i]?.value.text;
                        var unit = unitTECs[i]?.value.text;
                        var name = nameTECs[i]?.value.text;

                        if (name != null && name != "") {
                          double? amountDouble;
                          if (amount != null) {
                            amountDouble = double.parse(amount.replaceAll(",", "."));
                            amountDouble = double.parse(amountDouble.toStringAsFixed(1));
                          }
                          ingredients.add(Ingredient(amountDouble, unit, name));
                        }
                      }

                      Recipe recipe = Recipe(titleController.value.text, image, widget.category, ingredients,
                          instructionsController.value.text);
                      showDialog(
                        useRootNavigator: false,
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(color: Theme.of(context).primaryColor),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text("Loading ..."),
                              ],
                            ),
                          );
                        },
                        barrierDismissible: false,
                      );
                      var result = await MySQL().recipeEntry(recipe);
                      setState(() {});
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (result != true) {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text("Fehlermeldung"),
                                content: Text(result.toString()),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Okay")),
                                ],
                              );
                            },
                            barrierDismissible: false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: Text('Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Ingredient {
  final double? amount;
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
  final File? image;
  final String category;
  final List<Ingredient> ingredients;
  final String? instructions;

  Recipe(this.name, this.image, this.category, this.ingredients, this.instructions);
}
