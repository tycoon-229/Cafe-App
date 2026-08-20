import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// ================= IMAGE =================

Future<String> uploadImage({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false,
}) async {
  await supabase.storage
      .from(bucket)
      .upload(
        path,
        image,
        fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
      );

  return supabase.storage.from(bucket).getPublicUrl(path);
}

Future<String> updateImage({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false,
}) async {
  await supabase.storage
      .from(bucket)
      .update(
        path,
        image,
        fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
      );

  return supabase.storage.from(bucket).getPublicUrl(path) +
      "?ts=${DateTime.now().millisecondsSinceEpoch}";
}

Future<void> removeImage({required String bucket, required String path}) async {
  await supabase.storage.from(bucket).remove([path]);
}

/// ================= STREAM =================

Stream<List<T>> getDataStream<T>({
  required String table,
  required List<String> ids,
  required T Function(Map<String, dynamic>) fromJson,
}) {
  return supabase
      .from(table)
      .stream(primaryKey: ids)
      .map((list) => list.map((e) => fromJson(e)).toList());
}

/// ================= MAP DATA =================

Future<Map<K, T>> getMapData<K, T>({
  required String table,
  required T Function(Map<String, dynamic>) fromJson,
  required K Function(T) getId,
}) async {
  final data = await supabase.from(table).select();

  List<T> list = (data as List).map((e) => fromJson(e)).toList();

  Map<K, T> maps = {for (var item in list) getId(item): item};

  return maps;
}

/// ================= REALTIME =================

listenDatachange<K, T>(
  Map<K, T> maps, {
  required String channel,
  required String schema,
  required String table,
  required T Function(Map<String, dynamic>) fromJson,
  required K Function(T) getId,
  Function()? updateUI,
}) {
  supabase
      .channel(channel)
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: schema,
        table: table,
        callback: (payload) {
          switch (payload.eventType) {
            case PostgresChangeEvent.insert:
            case PostgresChangeEvent.update:
              {
                final item = fromJson(payload.newRecord);
                maps[getId(item)] = item;
                updateUI?.call();
                break;
              }

            case PostgresChangeEvent.delete:
              {
                final id = payload.oldRecord["id"];
                maps.remove(id);
                updateUI?.call();
                break;
              }

            default:
              break;
          }
        },
      )
      .subscribe();
}
