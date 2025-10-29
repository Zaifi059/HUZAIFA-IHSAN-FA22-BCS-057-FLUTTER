import 'dart:io';

import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../models/patient.dart';
import 'patient_form_screen.dart';
import 'patient_detail_screen.dart';
import 'consultation_screen.dart';
import 'appointment_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DbHelper _db = DbHelper();
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _patients = [];
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Simplified - just get patients
      final data = await _db.getAllPatients(query: _searchController.text)
          .timeout(const Duration(seconds: 3), onTimeout: () {
        print('DEBUG: Query timed out');
        return <Patient>[];
      });
      
      print('DEBUG: Loaded ${data.length} patients');
      
      if (!mounted) return;
      setState(() {
        _patients = data;
        _loading = false;
      });
    } catch (e) {
      print('DEBUG: Error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _patients = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          action: SnackBarAction(label: 'RETRY', onPressed: () => _load()),
        ),
      );
    }
  }

  Future<void> _delete(int id) async {
    await _db.deletePatient(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Blue Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: false,
            floating: false,
            snap: false,
            backgroundColor: const Color(0xFF1976D2),
            title: const Text('Patients', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () async {
                  await _db.resetDatabase();
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database reset with demo patients')),
                    );
                  }
                },
                tooltip: 'Reset with demo data',
              ),
              IconButton(
                icon: const Icon(Icons.clear_all, color: Colors.white),
                onPressed: () async {
                  await _db.clearDatabase();
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database cleared - refresh page to recreate')),
                    );
                  }
                },
                tooltip: 'Clear database (for web issues)',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.medical_services, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Student: Huzaifa Ihsan',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text('Reg: FA22-BCS-057', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Submitted to: Sir Abrar Sadiqque', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Course: Mobile App Development', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('COMSAT Vehari', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Curved white separator below banner
          SliverToBoxAdapter(
            child: Container(
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone',
                    hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor: cs.onSurface.withOpacity(0.8),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => _load(),
                ),
              ),
            ),
          ),

          // Services grid and section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildServiceCard(context, 'Add Patient', Icons.person_add, () async {
                        final created = await Navigator.push<Patient?>(context, MaterialPageRoute(builder: (_) => const PatientFormScreen()));
                        if (created != null) {
                          await _db.insertPatient(created);
                          _searchController.clear();
                          await _load();
                        }
                      }),
                      _buildServiceCard(context, 'Consultation', Icons.medical_services, () async {
                        final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const ConsultationScreen()));
                        if (ok == true && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation requested')));
                        }
                      }),
                      _buildServiceCard(context, 'Appointment', Icons.calendar_today, () async {
                        final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AppointmentScreen()));
                        if (ok == true && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment booked')));
                        }
                      }),
                      _buildServiceCard(context, 'Guide', Icons.help_outline, () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Emergency Doctors (Pakistan)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 12),
                  _EmergencyDoctorsStrip(),
                  const SizedBox(height: 20),
                  const Text('Recent Patients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Patients list / states
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_patients.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No patients found')),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = _patients[index];
                    return TweenAnimationBuilder<double>(
                      key: ValueKey('row_${p.id ?? p.name}_$index'),
                      duration: Duration(milliseconds: 240 + (index * 30).clamp(0, 240)),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 12),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Material(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Hero(
                                tag: 'avatar_${p.id ?? p.name}',
                                child: CircleAvatar(
                                  backgroundColor: cs.primaryContainer,
                                  backgroundImage: (p.imagePath != null && p.imagePath!.isNotEmpty)
                                      ? FileImage(File(p.imagePath!))
                                      : null,
                                  child: (p.imagePath == null || p.imagePath!.isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                              ),
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${p.gender}, ${p.age} • ${p.contact}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red.shade400),
                                onPressed: () => _delete(p.id!),
                              ),
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p)));
                                await _load();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                  childCount: _patients.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Consultation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: cs.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _EmergencyDoctorsStrip extends StatelessWidget {
  final List<Map<String, String>> _doctors = const [
    {
      'name': 'Dr. Ayesha Siddiqui',
      'specialty': 'Emergency Medicine',
      'hospital': 'Jinnah Hospital, Lahore',
      'city': 'Lahore',
      'phone': '+92 42 9923 1445'
    },
    {
      'name': 'Dr. Muhammad Usman',
      'specialty': 'Trauma & ER',
      'hospital': 'Agha Khan University Hospital',
      'city': 'Karachi',
      'phone': '+92 21 111 911 911'
    },
    {
      'name': 'Dr. Sara Khan',
      'specialty': 'Pediatrics ER',
      'hospital': 'Shifa International Hospital',
      'city': 'Islamabad',
      'phone': '+92 51 846 4646'
    },
    {
      'name': 'Dr. Hamza Rehman',
      'specialty': 'Cardiac Emergencies',
      'hospital': 'Punjab Institute of Cardiology',
      'city': 'Lahore',
      'phone': '+92 42 9920 3051'
    },
  ];

  const _EmergencyDoctorsStrip();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final d = _doctors[index];
          return Container(
            width: 260,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.local_hospital, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(d['specialty']!, style: TextStyle(color: cs.onSurface.withOpacity(0.8))),
                      const SizedBox(height: 4),
                      Text('${d['hospital']} • ${d['city']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.call, size: 16, color: cs.primary),
                          const SizedBox(width: 6),
                          Text(d['phone']!, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}