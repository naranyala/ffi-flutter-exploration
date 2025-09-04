import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BatteryTemperatureScreen(),
    );
  }
}

class BatteryTemperatureScreen extends StatefulWidget {
  @override
  _BatteryTemperatureScreenState createState() => _BatteryTemperatureScreenState();
}

class _BatteryTemperatureScreenState extends State<BatteryTemperatureScreen> {
  static const platform = MethodChannel('battery_temperature');
  String _batteryTemperature = 'Unknown';

  Future<void> _getBatteryTemperature() async {
    try {
      final int temperature = await platform.invokeMethod('getBatteryTemperature');
      setState(() {
        _batteryTemperature = '${temperature / 10.0} °C';
      });
    } catch (e) {
      setState(() {
        _batteryTemperature = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Battery Temperature')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Battery Temperature: $_batteryTemperature'),
            ElevatedButton(
              onPressed: _getBatteryTemperature,
              child: Text('Get Temperature'),
            ),
          ],
        ),
      ),
    );
  }
}

