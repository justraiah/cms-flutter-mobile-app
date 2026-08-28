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
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vital Signs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
      return _ErrorState(
        message: _errorMessage!,
        onRetry: _loadVitalSigns,
      );
    }

    if (_vitalSigns.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadVitalSigns,
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
            'Your Vital Signs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'View your recorded health measurements from clinic visits.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          ..._vitalSigns.map(
            (vital) => Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: _VitalSignCard(
                vital: vital,
              ),
            ),
          ),
        ],
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
        ? _formatDate(recordedAt)
        : 'Unknown date';

    final timeText = recordedAt != null
        ? TimeOfDay.fromDateTime(recordedAt).format(context)
        : '';

    final status =
        vital['status']?.toString() ?? 'Unknown';

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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.teal,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clinic Measurement',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                _StatusBadge(
                  status: status,
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Divider(
              height: 1,
            ),

            const SizedBox(height: 20),

            _VitalRow(
              icon: Icons.thermostat_outlined,
              label: 'Temperature',
              value:
                  '${vital['temperature']} °C',
            ),

            _VitalRow(
              icon: Icons.favorite_outline,
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
              icon: Icons.bloodtype_outlined,
              label: 'Blood Pressure',
              value:
                  '${vital['systolicBP']}/${vital['diastolicBP']} mmHg',
            ),

            if ((vital['visitReason'] ?? '')
                .toString()
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 4),
              _VitalRow(
                icon: Icons.notes_outlined,
                label: 'Visit Reason',
                value:
                    vital['visitReason'].toString(),
              ),
            ],

            if ((vital['remarks'] ?? '')
                .toString()
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 4),
              _VitalRow(
                icon: Icons.comment_outlined,
                label: 'Remarks',
                value:
                    vital['remarks'].toString(),
                showBottomPadding: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
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

class _VitalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showBottomPadding;

  const _VitalRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showBottomPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomPadding ? 18 : 0,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                size: 42,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Vital Signs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your recorded vital signs will appear here '
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
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.red.withValues(
                  alpha: 0.08,
                ),
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
              'Unable to Load Vital Signs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'We could not retrieve your vital signs. '
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