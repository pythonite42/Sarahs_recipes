import 'package:flutter/material.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Column(
            children: [
              TextFormField(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 7,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Menge',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 7,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Einheit',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2.25,
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        print("submitted");
                      },
                      decoration: InputDecoration(
                          hintText: 'Zutat',
                          hintStyle: TextStyle(fontWeight: FontWeight.w300)),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //daten speichern
                  }
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
