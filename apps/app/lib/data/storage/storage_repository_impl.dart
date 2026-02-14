import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StorageRepository {
  Future<String> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  });

  Future<Uint8List> download({required String bucket, required String path});

  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  });
}

class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<String> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final uploadedPath = await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return uploadedPath;
  }

  @override
  Future<Uint8List> download({required String bucket, required String path}) {
    return _client.storage.from(bucket).download(path);
  }

  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) {
    return _client.storage.from(bucket).createSignedUrl(path, expiresInSeconds);
  }
}
