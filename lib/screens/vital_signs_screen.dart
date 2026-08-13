import 'dart:convert';
import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class VitalSignsScreen extends StatefulWidget {
  final String token;

  const VitalSignsScreen({
    super.key,
    required this.token,
  });

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _vitalSigns = [];

  @override
  void initState() {
    super.initState();
    _loadVitalSigns();
  }

  Future<void> _loadVitalSigns() async {
    try {
      final response = await ApiService.get(
        '/mobile/student/vital-signs',
        token: widget.token,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _vitalSigns = data is List ? data : [];
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Unable to load vital signs.\n'
              'Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Unable to connect to the clinic server.';
        _isLoading = false;
      });

      print('VITAL SIGNS ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Signs'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_vitalSigns.isEmpty) {
      return const Center(
        child: Text(
          'No vital sign records found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVitalSigns,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _vitalSigns.length,
        itemBuilder: (context, index) {
          final vital = _vitalSigns[index];

          return _VitalSignCard(
            vital: vital,
          );
        },
      ),
    );
  }
}

class _VitalSignCard extends StatelessWidget {
  final dynamic vital;

  const _VitalSignCard({
    required this.vital,
  });

  @override
  Widget build(BuildContext context) {
    final recordedAt = DateTime.tryParse(
      vital['recordedAt']?.toString() ?? '',
    );

    final dateText = recordedAt != null
        ? '${recordedAt.month}/${recordedAt.day}/${recordedAt.year}'
        : 'Unknown date';

    final timeText = recordedAt != null
        ? TimeOfDay.fromDateTime(recordedAt).format(context)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.monitor_heart),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vital Signs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$dateText $timeText',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  vital['status']?.toString() ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            _VitalRow(
              icon: Icons.thermostat,
              label: 'Temperature',
              value:
                  '${vital['temperature']} °C',
            ),

            _VitalRow(
              icon: Icons.favorite,
              label: 'Heart Rate',
              value:
                  '${vital['heartRate']} bpm',
            ),

            _VitalRow(
              icon: Icons.air,
              label: 'Oxygen Saturation',
              value:
                  '${vital['oxygenSaturation']}%',
            ),

            _VitalRow(
              icon: Icons.bloodtype,
              label: 'Blood Pressure',
              value:
                  '${vital['systolicBP']}/${vital['diastolicBP']} mmHg',
            ),

            if ((vital['visitReason'] ?? '')
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              _VitalRow(
                icon: Icons.notes,
                label: 'Visit Reason',
                value:
                    vital['visitReason'].toString(),
              ),
            ],

            if ((vital['remarks'] ?? '')
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              _VitalRow(
                icon: Icons.comment,
                label: 'Remarks',
                value:
                    vital['remarks'].toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VitalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VitalRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}