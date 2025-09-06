import 'package:flutter/material.dart';

class EqualizerSlider extends StatelessWidget {
  const EqualizerSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotatedBox(
          quarterTurns: -1,
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: 0,
            max: 100,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class FakeEqualizerSliders extends StatefulWidget {
  const FakeEqualizerSliders({super.key});

  @override
  State<FakeEqualizerSliders> createState() => _FakeEqualizerSlidersState();
}

class _FakeEqualizerSlidersState extends State<FakeEqualizerSliders> {
  final List<double> _values = List.generate(8, (_) => 50.0);
  final List<String> _bands = ['60Hz', '150Hz', '400Hz', '1kHz', '2.4kHz', '6kHz', '12kHz', '16kHz'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_values.length, (index) {
        return EqualizerSlider(
          label: _bands[index],
          value: _values[index],
          onChanged: (val) {
            setState(() {
              _values[index] = val;
              // No-op: placeholder for future DSP logic
            });
          },
        );
      }),
    );
  }
}

