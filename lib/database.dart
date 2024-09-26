import 'package:mysql_client/mysql_client.dart';
import 'package:sarahs_recipes/new_recipe.dart';
import 'package:sarahs_recipes/ssh.dart';

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
        await SSH().uploadImage(recipe);
        var cmd = await db.prepare(
          'INSERT INTO recipe (name, category, instructions) values (?, ?, ?)',
        );
        await cmd.execute([recipe.name, recipe.category, recipe.instructions]);
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

        List<String> recipeNames = [];
        for (final row in result.rows) {
          Map content = row.assoc();
          recipeNames.add(content["name"]);
        }
        var images = await SSH().downloadImages(recipeNames);
        var i = 0;
        for (final row in result.rows) {
          //normal counting loop not possible because result.rows[i] throws error
          Map content = row.assoc();
          print(content);
          recipesList.add(Recipe(content["name"], images[i], content["category"], content["instructions"]));
          i += 1;
        }
        return recipesList;
      });
    } catch (_) {
      return _.toString();
    }
  }
}
