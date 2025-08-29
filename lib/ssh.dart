import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sarahs_recipes/main.dart';

class SSH {
  // Reusable helper that opens/closes the SSH client for you
  Future<T?> _withSSH<T>(Future<T> Function(SSHClient client) action) async {
    final host = dotenv.env['SERVER_IP_ADDRESS'] ?? '';
    final port = int.tryParse(dotenv.env['SERVER_SSH_PORT'] ?? '') ?? 0;
    final username = dotenv.env['SERVER_USERNAME'] ?? '';
    final password = dotenv.env['SERVER_PASSWORD'] ?? '';

    SSHSocket? socket;
    SSHClient? client;
    try {
      socket = await SSHSocket.connect(host, port);
      client = SSHClient(
        socket,
        username: username,
        // For password auth:
        onPasswordRequest: () => password,
        // For key auth instead, use:
        // identities: [SSHKeyPair.fromPem(privateKeyPem, passphrase: 'optional')],
      );
      return await action(client);
    } catch (e, st) {
      debugPrint('SSH error: $e\n$st');
      return null;
    } finally {
      try {
        client?.close();
      } catch (_) {}
      try {
        await socket?.close();
      } catch (_) {}
    }
  }

  Future<String?> uploadImage(Recipe recipe, int recipeId) async {
    if (recipe.image == null) return null;

    return _withSSH<String?>((client) async {
      final sftp = await client.sftp();

      File file = recipe.image!;
      final dir = path.dirname(file.path);
      final newPath = path.join(dir, '$recipeId.jpg');
      if (file.path != newPath) {
        file = await file.rename(newPath);
      }

      final remotePath = 'sarahs_recipes_images/$recipeId.jpg';

      try {
        await sftp.remove(remotePath);
      } catch (_) {}

      final remote = await sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.truncate | SftpFileOpenMode.write,
      );
      try {
        final bytes = await file.readAsBytes();
        await remote.writeBytes(bytes);
      } finally {
        await remote.close();
      }

      return 'done';
    });
  }

  Future<List<File?>> downloadImages(List<String> recipeIds) async {
    final result = await _withSSH<List<File?>>((client) async {
      final sftp = await client.sftp();
      final files = <File?>[];

      for (final id in recipeIds) {
        final remotePath = 'sarahs_recipes_images/$id.jpg';
        try {
          final remote = await sftp.open(remotePath, mode: SftpFileOpenMode.read);
          final bytes = await remote.readBytes();
          await remote.close();

          final tmp = await getTemporaryDirectory();
          final localPath = path.join(tmp.path, '$id.jpg');
          final localFile = File(localPath);
          await localFile.writeAsBytes(bytes, flush: true);

          files.add(localFile);
        } catch (e) {
          debugPrint('Download failed for $remotePath: $e');
          files.add(null);
        }
      }

      return files;
    });

    return result ?? List<File?>.filled(recipeIds.length, null, growable: true);
  }
}
