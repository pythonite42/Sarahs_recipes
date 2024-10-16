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

        var cmd = await db.prepare(
          'INSERT INTO recipe (name, category, quantity, quantity_name, instructions) values (?, ?, ?, ?, ?)',
        );
        await cmd.execute([recipe.name, recipe.category, recipe.quantity, recipe.quantityName, recipe.instructions]);
        await cmd.deallocate();
        var result = await db.execute('SELECT last_insert_id()');
        int? id;
        for (final row in result.rows) {
          //normal counting loop not possible because result.rows[i] throws error
          try {
            id = int.parse(row.assoc().values.first);
          } catch (_) {}
        }
        if (id == null) {
          return "Die Rezept Id konnte nicht ausgelesen werden. Die Zutaten wurden nicht gespeichert, das Rezept nur eventuell.";
        }
        var secondCmd = await db.prepare(
          'INSERT INTO ingredient (recipe_id, entry_number, amount, unit, name) values (?, ?, ?, ?, ?)',
        );
        for (final (i, ingredient) in recipe.ingredients.indexed) {
          await secondCmd.execute([id, i, ingredient.amount, ingredient.unit, ingredient.name]);
        }
        await secondCmd.deallocate();
        await SSH().uploadImage(recipe, id);
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

        List<String> recipeIds = [];
        for (final row in result.rows) {
          Map content = row.assoc();
          recipeIds.add(content["id"]);
        }
        var images = await SSH().downloadImages(recipeIds);
        var i = 0;
        for (final row in result.rows) {
          //normal counting loop not possible because result.rows[i] throws error
          Map content = row.assoc();
          recipesList.add(Recipe(content["name"], images[i], content["category"], content["quantity"],
              content["quantity_name"], [], content["instructions"]));
          i += 1;
        }
        return recipesList;
      });
    } catch (_) {
      return _.toString();
    }
  }
}
