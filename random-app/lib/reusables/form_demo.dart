import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FormInputsDemoPage(),
  ));
}

/// A page that hosts the form gallery.
class FormInputsDemoPage extends StatelessWidget {
  const FormInputsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Inputs Gallery')),
      body: const SafeArea(child: FormInputsShowcase()),
    );
  }
}

/// The form inputs showcase widget.
class FormInputsShowcase extends StatefulWidget {
  const FormInputsShowcase({super.key});

  @override
  State<FormInputsShowcase> createState() => _FormInputsShowcaseState();
}

class _FormInputsShowcaseState extends State<FormInputsShowcase> {
  // Form
  final _formKey = GlobalKey<FormState>();

  // Text inputs
  final _nameCtrl = TextEditingController(text: '');
  final _emailCtrl = TextEditingController(text: '');
  final _passwordCtrl = TextEditingController(text: '');
  final _phoneCtrl = TextEditingController(text: '');
  final _numberCtrl = TextEditingController(text: '');
  final _multilineCtrl = TextEditingController(text: '');

  // Choice inputs
  bool _agree = false;
  bool _notify = true;
  int? _radioChoice = 1;
  String? _dropdownValue = 'Option A';

  // Toggle buttons (multi-select)
  final List<bool> _toggleSelections = [true, false, false];
  final List<String> _toggleLabels = ['Bold', 'Italic', 'Underline'];

  // Chips
  final List<String> _chipOptions = ['Alpha', 'Beta', 'Gamma', 'Delta'];
  String? _choiceChip = 'Alpha';
  final Set<String> _filterChips = {'Beta'};

  // Ranges
  double _sliderValue = 30;
  RangeValues _rangeValues = const RangeValues(20, 80);

  // Pickers
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Autocomplete data
  static const _cities = <String>[
    'Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Depok', 'Malang', 'Madiun',
    'Yogyakarta', 'Semarang', 'Denpasar', 'Makassar',
  ];
  String? _selectedCity;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _numberCtrl.dispose();
    _multilineCtrl.dispose();
    super.dispose();
    // Note: If you add FocusNodes, dispose them here as well.
  }

  String _formatDate(DateTime? d) =>
      d == null ? 'Select date' : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay? t) =>
    t == null ? 'Select time' : t.format(context);

  void _reset() {
    setState(() {
      _nameCtrl.text = '';
      _emailCtrl.text = '';
      _passwordCtrl.text = '';
      _phoneCtrl.text = '';
      _numberCtrl.text = '';
      _multilineCtrl.text = '';

      _agree = false;
      _notify = true;
      _radioChoice = 1;
      _dropdownValue = 'Option A';

      _toggleSelections.setAll(0, [true, false, false]);
      _choiceChip = 'Alpha';
      _filterChips
        ..clear()
        ..add('Beta');

      _sliderValue = 30;
      _rangeValues = const RangeValues(20, 80);

      _selectedDate = null;
      _selectedTime = null;

      _selectedCity = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TEXT INPUTS
          _sectionTitle('Text inputs'),
          _card([
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Your full name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                return emailRx.hasMatch(v) ? null : 'Enter a valid email';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '+62 812 3456 7890',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberCtrl,
              decoration: const InputDecoration(
                labelText: 'Number',
                hintText: 'Numeric input',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _multilineCtrl,
              decoration: const InputDecoration(
                labelText: 'Multiline notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
            ),
          ]),

          // CHOICES
          _sectionTitle('Choices'),
          _card([
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    value: 1,
                    groupValue: _radioChoice,
                    title: const Text('Radio A'),
                    onChanged: (v) => setState(() => _radioChoice = v),
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    value: 2,
                    groupValue: _radioChoice,
                    title: const Text('Radio B'),
                    onChanged: (v) => setState(() => _radioChoice = v),
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              title: const Text('I agree to the terms'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SwitchListTile(
              value: _notify,
              onChanged: (v) => setState(() => _notify = v),
              title: const Text('Enable notifications'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _dropdownValue,
              items: const [
                DropdownMenuItem(value: 'Option A', child: Text('Option A')),
                DropdownMenuItem(value: 'Option B', child: Text('Option B')),
                DropdownMenuItem(value: 'Option C', child: Text('Option C')),
              ],
              onChanged: (v) => setState(() => _dropdownValue = v),
              decoration: const InputDecoration(
                labelText: 'Dropdown',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ToggleButtons(
                isSelected: _toggleSelections,
                onPressed: (index) {
                  setState(() => _toggleSelections[index] = !_toggleSelections[index]);
                },
                children: _toggleLabels.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(t),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: _chipOptions.map((label) {
                final selected = _choiceChip == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _choiceChip = label),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: _chipOptions.map((label) {
                final selected = _filterChips.contains(label);
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _filterChips.add(label);
                    } else {
                      _filterChips.remove(label);
                    }
                  }),
                );
              }).toList(),
            ),
          ]),

          // RANGES
          _sectionTitle('Ranges'),
          _card([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Slider: ${_sliderValue.toStringAsFixed(0)}'),
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _sliderValue.round().toString(),
                  onChanged: (v) => setState(() => _sliderValue = v),
                ),
                const SizedBox(height: 8),
                Text('Range: ${_rangeValues.start.toStringAsFixed(0)} — ${_rangeValues.end.toStringAsFixed(0)}'),
                RangeSlider(
                  values: _rangeValues,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labels: RangeLabels(
                    _rangeValues.start.round().toString(),
                    _rangeValues.end.round().toString(),
                  ),
                  onChanged: (v) => setState(() => _rangeValues = v),
                ),
              ],
            ),
          ]),

          // PICKERS
          _sectionTitle('Pickers'),
          _card([
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(_formatDate(_selectedDate)),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(_formatTime(_selectedTime)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
          ]),

          // AUTOCOMPLETE
          _sectionTitle('Autocomplete'),
          _card([
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _cities.where((c) =>
                    c.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (selection) => setState(() => _selectedCity = selection),
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                controller.text = _selectedCity ?? '';
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'Type to search',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ]),

          // ACTIONS
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form is valid ✅')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fix validation errors')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // CURRENT VALUES SUMMARY
          _sectionTitle('Current values'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${_nameCtrl.text}'),
                    Text('Email: ${_emailCtrl.text}'),
                    Text('Phone: ${_phoneCtrl.text}'),
                    Text('Number: ${_numberCtrl.text}'),
                    Text('Multiline: ${_multilineCtrl.text.replaceAll('\n', ' / ')}'),
                    Text('Password length: ${_passwordCtrl.text.length}'),
                    Text('Radio: ${_radioChoice ?? '-'}'),
                    Text('Agree: $_agree'),
                    Text('Notify: $_notify'),
                    Text('Dropdown: ${_dropdownValue ?? '-'}'),
                    Text('Toggles: ${[
                      for (var i = 0; i < _toggleLabels.length; i++)
                        if (_toggleSelections[i]) _toggleLabels[i]
                    ].join(', ')}'),
                    Text('Choice chip: ${_choiceChip ?? '-'}'),
                    Text('Filter chips: ${_filterChips.join(', ')}'),
                    Text('Slider: ${_sliderValue.toStringAsFixed(0)}'),
                    Text('Range: ${_rangeValues.start.toStringAsFixed(0)} — ${_rangeValues.end.toStringAsFixed(0)}'),
                    Text('Date: ${_formatDate(_selectedDate)}'),
                    Text('Time: ${_formatTime(_selectedTime)}'),
                    Text('City: ${_selectedCity ?? '-'}'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helpers to keep UI tidy
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

