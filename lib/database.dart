import 'package:mysql_client/mysql_client.dart';

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

  Future recipeEntry() async {
    try {
      return await initializeDB((db) async {
        if (db.runtimeType == String) {
          return db;
        }

        var cmd = await db.prepare(
          'INSERT INTO recipe (name, image, category, instructions) values (?, ?, ?, ?)',
        );
        await cmd.execute(["Test", null, "Brote", "einfach backen"]);
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

        for (final row in result.rows) {
          Map content = row.assoc();
          print(content);
        }
        return null;
      });
    } catch (_) {
      return _.toString();
    }
  }
}
