import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/medical_record.dart';
import '../Services/api_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String token;

  const MedicalRecordsScreen({
    super.key,
    required this.token,
  });

  @override
  State<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState
    extends State<MedicalRecordsScreen> {
  late Future<List<MedicalRecord>> _medicalRecordsFuture;

  @override
  void initState() {
    super.initState();
    _medicalRecordsFuture = _loadMedicalRecords();
  }

  Future<List<MedicalRecord>> _loadMedicalRecords() async {
    final response = await ApiService.get(
      '/mobile/student/medical-records',
      token: widget.token,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load medical records: '
        '${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (item) => MedicalRecord.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> _refreshRecords() async {
    setState(() {
      _medicalRecordsFuture = _loadMedicalRecords();
    });

    await _medicalRecordsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Medical Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<MedicalRecord>>(
        future: _medicalRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: _refreshRecords,
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshRecords,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32,
              ),
              children: [
                const Text(
                  'Your Health History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'View your recorded clinic visits and medical information.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                ...records.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: _MedicalRecordCard(
                      record: record,
                    ),
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

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;

  const _MedicalRecordCard({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.teal,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinic Visit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _formatDate(record.visitDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Divider(
              height: 1,
            ),

            const SizedBox(height: 20),

            _RecordField(
              icon: Icons.sick_outlined,
              label: 'Chief Complaint',
              value: record.chiefComplaint,
            ),

            _RecordField(
              icon: Icons.medical_services_outlined,
              label: 'Diagnosis',
              value: record.diagnosis,
            ),

            _RecordField(
              icon: Icons.medication_outlined,
              label: 'Medications',
              value: record.medications,
            ),

            _RecordField(
              icon: Icons.warning_amber_outlined,
              label: 'Allergies',
              value: record.allergies,
            ),

            _RecordField(
              icon: Icons.notes_outlined,
              label: 'Clinical Notes',
              value: record.clinicalNotes,
              showBottomPadding: false,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }
}

class _RecordField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool showBottomPadding;

  const _RecordField({
    required this.icon,
    required this.label,
    required this.value,
    this.showBottomPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomPadding ? 18 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.teal,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_information_outlined,
                size: 42,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Medical Records',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your clinic records will appear here '
              'when they become available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Unable to Load Records',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'We could not retrieve your medical records. '
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}