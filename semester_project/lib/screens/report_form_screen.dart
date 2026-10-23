import 'package:flutter/material.dart';

enum ReportUiState { idle, loading, success, empty, error }

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  ReportUiState _uiState = ReportUiState.idle;
  bool _simulateFailure = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (_uiState == ReportUiState.loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uiState = ReportUiState.loading);
    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_simulateFailure) {
        throw Exception('Simulated submission failure');
      }
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _onFormChanged() {
    if (_uiState == ReportUiState.success || _uiState == ReportUiState.error) {
      setState(() => _uiState = ReportUiState.idle);
    }
  }

  void _showEmptyState() {
    setState(() => _uiState = ReportUiState.empty);
  }

  void _returnToForm() {
    setState(() => _uiState = ReportUiState.idle);
  }

  Future<void> _retryWithSimulationDisabled() async {
    setState(() {
      _simulateFailure = false;
      _uiState = ReportUiState.idle;
    });
    await submitReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cafe Issue Report')),
      body: _uiState == ReportUiState.empty
          ? _buildEmptyState()
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Report a cafe issue',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell us what needs attention at Nexus Net Cafe.',
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Issue title',
                            hintText: 'e.g. Workstation 04 cannot connect',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _uiState != ReportUiState.loading,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 80,
                          onChanged: (_) => _onFormChanged(),
                          validator: (value) {
                            final title = value?.trim() ?? '';
                            if (title.isEmpty) {
                              return 'Enter a short title for the issue.';
                            }
                            if (title.length < 3) {
                              return 'The title must be at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Issue category',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Select a category'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Computer or internet',
                              child: Text('Computer or internet'),
                            ),
                            DropdownMenuItem(
                              value: 'Payment or POS',
                              child: Text('Payment or POS'),
                            ),
                            DropdownMenuItem(
                              value: 'Cleanliness',
                              child: Text('Cleanliness'),
                            ),
                            DropdownMenuItem(
                              value: 'Safety',
                              child: Text('Safety'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: _uiState == ReportUiState.loading
                              ? null
                              : (value) {
                                  setState(() {
                                    _category = value;
                                  });
                                  _onFormChanged();
                                },
                          validator: (value) => value == null
                              ? 'Select an issue category.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location or workstation',
                            hintText: 'e.g. Workstation 04 or front counter',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _uiState != ReportUiState.loading,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => _onFormChanged(),
                          validator: (value) {
                            final location = value?.trim() ?? '';
                            if (location.isEmpty) {
                              return 'Enter where the issue is happening.';
                            }
                            if (location.length < 2) {
                              return 'Enter a valid cafe location.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Issue details',
                            hintText: 'Describe what happened or what needs attention.',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _uiState != ReportUiState.loading,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => _onFormChanged(),
                          validator: (value) {
                            final description = value?.trim() ?? '';
                            if (description.isEmpty) {
                              return 'Describe the issue.';
                            }
                            if (description.length < 10) {
                              return 'Add a few more details (at least 10 characters).';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildStatus(),
                        if (_uiState == ReportUiState.error) ...[
                          OutlinedButton(
                            onPressed: submitReport,
                            child: const Text('Retry submission'),
                          ),
                          TextButton(
                            onPressed: _retryWithSimulationDisabled,
                            child: const Text(
                              'Turn off simulated error and retry',
                            ),
                          ),
                        ],
                        FilledButton(
                          onPressed: _uiState == ReportUiState.loading
                              ? null
                              : submitReport,
                          child: Text(
                            _uiState == ReportUiState.loading
                                ? 'Submitting...'
                                : 'Submit Issue Report',
                          ),
                        ),
                        if (_uiState != ReportUiState.loading) ...[
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Simulate submission error'),
                            value: _simulateFailure,
                            onChanged: (value) {
                              setState(() {
                                _simulateFailure = value;
                                if (_uiState == ReportUiState.error) {
                                  _uiState = ReportUiState.idle;
                                }
                              });
                            },
                          ),
                          TextButton(
                            onPressed: _showEmptyState,
                            child: const Text('View reports'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatus() {
    switch (_uiState) {
      case ReportUiState.loading:
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Submitting issue report...'),
            ],
          ),
        );
      case ReportUiState.success:
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Demo success: the submission completed. No report was saved.',
            style: TextStyle(color: Colors.green),
          ),
        );
      case ReportUiState.error:
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Submission failed in the demo. You can retry or turn off the simulated error.',
            style: TextStyle(color: Colors.red),
          ),
        );
      case ReportUiState.idle:
      case ReportUiState.empty:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No cafe reports yet.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no report records to display in this demo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _returnToForm,
              child: const Text('Back to report form'),
            ),
          ],
        ),
      ),
    );
  }
}
