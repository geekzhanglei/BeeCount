import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorite_image_service.dart';

/// Cross-device preferences and image data stored in the user's cloud profile.
/// Device identity, authentication, database IDs, and app-lock settings are
/// intentionally excluded.
class AppProfileSyncService {
  static const lastSyncHashKey = 'app_profile_sync_last_hash_v1';

  static const _preferenceKeys = <String>{
    'fontScaleLevel',
    'customFontScale',
    'selected_language',
    'selected_language_country',
    'hideAmounts',
    'assetTrendView',
    'home_budget_card_enabled',
    'attachmentKeepOriginal',
    'smartBillingAutoTags',
    'smartBillingAutoAttachment',
    'search_amount_filter_enabled',
    'account_feature_enabled',
    'reminder_enabled',
    'reminder_hour',
    'reminder_minute',
  };

  static Future<Map<String, dynamic>> snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, dynamic>{};
    for (final key in _preferenceKeys) {
      final value = prefs.get(key);
      if (value is bool || value is int || value is double || value is String) {
        values[key] = value;
      } else if (value is List<String>) {
        values[key] = value;
      }
    }
    final images = <Map<String, String>>[];
    for (final file in await FavoriteImageService.list()) {
      var bytes = await file.readAsBytes();
      if (bytes.length > 512 * 1024) {
        try {
          final compressed = await FlutterImageCompress.compressWithFile(
            file.path,
            minWidth: 1280,
            minHeight: 1280,
            quality: 72,
            format: CompressFormat.jpeg,
          );
          if (compressed != null && compressed.isNotEmpty) bytes = compressed;
        } catch (_) {
          // Preserve the original bytes if an image format cannot be decoded.
        }
      }
      images.add({
        'name': file.uri.pathSegments.last,
        'data': base64Encode(bytes),
      });
    }
    return {'values': values, 'favorite_images': images};
  }

  static String hash(Map<String, dynamic> snapshot) =>
      sha256.convert(utf8.encode(jsonEncode(snapshot))).toString();

  static Future<void> apply(Map<String, dynamic> snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final values = snapshot['values'];
    if (values is Map) {
      for (final entry in values.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || !_preferenceKeys.contains(key)) continue;
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List && value.every((item) => item is String)) {
          await prefs.setStringList(key, value.cast<String>());
        }
      }
    }
    final images = snapshot['favorite_images'];
    if (images is List) {
      await FavoriteImageService.replaceFromSync(images);
    }
  }
}
