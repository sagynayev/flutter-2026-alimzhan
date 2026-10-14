import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../utils/format.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({this.initial, super.key});

  final StudySession? initial;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _changes = ValueNotifier<int>(0);

  late final StudySession _base;
  late final DateTime _initialWhen;
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();

  StudyCategory? _category;
  late bool _online;
  late DateTime _date;
  late TimeOfDay _time;
  bool _saving = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _base = widget.initial ?? StudySession.empty();
    _initialWhen = DateTime(
      _base.when.year,
      _base.when.month,
      _base.when.day,
      _base.when.hour,
      _base.when.minute,
    );
    _category = widget.initial?.category;
    _online = _base.online;
    _date = DateTime(_initialWhen.year, _initialWhen.month, _initialWhen.day);
    _time = TimeOfDay.fromDateTime(_initialWhen);
    _titleController = TextEditingController(text: _base.title);
    _placeController = TextEditingController(text: _base.place);
    _limitController = TextEditingController(text: _base.limit.toString());
    _descriptionController = TextEditingController(
      text: _base.description ?? '',
    );
    _dateController = TextEditingController(text: formatDate(_date));
    _timeController = TextEditingController(text: formatTime(_combinedDate));
    for (final controller in _controllers) {
      controller.addListener(_notifyTextChange);
    }
  }

  List<TextEditingController> get _controllers => [
    _titleController,
    _placeController,
    _limitController,
    _descriptionController,
    _dateController,
    _timeController,
  ];

  DateTime get _combinedDate =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  bool get _dirty =>
      _titleController.text != _base.title ||
      _placeController.text != _base.place ||
      _limitController.text != _base.limit.toString() ||
      _descriptionController.text != (_base.description ?? '') ||
      _category != widget.initial?.category ||
      _online != _base.online ||
      _combinedDate != _initialWhen;

  void _notifyTextChange() => _changes.value++;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _descriptionFocus.dispose();
    _dateFocus.dispose();
    _timeFocus.dispose();
    _changes.dispose();
    super.dispose();
  }

  String? _titleValidator(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) {
      return 'Enter at least 3 characters';
    }
    if (title.length > 60) {
      return 'Use no more than 60 characters';
    }
    return null;
  }

  String? _placeValidator(String? value) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) {
      return _online ? 'Meeting link is required' : 'Place is required';
    }
    if (_online && !place.contains('://')) {
      return 'Link must contain ://';
    }
    return null;
  }

  String? _limitValidator(String? value) {
    final limit = int.tryParse(value ?? '');
    if (limit == null || limit < 1 || limit > 500) {
      return 'Enter a number from 1 to 500';
    }
    if (limit < _base.count) {
      return 'Cannot be below the current count (${_base.count})';
    }
    return null;
  }

  String? _dateValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Choose a date and time';
    }
    if (widget.initial == null && !_combinedDate.isAfter(DateTime.now())) {
      return 'A new session must be in the future';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _date = selected;
      _dateController.text = formatDate(selected);
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _time = selected;
      _timeController.text = formatTime(_combinedDate);
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final category = _category;
    final limit = int.tryParse(_limitController.text);
    if (category == null || limit == null) {
      return;
    }

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    final description = _descriptionController.text.trim();
    final result = StudySession(
      id: _base.id,
      title: _titleController.text.trim(),
      category: category,
      when: _combinedDate,
      place: _placeController.text.trim(),
      limit: limit,
      participants: _base.participants,
      online: _online,
      description: description.isEmpty ? null : description,
      favourite: _base.favourite,
    );
    setState(() {
      _saving = false;
      _allowPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }

  Future<void> _handleBack(bool didPop) async {
    if (didPop) {
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && context.mounted) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  InputDecoration _decoration(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: _changes,
    builder: (context, value, child) => PopScope<StudySession>(
      canPop: !_dirty || _allowPop,
      onPopInvokedWithResult: (didPop, result) => _handleBack(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initial == null ? 'New session' : 'Edit session'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    decoration: _decoration('Title'),
                    maxLength: 60,
                    validator: _titleValidator,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<StudyCategory>(
                    initialValue: _category,
                    decoration: _decoration('Category'),
                    items: StudyCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Choose a category' : null,
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Online session'),
                    value: _online,
                    onChanged: (value) => setState(() => _online = value),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _placeController,
                    focusNode: _placeFocus,
                    decoration: _decoration(_online ? 'Meeting link' : 'Place'),
                    validator: _placeValidator,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _limitController,
                    focusNode: _limitFocus,
                    decoration: _decoration('Participant limit'),
                    keyboardType: TextInputType.number,
                    validator: _limitValidator,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          focusNode: _dateFocus,
                          readOnly: true,
                          decoration: _decoration('Date'),
                          validator: _dateValidator,
                          onTap: _pickDate,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _timeController,
                          focusNode: _timeFocus,
                          readOnly: true,
                          decoration: _decoration('Time'),
                          validator: _dateValidator,
                          onTap: _pickTime,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocus,
                    decoration: _decoration('Description (optional)'),
                    maxLines: 3,
                    validator: (value) => null,
                    textInputAction: TextInputAction.done,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
