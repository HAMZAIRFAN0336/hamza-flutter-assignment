import 'package:hive/hive.dart';
import '../models/course_model.dart';

/// Handles ONLY local storage operations via Hive.
/// Knows nothing about the network — that's the Repository's job.
class CourseLocalService {
  static const String boxName = 'coursesBox';

  Box<Course> get _box => Hive.box<Course>(boxName);

  /// Replace all locally cached courses with a fresh list (after a
  /// successful API fetch).
  Future<void> cacheCourses(List<Course> courses) async {
    await _box.clear();
    final Map<dynamic, Course> entries = {
      for (final c in courses) c.id: c,
    };
    await _box.putAll(entries);
  }

  /// Read whatever is currently cached (used when offline).
  List<Course> getCachedCourses() {
    return _box.values.toList();
  }

  Future<void> addCourse(Course course) async {
    await _box.put(course.id, course);
  }

  Future<void> updateCourse(Course course) async {
    await _box.put(course.id, course);
  }

  Future<void> deleteCourse(int id) async {
    await _box.delete(id);
  }

  bool get hasCachedData => _box.isNotEmpty;
}
