import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class SupabasePostsService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final NotificationService _notificationService;

  List<PostModel> _posts = [];
  bool _isLoading = false;
  RealtimeChannel? _postsChannel;

  // Track post IDs that have already triggered an FCM topic send from this client
  final Set<String> _fcmSentPostIds = {};

  SupabasePostsService({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? PlaceholderNotificationService();

  List<PostModel> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;

  /// Initialize real-time streaming of posts
  Future<void> initializePostsStream() async {
    _isLoading = true;
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // First, load existing posts
      final response = await _client
          .from('posts')
          .select()
          .order('createdat', ascending: false);

      final rows = response as List<dynamic>;
      _posts =
          rows
              .map((row) => PostModel.fromMap(row as Map<String, dynamic>))
              .toList();

      // Set up real-time subscription
      _postsChannel =
          _client
              .channel('posts_channel')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'posts',
                callback: (payload) => _handleRealtimeChange(payload),
              )
              .subscribe();
    } catch (e) {
      // Handle error silently in production
    } finally {
      _isLoading = false;
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Handle real-time changes to posts
  void _handleRealtimeChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          final newPost = PostModel.fromMap(payload.newRecord);
          _posts.insert(0, newPost);

          // Avoid sending the same FCM topic message multiple times from this client
          if (newPost.id.isNotEmpty && !_fcmSentPostIds.contains(newPost.id)) {
            _fcmSentPostIds.add(newPost.id);
            _notificationService.sendNewPostNotification(newPost);
          }
          break;
        case PostgresChangeEvent.update:
          final updatedPost = PostModel.fromMap(payload.newRecord);
          final index = _posts.indexWhere((p) => p.id == updatedPost.id);
          if (index != -1) {
            _posts[index] = updatedPost;
          }
          break;
        case PostgresChangeEvent.delete:
          final deletedId = payload.oldRecord['id'] as String;
          _posts.removeWhere((p) => p.id == deletedId);
          break;
        case PostgresChangeEvent.all:
          break;
      }
      notifyListeners();
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Load all posts, newest first (legacy method for refresh)
  Future<void> loadPosts() async {
    await initializePostsStream();
  }

  /// Reset the service (clear data and unsubscribe)
  void reset() {
    _postsChannel?.unsubscribe();
    _postsChannel = null;
    _posts.clear();
    _isLoading = false;
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _postsChannel?.unsubscribe();
    super.dispose();
  }

  /// Create a new post
  Future<bool> createPost({
    required String description,
    String? mediaUrl,
    required UserModel user,
  }) async {
    try {
      final data = {
        'description': description,
        'mediaUrl': mediaUrl,
        'createdBy': user.id, // user.id must be a UUID string
        'createdByName': user.name,
        'createdByAvatar': user.profileImageUrl,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final inserted =
          await _client.from('posts').insert(data).select().single();

      final saved = PostModel.fromMap(inserted);
      _posts.insert(0, saved);

      // Mark this post id as already triggering an FCM send so the realtime insert doesn't duplicate
      if (saved.id.isNotEmpty) {
        _fcmSentPostIds.add(saved.id);
      }

      // Send notification for the new post
      _notificationService.sendNewPostNotification(saved);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
