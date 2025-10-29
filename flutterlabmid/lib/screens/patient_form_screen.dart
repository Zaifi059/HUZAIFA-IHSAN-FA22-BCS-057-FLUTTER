import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../utils/file_storage.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;
  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _gender = 'Male';
  final _contact = TextEditingController();
  final _diagnosis = TextEditingController();
  final _notes = TextEditingController();
  final List<String> _files = [];
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (p != null) {
      _name.text = p.name;
      _age.text = p.age.toString();
      _gender = p.gender;
      _contact.text = p.contact;
      _diagnosis.text = p.diagnosis;
      _notes.text = p.notes;
      _files.addAll(p.filePaths);
      _imagePath = p.imagePath;
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (result == null) return;
    for (final f in result.files) {
      if (f.path == null) continue;
      final saved = await FileStorageService.saveFileToAppDir(File(f.path!));
      _files.add(saved);
    }
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final patient = Patient(
      id: widget.patient?.id,
      name: _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      gender: _gender,
      contact: _contact.text.trim(),
      diagnosis: _diagnosis.text.trim(),
      notes: _notes.text.trim(),
      filePaths: List.of(_files),
      imagePath: _imagePath,
    );
    Navigator.pop(context, patient);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image == null) return;
    final saved = await FileStorageService.saveFileToAppDir(File(image.path));
    setState(() => _imagePath = saved);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;
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
                        Text(
                          isEdit ? 'Edit Patient' : 'Add Patient',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Profile Avatar
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Hero(
                      tag: 'avatar_${widget.patient?.id ?? widget.patient?.name ?? 'new'}',
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: (_imagePath != null && _imagePath!.isNotEmpty) 
                            ? FileImage(File(_imagePath!)) 
                            : null,
                        child: (_imagePath == null || _imagePath!.isEmpty)
                            ? const Icon(Icons.camera_alt, color: Colors.white, size: 40)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Update Patient Info' : 'Create New Patient',
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
                        controller: _age,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Enter valid age';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contact,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Contact'),
                        validator: (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _diagnosis,
                        decoration: const InputDecoration(labelText: 'Diagnosis'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notes,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Add Files/Images'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondaryContainer,
                                foregroundColor: cs.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${_files.length} attached'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_files.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _files
                              .map((e) => Chip(
                                    label: Text(e.split('/').last),
                                    onDeleted: () {
                                      setState(() => _files.remove(e));
                                    },
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Create Patient',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


