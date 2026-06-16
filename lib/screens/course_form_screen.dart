import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';

class CourseFormScreen extends StatefulWidget {
  /// Pass an existing course to enter "Edit" mode; null = "Add" mode.
  final Course? existingCourse;

  const CourseFormScreen({super.key, this.existingCourse});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool get _isEditing => widget.existingCourse != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing an existing course
    _titleController =
        TextEditingController(text: widget.existingCourse?.title ?? '');
    _bodyController =
        TextEditingController(text: widget.existingCourse?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CourseProvider>();
    bool success;

    if (_isEditing) {
      // UPDATE — keep original id and userId
      final updated = widget.existingCourse!.copyWith(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      success = await provider.updateCourse(updated);
    } else {
      // CREATE
      success = await provider.addCourse(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? _isEditing
                  ? 'Course updated successfully!'
                  : 'Course added successfully!'
              : 'Operation failed. Please try again.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Title field ────────────────────────────────────────
                  TextFormField(
                    controller: _titleController,
                    enabled: !provider.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Course Title *',
                      hintText: 'e.g. Introduction to Flutter',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Title must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Description field ──────────────────────────────────
                  TextFormField(
                    controller: _bodyController,
                    enabled: !provider.isLoading,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Describe what this course covers…',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Submit button ──────────────────────────────────────
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _submit,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(
                        provider.isLoading
                            ? 'Please wait…'
                            : _isEditing
                                ? 'Save Changes'
                                : 'Add Course',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  // ── Error banner ───────────────────────────────────────
                  if (provider.state == ViewState.error) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
