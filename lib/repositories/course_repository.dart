import '../models/course_model.dart';
import '../services/course_api_service.dart';
import '../services/course_local_service.dart';
import '../services/connectivity_service.dart';

/// Result wrapper so the Provider knows whether data came fresh from
/// the network or from the offline cache — useful for showing a
/// "you're viewing offline data" banner if desired.
class CourseResult {
  final List<Course> courses;
  final bool fromCache;

  CourseResult({required this.courses, required this.fromCache});
}

/// The single source of truth for course data.
/// UI and State Management never talk to the API or Hive directly —
/// everything goes through this repository.
///
///   UI → Provider → Repository → ApiService / LocalService
class CourseRepository {
  final CourseApiService _apiService;
  final CourseLocalService _localService;
  final ConnectivityService _connectivityService;

  CourseRepository({
    CourseApiService? apiService,
    CourseLocalService? localService,
    ConnectivityService? connectivityService,
  })  : _apiService = apiService ?? CourseApiService(),
        _localService = localService ?? CourseLocalService(),
        _connectivityService = connectivityService ?? ConnectivityService();

  // ─── READ ──────────────────────────────────────────────────────────────
  /// Tries the network first. On success, caches the result locally.
  /// If offline (or the request fails), falls back to cached data.
  Future<CourseResult> getCourses() async {
    final online = await _connectivityService.isOnline;

    if (online) {
      try {
        final freshCourses = await _apiService.fetchCourses();
        await _localService.cacheCourses(freshCourses);
        return CourseResult(courses: freshCourses, fromCache: false);
      } catch (_) {
        // Network call failed even though "online" — fall back to cache.
        return _loadFromCacheOrThrow();
      }
    } else {
      return _loadFromCacheOrThrow();
    }
  }

  CourseResult _loadFromCacheOrThrow() {
    final cached = _localService.getCachedCourses();
    if (cached.isNotEmpty) {
      return CourseResult(courses: cached, fromCache: true);
    }
    throw Exception(
        'No internet connection and no cached data available.');
  }

  // ─── CREATE ────────────────────────────────────────────────────────────
  /// Creates on the API, then mirrors the result into local cache.
  /// Throws on failure so the Provider can decide how to handle UI state
  /// (no optimistic insert here since we need the server-assigned id).
  Future<Course> addCourse({
    required String title,
    required String body,
  }) async {
    final online = await _connectivityService.isOnline;
    if (!online) {
      throw Exception('Cannot add a course while offline.');
    }

    final newCourse = await _apiService.createCourse(title: title, body: body);
    await _localService.addCourse(newCourse);
    return newCourse;
  }

  // ─── UPDATE ────────────────────────────────────────────────────────────
  /// Optimistic update: caller updates UI immediately, then calls this.
  /// If the API call fails, throws — caller is responsible for rollback.
  Future<Course> updateCourse(Course course) async {
    final online = await _connectivityService.isOnline;
    if (!online) {
      throw Exception('Cannot update a course while offline.');
    }

    final updated = await _apiService.updateCourse(course);
    await _localService.updateCourse(updated);
    return updated;
  }

  // ─── DELETE ────────────────────────────────────────────────────────────
  /// Optimistic delete: caller removes from UI immediately, then calls this.
  /// If the API call fails, throws — caller is responsible for rollback.
  Future<void> deleteCourse(int id) async {
    final online = await _connectivityService.isOnline;
    if (!online) {
      throw Exception('Cannot delete a course while offline.');
    }

    await _apiService.deleteCourse(id);
    await _localService.deleteCourse(id);
  }
}
