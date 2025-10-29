import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  String _department = 'General Medicine';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: cs.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(labelText: 'Department'),
                items: const [
                  DropdownMenuItem(value: 'General Medicine', child: Text('General Medicine')),
                  DropdownMenuItem(value: 'Cardiology', child: Text('Cardiology')),
                  DropdownMenuItem(value: 'Orthopedics', child: Text('Orthopedics')),
                  DropdownMenuItem(value: 'Pediatrics', child: Text('Pediatrics')),
                ],
                onChanged: (v) => setState(() => _department = v ?? 'General Medicine'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.date_range),
                      label: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_time.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Appointment booked on ${dt.toString()} (${_department})')),
                    );
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirm Appointment'),
                  style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


