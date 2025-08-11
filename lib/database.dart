import 'package:mysql_client/mysql_client.dart';
import 'package:sarahs_recipes/main.dart';
import 'package:sarahs_recipes/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MySQL {
  Future initializeDB(Function function) async {
    try {
      String host = dotenv.env['SERVER_IP_ADDRESS'] ?? "";
      int port = int.parse(dotenv.env['DATABASE_PORT'] ?? "0");
      String username = dotenv.env['DATABASE_USERNAME'] ?? "";
      String password = dotenv.env['DATABASE_PASSWORD'] ?? "";
      String databaseName = dotenv.env['DATABASE_NAME'] ?? "";
      var db = await MySQLConnection.createConnection(
          host: host, port: port, userName: username, password: password, databaseName: databaseName);
      await db.connect();
      var returnValue = await function(db);
      await db.close();
      return returnValue;
    } catch (_) {
      return _.toString();
    }
  }

  Future getUsers() async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }
        var result = await db.execute('SELECT * FROM user ORDER BY id ASC');
        List<User> users = [];
        for (final row in result.rows) {
          Map content = row.assoc();
          try {
            int id = int.parse(content["id"]);
            users.add(User(id, content["name"]));
          } catch (_) {}
        }
        return users;
      });
    } catch (_) {
      return _.toString();
    }
  }

  Future editEntry(Recipe recipe) async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }
        if (recipe.id == null) {
          return "Das Rezept hat keine ID und kann deshalb nicht verändert werden.";
        }
        var cmdUpdate = await db.prepare(
          'UPDATE recipe SET name=?, quantity=?, quantity_name=?, instructions=? WHERE id=?',
        );
        await cmdUpdate.execute([recipe.name, recipe.quantity, recipe.quantityName, recipe.instructions, recipe.id]);
        await cmdUpdate.deallocate();

        var cmdDelete = await db.prepare(
          'DELETE FROM ingredient WHERE recipe_id=?',
        );
        await cmdDelete.execute([recipe.id]);
        await cmdDelete.deallocate();

        var cmdInsert = await db.prepare(
          'INSERT INTO ingredient (recipe_id, entry_number, amount, unit, name) values (?, ?, ?, ?, ?)',
        );
        for (final ingredient in recipe.ingredients) {
          await cmdInsert
              .execute([recipe.id, ingredient.entryNumber, ingredient.amount, ingredient.unit, ingredient.name]);
        }
        await cmdInsert.deallocate();

        await SSH().uploadImage(recipe, recipe.id!);
        return true;
      });
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var selectedUserId = prefs.getInt('userId');
        var cmd = await db.prepare(
          'INSERT INTO recipe (name, category, quantity, quantity_name, instructions, user_id) values (?, ?, ?, ?, ?, ?)',
        );
        await cmd.execute(
            [recipe.name, recipe.category, recipe.quantity, recipe.quantityName, recipe.instructions, selectedUserId]);
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
        for (final ingredient in recipe.ingredients) {
          await secondCmd.execute([id, ingredient.entryNumber, ingredient.amount, ingredient.unit, ingredient.name]);
        }
        await secondCmd.deallocate();
        await SSH().uploadImage(recipe, id);
        return true;
      });
    } catch (_) {
      return _.toString();
    }
  }

  Future getRecipesByCategory(String category) async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var selectedUserId = prefs.getInt('userId');
        dynamic result;
        if (selectedUserId != 0) {
          result = await db.execute('SELECT * FROM recipe  WHERE category = :category and user_id = :user_id',
              {"category": category, "user_id": selectedUserId});
        } else {
          result = await db.execute('SELECT * FROM recipe  WHERE category = :category', {"category": category});
        }
        return sqlResultToRecipe(result);
      });
    } catch (_) {
      return _.toString();
    }
  }

  Future sqlResultToRecipe(dynamic result) async {
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
      double? quantity;
      try {
        quantity = double.parse(content["quantity"]);
      } catch (_) {}
      int? id;
      try {
        id = int.parse(content["id"]);
      } catch (_) {}
      recipesList.add(Recipe(id, content["name"], images[i], content["category"], quantity, content["quantity_name"],
          [], content["instructions"]));
      i += 1;
    }
    return recipesList;
  }

  Future getIngredientsById(int? recipeId) async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }
        var result = await db.execute('SELECT * FROM ingredient WHERE recipe_id = :recipeId', {"recipeId": recipeId});

        List ingredientsList = [];

        // ignore: unused_local_variable
        var i = 0;
        for (final row in result.rows) {
          //normal counting loop not possible because result.rows[i] throws error
          Map content = row.assoc();
          double? amount;
          try {
            amount = double.parse(content["amount"]);
          } catch (_) {}
          int? entryNumber;
          try {
            entryNumber = int.parse(content["entry_number"]);
          } catch (_) {}
          ingredientsList.add(Ingredient(entryNumber, amount, content["unit"], content["name"]));
          i += 1;
        }
        return ingredientsList;
      });
    } catch (_) {
      return _.toString();
    }
  }
}
