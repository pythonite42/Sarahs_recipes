import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ssh2/ssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'new_recipe.dart';

class SSH {
  Future<dynamic> initSSH(Function execute) async {
    var client = SSHClient(
      host: "REMOVED",
      port: REMOVED,
      username: REMOVED,
      passwordOrKey: "REMOVED",
    );
    try {
      var result = await client.connect() ?? 'Null result';
      List<File?>? executeResult;
      if (result == "session_connected") {
        executeResult = await execute(client);
      }
      await client.disconnect();
      return executeResult;
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  uploadImage(Recipe recipe, int recipeId) {
    if (recipe.image != null) {
      initSSH((SSHClient client) async {
        String result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          File file = recipe.image!;
          String dir = path.dirname(file.path);
          String newPath = path.join(dir, '$recipeId.jpg');
          file = file.renameSync(newPath);
          try {
            await client.sftpRm("sarahs_recipes_images/$recipeId.jpg");
          } catch (_) {}
          try {
            await client.sftpUpload(
              path: file.path,
              toPath: "sarahs_recipes_images",
              callback: (progress) async {
                //if (progress == 30) await client.sftpCancelUpload();
              },
            );
          } catch (_) {
            debugPrint(_.toString());
          }
        }
      });
      return "done";
    }
  }

  Future<List<File?>> downloadImages(List<String> recipeIds) async {
    List<File?>? returnVal = await initSSH((SSHClient client) async {
      List<File?> returnValue = [];
      String result = await client.connectSFTP() ?? 'Null result';
      if (result == "sftp_connected") {
        for (final recipeId in recipeIds) {
          try {
            Directory tempDir = await getTemporaryDirectory();
            String newPath = path.join(tempDir.path, '$recipeId.jpg');
            await client.sftpDownload(
              path: "sarahs_recipes_images/$recipeId.jpg",
              toPath: newPath,
              callback: (progress) async {
                //if (progress == 20) await client.sftpCancelDownload();
              },
            );
            File file = File(newPath);
            returnValue.add(file);
          } catch (_) {
            debugPrint(_.toString());
            returnValue.add(null);
          }
        }

        return returnValue;
      }
    });
    return returnVal ?? List<File?>.filled(recipeIds.length, null, growable: true);
  }
}
