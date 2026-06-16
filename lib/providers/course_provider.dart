import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/course_api_service.dart';

enum ViewState { idle, loading, success, error }

class CourseProvider extends ChangeNotifier {
  final CourseApiService _apiService = CourseApiService();

  // ─── State ─────────────────────────────────────────────────────────────────
  List<Course> _courses = [];
  ViewState _state = ViewState.idle;
  String _errorMessage = '';

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<Course> get courses => _courses;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  // ─── READ ──────────────────────────────────────────────────────────────────
  Future<void> fetchCourses() async {
    _setState(ViewState.loading);
    try {
      _courses = await _apiService.fetchCourses();
      _setState(ViewState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ─── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> addCourse({
    required String title,
    required String body,
  }) async {
    _setState(ViewState.loading);
    try {
      final newCourse = await _apiService.createCourse(
        title: title,
        body: body,
      );
      // JSONPlaceholder returns id=101 for all POSTs;
      // we prepend so it appears at the top of the list.
      _courses.insert(0, newCourse);
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ─── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> updateCourse(Course course) async {
    _setState(ViewState.loading);
    try {
      final updated = await _apiService.updateCourse(course);
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = updated;
      }
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ─── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> deleteCourse(int id) async {
    _setState(ViewState.loading);
    try {
      await _apiService.deleteCourse(id);
      _courses.removeWhere((c) => c.id == id);
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}
