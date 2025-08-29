import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarahs_recipes/database.dart';
import 'package:sarahs_recipes/main.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  bool isInEditMode = false;

  var titleController = TextEditingController();
  var amountTECs = <int, TextEditingController>{};
  var unitTECs = <int, TextEditingController>{};
  var nameTECs = <int, TextEditingController>{};
  var recipeQuantityController = TextEditingController();
  var recipeQuantityNameController = TextEditingController();
  var instructionsController = TextEditingController();
  File? image;

  double? quantityFromDatabase;

  List<Ingredient> ingredients = [];
  late Future<void> initIngredientsData;

  var ingredientWidgets = <int, Widget>{};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> initIngredients() async {
    var queryResult = await MySQL().getIngredientsById(widget.recipe.id);
    if (queryResult is List) {
      ingredients = List<Ingredient>.from(queryResult);
    }
    if (mounted) {
      ingredientWidgets = <int, Widget>{};
      for (final (i, ingredient) in ingredients.indexed) {
        final key = ingredient.entryNumber ?? i;
        ingredientWidgets.addAll({key: newMethod(context, key, FocusNode(), ingredient)});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initIngredientsData = initIngredients();
    titleController.text = widget.recipe.name;
    if (widget.recipe.quantity != null) {
      if (widget.recipe.quantity! % 1 == 0) {
        recipeQuantityController.text = widget.recipe.quantity!.toInt().toString();
      } else {
        recipeQuantityController.text = widget.recipe.quantity!.toString();
      }
      quantityFromDatabase = widget.recipe.quantity;
    }
    if (widget.recipe.quantityName != null) {
      recipeQuantityNameController.text = widget.recipe.quantityName!;
    }
    if (widget.recipe.instructions != null) {
      instructionsController.text = widget.recipe.instructions!;
    }
    image = widget.recipe.image;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ingredientWidgets.isEmpty) {
      ingredientWidgets.addAll({0: newMethod(context, 0, FocusNode(), null)});
    }
  }

  newMethod(BuildContext context, int index, FocusNode focusNode, Ingredient? ingredient) {
    var amountController = TextEditingController();
    if (ingredient?.amount != null) {
      if (ingredient!.amount! % 1 == 0) {
        amountController.text = ingredient.amount!.toInt().toString();
      } else {
        amountController.text = ingredient.amount.toString();
      }
    }
    var unitController = TextEditingController();
    if (ingredient?.unit != null) {
      unitController.text = ingredient!.unit!;
    }
    var nameController = TextEditingController();
    if (ingredient?.name != null) {
      nameController.text = ingredient!.name;
    }
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
              child: isInEditMode
                  ? TextFormField(
                      focusNode: focusNode,
                      controller: amountController,
                      decoration: InputDecoration(
                        hintText: 'Menge',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number)
                  : Text(amountController.text),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 8,
              child: isInEditMode
                  ? TextFormField(
                      controller: unitController,
                      decoration: InputDecoration(
                        hintText: 'Einheit',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                    )
                  : Text(unitController.text),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 2.5,
              child: isInEditMode
                  ? TextFormField(
                      controller: nameController,
                      validator: (value) {
                        return value!.isEmpty &&
                                (amountController.value.text.isNotEmpty || unitController.value.text.isNotEmpty)
                            ? 'Zutat eingeben'
                            : null;
                      },
                      onFieldSubmitted: (value) {
                        var newFocusNode = FocusNode();
                        int nextKey() {
                          if (ingredientWidgets.isEmpty) return 0;
                          final keys = ingredientWidgets.keys;
                          return (keys.reduce((a, b) => a > b ? a : b)) + 1;
                        }

                        final key = nextKey();
                        ingredientWidgets.addAll({key: newMethod(context, key, newFocusNode, null)});

                        setState(() {});
                        newFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(hintText: 'Zutat', hintStyle: TextStyle(fontWeight: FontWeight.w300)),
                      textCapitalization: TextCapitalization.words,
                    )
                  : Text(nameController.text),
            ),
            if (isInEditMode)
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: true,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      ingredientWidgets.removeWhere((key, value) => key == index);
                      amountTECs.removeWhere((key, value) => key == index);
                      unitTECs.removeWhere((key, value) => key == index);
                      nameTECs.removeWhere((key, value) => key == index);
                    });
                    if (ingredientWidgets.isEmpty) {
                      ingredientWidgets.addAll({0: newMethod(context, 0, FocusNode(), null)});
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
    for (final k in nameTECs.keys) {
      amountTECs[k]?.dispose();
      unitTECs[k]?.dispose();
      nameTECs[k]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initIngredientsData,
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
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) {
                      return;
                    }
                    if (isInEditMode &&
                        (titleController.value.text.isNotEmpty ||
                            image != null ||
                            (nameTECs.keys.isNotEmpty && nameTECs[0]!.value.text.isNotEmpty) ||
                            instructionsController.value.text.isNotEmpty)) {
                      showDialog(
                        useRootNavigator: false,
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            content: Text("Willst du alle Änderungen verwerfen?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ja, Änderungen verwerfen")),
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
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                          children: [
                            if (isInEditMode)
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
                              isInEditMode
                                  ? GestureDetector(
                                      onTap: () async {
                                        final XFile? pickedImage =
                                            await ImagePicker().pickImage(source: ImageSource.gallery);
                                        final pathVar = pickedImage?.path;
                                        if (pathVar == null) {
                                          return;
                                        }
                                        File file = File(pathVar);
                                        setState(() {
                                          image = file;
                                        });
                                      },
                                      child: RecipeImage(image: image))
                                  : RecipeImage(image: image)
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text("Für "),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width / 8,
                                          child: TextFormField(
                                            controller: recipeQuantityController,
                                            decoration: InputDecoration(
                                              hintText: 'Anzahl',
                                              hintStyle: TextStyle(fontWeight: FontWeight.w300),
                                            ),
                                            textInputAction: (isInEditMode) ? TextInputAction.next : null,
                                            keyboardType: TextInputType.number,
                                            onFieldSubmitted: (newValue) {
                                              if (!isInEditMode) {
                                                ingredientWidgets = <int, Widget>{};

                                                var newValueDouble = double.parse(newValue.replaceAll(",", "."));
                                                newValueDouble = double.parse(newValueDouble.toStringAsFixed(1));

                                                for (final (i, ingredient) in ingredients.indexed) {
                                                  var newIngredient = ingredient;
                                                  if (ingredient.amount != null && quantityFromDatabase != null) {
                                                    double newAmount = double.parse(
                                                        (ingredient.amount! * newValueDouble / quantityFromDatabase!)
                                                            .toStringAsFixed(1));
                                                    newIngredient = Ingredient(ingredient.entryNumber, newAmount,
                                                        ingredient.unit, ingredient.name);
                                                  }
                                                  final key = ingredient.entryNumber ?? i;
                                                  ingredientWidgets.addAll(
                                                      {key: newMethod(context, key, FocusNode(), newIngredient)});
                                                }
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width / 3,
                                          child: isInEditMode
                                              ? TextFormField(
                                                  controller: recipeQuantityNameController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Bezeichnung',
                                                    hintStyle: TextStyle(fontWeight: FontWeight.w300),
                                                  ),
                                                  textInputAction: TextInputAction.next,
                                                )
                                              : Text(widget.recipe.quantityName ?? ""),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        itemCount: ingredientWidgets.length,
                                        itemBuilder: (context, index) {
                                          return ingredientWidgets.values.elementAt(index);
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
                                  isInEditMode
                                      ? TextFormField(
                                          controller: instructionsController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          maxLines: 15,
                                          textCapitalization: TextCapitalization.sentences,
                                        )
                                      : Container(
                                          //color: Theme.of(context).colorScheme.surface,
                                          constraints: BoxConstraints(minHeight: 200),
                                          width: double.infinity,
                                          child: Text(instructionsController.value.text),
                                        ),
                                ]),
                              ),
                            ),
                            SizedBox(height: 30),
                            (isInEditMode)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                            textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            ingredients.clear();

                                            for (final i in (nameTECs.keys.toList())) {
                                              final name = nameTECs[i]!.text.trim();
                                              if (name.isEmpty) continue;

                                              final amountText = amountTECs[i]?.text.trim() ?? '';
                                              double? amountDouble = amountText.isEmpty
                                                  ? null
                                                  : double.parse(amountText.replaceAll(',', '.'));
                                              if (amountDouble != null) {
                                                amountDouble = double.parse(amountDouble.toStringAsFixed(1));
                                              }
                                              final unit = unitTECs[i]?.text;

                                              ingredients.add(Ingredient(i, amountDouble, unit, name));
                                            }

                                            double? quantityDouble;
                                            if (recipeQuantityController.value.text != "") {
                                              quantityDouble = double.parse(
                                                  recipeQuantityController.value.text.replaceAll(",", "."));
                                              quantityDouble = double.parse(quantityDouble.toStringAsFixed(1));
                                            }

                                            Recipe recipe = Recipe(
                                                widget.recipe.id,
                                                titleController.value.text,
                                                image,
                                                widget.recipe.category,
                                                quantityDouble,
                                                recipeQuantityNameController.value.text,
                                                ingredients,
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
                                            var result = await MySQL().editEntry(recipe);
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
                                                Navigator.pop(context);
                                              }
                                            }
                                          }
                                        },
                                        child: Text('Speichern'),
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.secondary,
                                              textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                                          onPressed: () {
                                            showDialog(
                                              useRootNavigator: false,
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  content: Text("Willst du alle Änderungen verwerfen?"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          setState(() {
                                                            isInEditMode = false;
                                                            titleController.text = widget.recipe.name;
                                                            if (widget.recipe.quantity != null) {
                                                              if (widget.recipe.quantity! % 1 == 0) {
                                                                recipeQuantityController.text =
                                                                    widget.recipe.quantity!.toInt().toString();
                                                              } else {
                                                                recipeQuantityController.text =
                                                                    widget.recipe.quantity!.toString();
                                                              }
                                                              quantityFromDatabase = widget.recipe.quantity;
                                                            }
                                                            if (widget.recipe.quantityName != null) {
                                                              recipeQuantityNameController.text =
                                                                  widget.recipe.quantityName!;
                                                            }
                                                            if (widget.recipe.instructions != null) {
                                                              instructionsController.text = widget.recipe.instructions!;
                                                            }
                                                            image = widget.recipe.image;

                                                            ingredientWidgets = <int, Widget>{};
                                                            for (final (i, ingredient) in ingredients.indexed) {
                                                              final key = ingredient.entryNumber ?? i;
                                                              ingredientWidgets.addAll({
                                                                key: newMethod(context, key, FocusNode(), ingredient)
                                                              });
                                                            }
                                                          });
                                                        },
                                                        child: const Text("Ja, Änderungen verwerfen")),
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
                                          },
                                          child: Text("Abbrechen"))
                                    ],
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                                    onPressed: () {
                                      setState(() {
                                        isInEditMode = true;
                                        if (widget.recipe.quantity != null) {
                                          if (widget.recipe.quantity! % 1 == 0) {
                                            recipeQuantityController.text = widget.recipe.quantity!.toInt().toString();
                                          } else {
                                            recipeQuantityController.text = widget.recipe.quantity!.toString();
                                          }
                                        }
                                        ingredientWidgets = <int, Widget>{};
                                        for (final (i, ingredient) in ingredients.indexed) {
                                          final key = ingredient.entryNumber ?? i;
                                          ingredientWidgets
                                              .addAll({key: newMethod(context, key, FocusNode(), ingredient)});
                                        }
                                        if (ingredientWidgets.isEmpty) {
                                          ingredientWidgets.addAll({0: newMethod(context, 0, FocusNode(), null)});
                                        }
                                      });
                                    },
                                    child: Text("Bearbeiten")),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          }
        });
  }
}

class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.image});
  final File? image;

  @override
  Widget build(BuildContext context) {
    return (image != null)
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
                color: Colors.black12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Icon(
              Icons.photo,
              size: MediaQuery.sizeOf(context).width * 0.15,
              color: Colors.grey,
            ),
          );
  }
}
