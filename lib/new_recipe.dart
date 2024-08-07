import 'package:flutter/material.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  var titleController = TextEditingController();
  var amountTECs = <int, TextEditingController>{};
  var unitTECs = <int, TextEditingController>{};
  var nameTECs = <int, TextEditingController>{};
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
    return Row(
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
                      (amountController.value.text.isNotEmpty ||
                          unitController.value.text.isNotEmpty)
                  ? 'Zutat eingeben'
                  : null;
            },
            onFieldSubmitted: (value) {
              item.addAll(
                  {item.keys.last + 1: newMethod(context, item.keys.last + 1)});
              setState(() {});
            },
            decoration: InputDecoration(
                hintText: 'Zutat',
                hintStyle: TextStyle(fontWeight: FontWeight.w300)),
          ),
        ),
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: nameTECs.keys.length > 1,
          child: IconButton(
            onPressed: () {
              setState(() {
                item.removeWhere((key, value) => key == index);
                amountTECs.removeWhere((key, value) => key == index);
                unitTECs.removeWhere((key, value) => key == index);
                nameTECs.removeWhere((key, value) => key == index);
              });
            },
            iconSize: 20,
            color: Colors.grey,
            icon: Icon(Icons.delete),
          ),
        ),
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
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                style: TextStyle(fontSize: 30),
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
              SizedBox(height: 30),
              ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: item.length,
                  itemBuilder: (context, index) {
                    return item.values.elementAt(index);
                  }),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ingredients.clear();
                    var title = titleController.value.text;
                    print("title: $title");
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
                    setState(() {});
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
  final String? name;

  Ingredient(
    this.amount,
    this.unit,
    this.name,
  );
}
