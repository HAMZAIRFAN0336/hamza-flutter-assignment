import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class CourseApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _endpoint = '/posts';

  Future<List<Course>> fetchCourses() async {
    final response = await http
        .get(Uri.parse('$_baseUrl$_endpoint'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.take(1).map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses (${response.statusCode})');
    }
  }

  Future<Course> createCourse({
    required String title,
    required String body,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl$_endpoint'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create course (${response.statusCode})');
    }
  }

  Future<Course> updateCourse(Course course) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl$_endpoint/${course.id}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(course.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update course (${response.statusCode})');
    }
  }

  Future<void> deleteCourse(int id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl$_endpoint/$id'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete course (${response.statusCode})');
    }
  }
}
