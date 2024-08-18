import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:sarahs_recipes/new_recipe.dart';

class MySQL {
  Future initializeDB(Function function) async {
    try {
      var db = await MySQLConnection.createConnection(
          host: 'REMOVED',
          port: REMOVED,
          userName: 'REMOVED',
          password: 'REMOVED',
          databaseName: 'sarahs_recipes');
      await db.connect();
      var returnValue = await function(db);
      await db.close();
      return returnValue;
    } catch (_) {
      return _.toString();
    }
  }

  Future recipeEntry(Recipe recipe) async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }

        /* final image = await ImagePicker().pickImage(source: ImageSource.gallery);

        Uint8List? bytes = await image?.readAsBytes();
         String? base64Image = bytes != null ? base64Encode(bytes) : null; */
        Uint8List? test = recipe.image;
        String? base64Image = test != null ? base64Encode(test) : null;
        //String? base64Image = recipe.image != null ? base64Encode(recipe.image!) : null;

        var cmd = await db.prepare(
          'INSERT INTO recipe (name, image, category, instructions) values (?, ?, ?, ?)',
        );
        await cmd.execute([recipe.name, base64Image, recipe.category, recipe.instructions]);
        await cmd.deallocate();
        return true;
      });
    } catch (_) {
      return _.toString();
    }
  }

  Future getRecipes() async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }
        var result = await db.execute('SELECT * FROM recipe');

        List recipesList = [];

        for (final row in result.rows) {
          Map content = row.assoc();
          print(content);
          String? base64Image = content["image"];
          Uint8List? image = base64Image != null ? base64.decode(base64Image) : null;
          recipesList.add(Recipe(content["name"], image, content["category"], content["instructions"]));
        }
        return recipesList;
      });
    } catch (_) {
      return _.toString();
    }
  }
}
