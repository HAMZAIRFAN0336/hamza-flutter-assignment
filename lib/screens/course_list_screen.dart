import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';
import 'course_form_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Optimistic delete — UI updates instantly inside the provider.
    final success = await context.read<CourseProvider>().deleteCourse(course.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Course deleted.'
                : 'Delete failed — restored (${context.read<CourseProvider>().errorMessage})',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _openForm(BuildContext context, {Course? course}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseFormScreen(existingCourse: course)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<CourseProvider>().fetchCourses(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Offline banner ────────────────────────────────────────
              if (provider.isOffline && provider.courses.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off,
                          size: 16, color: Colors.orange.shade900),
                      const SizedBox(width: 8),
                      Text(
                        'You\'re offline — showing saved data',
                        style: TextStyle(
                            color: Colors.orange.shade900, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // ── Main content ───────────────────────────────────────────
              Expanded(child: _buildBody(context, provider, colorScheme, textTheme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CourseProvider provider,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // ── Loading ────────────────────────────────────────────────────────
    if (provider.isLoading && provider.courses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading courses…'),
          ],
        ),
      );
    }

    // ── Error (no cached data at all) ─────────────────────────────────
    if (provider.state == ViewState.error && provider.courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Something went wrong', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => provider.fetchCourses(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty (no error, just nothing there) ──────────────────────────
    if (provider.state == ViewState.empty || provider.courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No courses yet.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openForm(context),
              child: const Text('Add First Course'),
            ),
          ],
        ),
      );
    }

    // ── Success — list with pull-to-refresh ───────────────────────────
    return RefreshIndicator(
      onRefresh: () => provider.refreshCourses(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: provider.courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final course = provider.courses[index];
          return Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                child: Text(
                  '#${course.id}',
                  style:
                      const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                course.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                course.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit',
                    onPressed: () => _openForm(context, course: course),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context, course),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: course),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
