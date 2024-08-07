import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarahs Recipes',
      themeMode: ThemeMode.light,
      theme: GlobalThemData.lightThemeData,
      darkTheme: GlobalThemData.darkThemeData,
      home: const MyHomePage(title: 'Sarahs Recipes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List catgories = [
    {"name": "Salate", "imageName": "salad.jpeg"},
    {"name": "Hauptgerichte", "imageName": "hauptgerichte.jpg"},
    {"name": "Brote", "imageName": "brote.jpg"},
    {"name": "Süßspeisen", "imageName": "sweets.jpg"},
    {"name": "Getränke", "imageName": "drinks.jpg"},
    {"name": "Sonstiges", "imageName": "sonstiges.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        centerTitle: true,
        title: Text(widget.title, style: GoogleFonts.indieFlower(fontSize: 30)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            for (var category in catgories)
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
                    onTap: () {},
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Neues Rezept',
        child: Icon(Icons.add),
      ),
    );
  }
}
