import 'package:flutter/material.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  String _mode = 'Video';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
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
                value: _mode,
                decoration: const InputDecoration(labelText: 'Mode'),
                items: const [
                  DropdownMenuItem(value: 'Video', child: Text('Video')),
                  DropdownMenuItem(value: 'Audio', child: Text('Audio')),
                  DropdownMenuItem(value: 'In-person', child: Text('In-person')),
                ],
                onChanged: (v) => setState(() => _mode = v ?? 'Video'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Reason / Symptoms'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Consultation request submitted (${_mode})')),
                    );
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Request'),
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


