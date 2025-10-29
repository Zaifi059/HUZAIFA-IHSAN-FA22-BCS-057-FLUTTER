import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/patient.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  // File-based storage (non-web), in-memory fallback (web)
  static const String _fileName = 'patients.json';
  List<Patient> _cache = [];
  bool _initialized = false;

  Future<void> _initStorageIfNeeded() async {
    if (_initialized) return;
    if (kIsWeb) {
      // Simple in-memory seed for web runtime
      _cache = _seedPatients();
      _initialized = true;
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _fileName));
    if (!await file.exists()) {
      _cache = _seedPatients();
      await _saveToFile(file, _cache);
    } else {
      final text = await file.readAsString();
      final decoded = (jsonDecode(text) as List<dynamic>?) ?? <dynamic>[];
      _cache = decoded
          .map((e) => Patient.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
    }
    _initialized = true;
  }

  List<Patient> _seedPatients() {
    return const [
      Patient(name: 'John Doe', age: 35, gender: 'Male', contact: '0300-1234567', diagnosis: 'Flu', notes: 'Rest and fluids', filePaths: [], imagePath: null),
      Patient(name: 'Ayesha Khan', age: 29, gender: 'Female', contact: '0333-9876543', diagnosis: 'Migraine', notes: 'Prescribed pain relief', filePaths: [], imagePath: null),
      Patient(name: 'Ahmed Ali', age: 42, gender: 'Male', contact: '0301-5551234', diagnosis: 'Diabetes Type 2', notes: 'Blood sugar monitoring required', filePaths: [], imagePath: null),
      Patient(name: 'Fatima Sheikh', age: 25, gender: 'Female', contact: '0332-7778889', diagnosis: 'Anemia', notes: 'Iron supplements prescribed', filePaths: [], imagePath: null),
      Patient(name: 'Muhammad Hassan', age: 38, gender: 'Male', contact: '0305-4445556', diagnosis: 'Hypertension', notes: 'Regular BP check needed', filePaths: [], imagePath: null),
      Patient(name: 'Sara Ahmed', age: 31, gender: 'Female', contact: '0345-6667778', diagnosis: 'Asthma', notes: 'Inhaler prescribed', filePaths: [], imagePath: null),
      Patient(name: 'Ali Raza', age: 45, gender: 'Male', contact: '0300-9990001', diagnosis: 'Heart Disease', notes: 'Cardiac monitoring', filePaths: [], imagePath: null),
      Patient(name: 'Zainab Malik', age: 27, gender: 'Female', contact: '0333-2223334', diagnosis: 'Thyroid Disorder', notes: 'Thyroid function tests', filePaths: [], imagePath: null),
    ]
        .asMap()
        .entries
        .map((e) => e.value.copyWith(id: e.key + 1))
        .toList();
  }

  Future<void> _saveToFile(File file, List<Patient> items) async {
    final jsonList = items.map((e) => e.toMap()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<File?> _getFileIfAny() async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<int> insertPatient(Patient patient) async {
    await _initStorageIfNeeded();
    final nextId = (_cache.map((e) => e.id ?? 0).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
    final created = patient.copyWith(id: nextId);
    _cache.insert(0, created);
    final file = await _getFileIfAny();
    if (file != null) await _saveToFile(file, _cache);
    return nextId;
  }

  Future<List<Patient>> getAllPatients({String? query}) async {
    await _initStorageIfNeeded();
    final q = query?.trim().toLowerCase() ?? '';
    List<Patient> items = List.of(_cache);
    if (q.isNotEmpty) {
      items = items.where((p) {
        return p.name.toLowerCase().contains(q) || p.contact.toLowerCase().contains(q);
      }).toList();
    }
    items.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return items;
  }

  Future<int> getPatientCount() async {
    await _initStorageIfNeeded();
    return _cache.length;
  }

  Future<int> updatePatient(Patient patient) async {
    await _initStorageIfNeeded();
    final idx = _cache.indexWhere((e) => e.id == patient.id);
    if (idx == -1) return 0;
    _cache[idx] = patient;
    final file = await _getFileIfAny();
    if (file != null) await _saveToFile(file, _cache);
    return 1;
  }

  Future<int> deletePatient(int id) async {
    await _initStorageIfNeeded();
    final before = _cache.length;
    _cache.removeWhere((e) => (e.id ?? -1) == id);
    final file = await _getFileIfAny();
    if (file != null) await _saveToFile(file, _cache);
    return before - _cache.length;
  }

  Future<void> resetDatabase() async {
    _cache = _seedPatients();
    final file = await _getFileIfAny();
    if (file != null) await _saveToFile(file, _cache);
    _initialized = true;
  }

  Future<void> clearDatabase() async {
    _cache = [];
    final file = await _getFileIfAny();
    if (file != null) {
      try {
        if (await file.exists()) {
          await file.writeAsString(jsonEncode(<dynamic>[]));
        }
      } catch (_) {}
    }
  }
}
