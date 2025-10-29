import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../db/db_helper.dart';
import '../models/patient.dart';
import 'patient_form_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final DbHelper _db = DbHelper();
  late Patient _patient;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Patient?>(
      context,
      MaterialPageRoute(builder: (_) => PatientFormScreen(patient: _patient)),
    );
    if (updated != null) {
      await _db.updatePatient(updated);
      setState(() => _patient = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _patient;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          // Blue Header Section
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Patient Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _edit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Profile Avatar
                  Hero(
                    tag: 'avatar_${p.id ?? p.name}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: (p.imagePath != null && p.imagePath!.isNotEmpty)
                          ? FileImage(File(p.imagePath!))
                          : null,
                      child: (p.imagePath == null || p.imagePath!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.gender}, ${p.age} • ${p.contact}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Curved Bottom Border
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diagnosis Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diagnosis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.diagnosis.isEmpty ? 'No diagnosis recorded' : p.diagnosis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Patient Information
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard('Name', p.name),
                    _buildInfoCard('Age', '${p.age}'),
                    _buildInfoCard('Gender', p.gender),
                    _buildInfoCard('Contact', p.contact),
                    const SizedBox(height: 16),
                    // Notes Section
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Text(
                        p.notes.isEmpty ? 'No notes recorded' : p.notes,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Attachments Section
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (p.filePaths.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outline),
                        ),
                        child: const Text(
                          'No attachments',
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      ...p.filePaths.map((path) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outline),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(path.split('/').last),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => OpenFilex.open(path),
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}


