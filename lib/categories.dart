import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Categories extends StatelessWidget {
  Categories({super.key});

  final List categories = [
    {"name": "Salate", "imageName": "salad.jpeg"},
    {"name": "Hauptgerichte", "imageName": "hauptgerichte.jpg"},
    {"name": "Brote", "imageName": "brote.jpg"},
    {"name": "Süßspeisen", "imageName": "sweets.jpg"},
    {"name": "Getränke", "imageName": "drinks.jpg"},
    {"name": "Sonstiges", "imageName": "sonstiges.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (var category in categories)
            Container(
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
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
                    Navigator.pushNamed(context, '/recipes');
                  },
                  child: Stack(
                    children: [
                      Ink.image(
                        image: AssetImage('assets/${category["imageName"]}'),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  category["name"],
                                  style: GoogleFonts.manrope(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
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
    );
  }
}
