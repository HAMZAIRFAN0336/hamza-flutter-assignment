import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class CourseApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _endpoint = '/posts'; // posts = courses

  // ─── READ: Fetch all courses ───────────────────────────────────────────────
  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse('$_baseUrl$_endpoint'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Limit to first 20 for usability
      return data.take(1).map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses (${response.statusCode})');
    }
  }

  // ─── READ: Fetch single course ─────────────────────────────────────────────
  Future<Course> fetchCourseById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl$_endpoint/$id'));

    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load course $id (${response.statusCode})');
    }
  }

  // ─── CREATE: Add a new course ──────────────────────────────────────────────
  Future<Course> createCourse({
    required String title,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_endpoint'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'title': title,
        'body': body,
        'userId': 1,
      }),
    );

    if (response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create course (${response.statusCode})');
    }
  }

  // ─── UPDATE: Edit an existing course (PUT) ─────────────────────────────────
  Future<Course> updateCourse(Course course) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$_endpoint/${course.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update course (${response.statusCode})');
    }
  }

  // ─── DELETE: Remove a course ───────────────────────────────────────────────
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl$_endpoint/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete course (${response.statusCode})');
    }
  }
}
