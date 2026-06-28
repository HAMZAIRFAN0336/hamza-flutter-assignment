import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

enum ViewState { idle, loading, success, error, empty }

/// Pure UI state management. Holds no API or Hive logic itself —
/// it only calls into CourseRepository and reacts to the result.
class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

  // ─── State ─────────────────────────────────────────────────────────────
  List<Course> _courses = [];
  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  bool _isOffline = false;

  // ─── Getters ───────────────────────────────────────────────────────────
  List<Course> get courses => _courses;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isOffline => _isOffline;

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  // ─── READ ──────────────────────────────────────────────────────────────
  Future<void> fetchCourses() async {
    _setState(ViewState.loading);
    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.fromCache;
      _setState(_courses.isEmpty ? ViewState.empty : ViewState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// For pull-to-refresh — same as fetchCourses but kept as a separate,
  /// clearly-named method in case UI needs to distinguish later.
  Future<void> refreshCourses() => fetchCourses();

  // ─── CREATE ────────────────────────────────────────────────────────────
  /// Not optimistic — we need the server-assigned id before showing it,
  /// since JSONPlaceholder generates the id on its end.
  Future<bool> addCourse({
    required String title,
    required String body,
  }) async {
    _setState(ViewState.loading);
    try {
      final newCourse = await _repository.addCourse(title: title, body: body);
      _courses.insert(0, newCourse);
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ─── UPDATE (optimistic) ───────────────────────────────────────────────
  Future<bool> updateCourse(Course updatedCourse) async {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index == -1) return false;

    // 1. Snapshot the original in case we need to roll back.
    final original = _courses[index];

    // 2. Optimistically update the UI immediately.
    _courses[index] = updatedCourse;
    notifyListeners();

    // 3. Fire the real request in the background.
    try {
      final confirmed = await _repository.updateCourse(updatedCourse);
      _courses[index] = confirmed; // reconcile with server response
      notifyListeners();
      return true;
    } catch (e) {
      // 4. Rollback on failure.
      _courses[index] = original;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── DELETE (optimistic) ───────────────────────────────────────────────
  Future<bool> deleteCourse(int id) async {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    // 1. Snapshot before removing.
    final removedCourse = _courses[index];

    // 2. Optimistically remove from UI immediately.
    _courses.removeAt(index);
    notifyListeners();

    // 3. Fire the real request.
    try {
      await _repository.deleteCourse(id);
      return true;
    } catch (e) {
      // 4. Rollback — reinsert at original position.
      _courses.insert(index, removedCourse);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
