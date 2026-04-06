import 'dart:typed_data';

import 'package:http/http.dart' as http;

class SupabaseStorageService {
  SupabaseStorageService({required this.supabaseUrl, required this.anonKey, required this.bucket});

  final String supabaseUrl;
  final String anonKey;
  final String bucket;

  static SupabaseStorageService fromDartDefines() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    const bucket = String.fromEnvironment('SUPABASE_BUCKET', defaultValue: 'designs');

    if (url.isEmpty || key.isEmpty) {
      throw StateError('SUPABASE_URL / SUPABASE_ANON_KEY manquants. Lance Flutter avec --dart-define.');
    }

    return SupabaseStorageService(supabaseUrl: url, anonKey: key, bucket: bucket);
  }

  Future<String> uploadDesignImage({
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final cleanBase = supabaseUrl.endsWith('/') ? supabaseUrl.substring(0, supabaseUrl.length - 1) : supabaseUrl;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = 'designs/$ts-$filename';

    final uri = Uri.parse('$cleanBase/storage/v1/object/$bucket/$path');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $anonKey',
        'apikey': anonKey,
        'Content-Type': contentType ?? 'application/octet-stream',
        'x-upsert': 'true',
      },
      body: bytes,
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return '$cleanBase/storage/v1/object/public/$bucket/$path';
    }

    throw Exception('Upload Supabase échoué (${res.statusCode}): ${res.body}');
  }
}
