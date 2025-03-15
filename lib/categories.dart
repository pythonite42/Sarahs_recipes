import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarahs_recipes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Categories extends StatelessWidget {
  Categories({super.key, required this.users});

  final List<User> users;

  final List categories = [
    {"name": "Salate", "imageName": "salad.jpeg", "newRecipeTitle": "Neuer Salat"},
    {"name": "Hauptgerichte", "imageName": "hauptgerichte.jpg", "newRecipeTitle": "Neues Hauptgericht"},
    {"name": "Brote", "imageName": "brote.jpg", "newRecipeTitle": "Neues Brot"},
    {"name": "Süßspeisen", "imageName": "sweets.jpg", "newRecipeTitle": "Neue Süßspeise"},
    {"name": "Getränke", "imageName": "drinks.jpg", "newRecipeTitle": "Neues Getränk"},
    {"name": "Sonstiges", "imageName": "sonstiges.jpg", "newRecipeTitle": "Neues Rezept"},
  ];

  Future<String> getSelectedUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('userId');
    User? user = users.firstWhere((it) => it.id == id);
    return user.name;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<String>(
                    future: getSelectedUsername(),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ausgewählter Nutzer:"),
                            SizedBox(width: 30),
                            Flexible(
                              child: DropdownButtonFormField(
                                value: snapshot.data,
                                icon: const Icon(Icons.expand_more),
                                onChanged: (String? newValue) async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  User user = users.firstWhere((it) => it.name == newValue);
                                  prefs.setInt("userId", user.id);
                                },
                                items: users.map((it) => it.name).map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }),
                for (var category in categories)
                  Container(
                    padding: EdgeInsets.only(top: 30),
                    width: double.infinity,
                    height: 160,
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        splashColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          Navigator.pushNamed(context, '/recipes',
                              arguments: ScreenArguments(category: category["name"]));
                        },
                        child: Stack(
                          children: [
                            Ink.image(
                              image: AssetImage('assets/${category["imageName"]}'),
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.all(Radius.circular(10))),
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    category["name"],
                                    style: GoogleFonts.manrope(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).colorScheme.onPrimary),
                                  ),
                                )
                              ]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 90,
                )
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: 80.0,
              width: 80.0,
              child: PopupMenuButton<int>(
                color: Theme.of(context).colorScheme.surfaceDim,
                itemBuilder: (context) => [
                  for (var i = 0; i < categories.length; i++)
                    PopupMenuItem(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/newRecipe',
                          arguments: ScreenArguments(
                              category: categories[i]["name"], newRecipeTitle: categories[i]["newRecipeTitle"]),
                        );
                      },
                      child: Column(children: [
                        Container(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Text(
                            categories[i]["name"],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ]),
                    ),
                ],
                offset: Offset(-10, -300),
                icon: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: ShapeDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      )),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
