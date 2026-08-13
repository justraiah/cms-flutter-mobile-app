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

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map(
          (item) => MedicalRecord.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Unable to load medical records.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _medicalRecordsFuture =
                              _loadMedicalRecords();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      size: 64,
                    ),

                    SizedBox(height: 16),

                    Text(
                      'No medical records found.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Your clinic records will appear here '
                      'when available.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _medicalRecordsFuture =
                    _loadMedicalRecords();
              });

              await _medicalRecordsFuture;
            },

            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,

              itemBuilder: (context, index) {
                final record = records[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              _formatDate(
                                record.visitDate,
                              ),

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _RecordField(
                          label: 'Chief Complaint',
                          value:
                              record.chiefComplaint,
                        ),

                        _RecordField(
                          label: 'Diagnosis',
                          value: record.diagnosis,
                        ),

                        _RecordField(
                          label: 'Medications',
                          value:
                              record.medications,
                        ),

                        _RecordField(
                          label: 'Allergies',
                          value: record.allergies,
                        ),

                        _RecordField(
                          label: 'Clinical Notes',
                          value:
                              record.clinicalNotes,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _RecordField extends StatelessWidget {
  final String label;
  final String? value;

  const _RecordField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null ||
        value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value!,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}