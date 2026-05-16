import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.',
      );
    }
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  SupabaseClient get client => Supabase.instance.client;

  // ─── Auth ──────────────────────────────────────────────────────────────────
  User? get currentUser => client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ─── User Profile ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final data = await client
          .from('user_profiles')
          .select()
          .order('full_name', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  /// Creates a new user by calling a Supabase Edge Function (create-user)
  /// that uses the service role key server-side.
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await client.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.status == 200 || response.status == 201) {
        return {'success': true};
      } else {
        final data = response.data;
        final msg = data is Map
            ? (data['error'] ?? 'Gabim i panjohur')
            : 'Gabim i panjohur';
        return {'success': false, 'error': msg};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── Form Submissions ──────────────────────────────────────────────────────
  Future<String?> submitForm({
    required Map<String, dynamic> formData,
    required List<String> photoUrls,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'Nuk jeni i kyçur';

      final profile = await getCurrentUserProfile();
      final submitterName = profile?['full_name'] ?? user.email ?? '';

      await client.from('form_submissions').insert({
        'submitted_by': user.id,
        'submitter_name': submitterName,
        'work_order': formData['work_order'],
        'submitted_at': DateTime.now().toIso8601String(),
        'work_types': formData['work_types'],
        'activities': formData['activities'],
        'ppe_checklist': formData['ppe_checklist'],
        'employees': formData['employees'],
        'suspension_reason': formData['suspension_reason'],
        'photo_urls': photoUrls,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getMySubmissions() async {
    try {
      final user = currentUser;
      if (user == null) return [];
      // Explicitly filter by submitted_by as double safety (RLS also enforces this)
      final data = await client
          .from('form_submissions')
          .select()
          .eq('submitted_by', user.id)
          .order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllSubmissions() async {
    try {
      final data = await client
          .from('form_submissions')
          .select()
          .order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  // ─── Storage ───────────────────────────────────────────────────────────────

  /// Ensures the form-photos bucket exists and is public.
  Future<void> _ensureBucketExists() async {
    try {
      final buckets = await client.storage.listBuckets();
      final exists = buckets.any((b) => b.id == 'form-photos');
      if (!exists) {
        await client.storage.createBucket(
          'form-photos',
          const BucketOptions(public: true, fileSizeLimit: '10MB'),
        );
      }
    } catch (_) {
      // Bucket may already exist or creation may fail due to permissions;
      // proceed anyway — the upload will surface any real error.
    }
  }

  Future<String?> uploadPhoto(String filePath, List<int> bytes) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      // Ensure bucket exists before uploading
      await _ensureBucketExists();

      final ext = filePath.contains('.')
          ? filePath.split('.').last.toLowerCase()
          : 'jpg';
      final safeExt =
          ['jpg', 'jpeg', 'png', 'webp', 'gif', 'heic', 'heif'].contains(ext)
          ? ext
          : 'jpg';
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$safeExt';

      await client.storage
          .from('form-photos')
          .uploadBinary(
            fileName,
            Uint8List.fromList(bytes),
            fileOptions: const FileOptions(upsert: true),
          );

      // Always use public URL — bucket is set to public
      final publicUrl = client.storage
          .from('form-photos')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  /// Refreshes photo URLs for a submission — converts any expired signed URLs
  /// to fresh public URLs based on the stored file path.
  List<String> refreshPhotoUrls(List<dynamic> rawUrls) {
    return rawUrls
        .map((url) {
          final urlStr = url?.toString() ?? '';
          if (urlStr.isEmpty) return urlStr;
          // If it's already a public URL (contains /object/public/), return as-is
          if (urlStr.contains('/object/public/')) return urlStr;
          // If it's a signed URL, extract the file path and rebuild as public URL
          try {
            final uri = Uri.parse(urlStr);
            final pathSegments = uri.pathSegments;
            // Signed URL path: /storage/v1/object/sign/form-photos/<userId>/<file>
            final signIdx = pathSegments.indexOf('sign');
            if (signIdx != -1 && signIdx + 1 < pathSegments.length) {
              final bucketAndFile = pathSegments.sublist(signIdx + 1).join('/');
              return '$supabaseUrl/storage/v1/object/public/$bucketAndFile';
            }
          } catch (_) {}
          return urlStr;
        })
        .where((u) => u.isNotEmpty)
        .toList();
  }
}
