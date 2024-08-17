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

}
