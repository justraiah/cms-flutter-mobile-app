class MedicalRecord {
  final int medicalRecordId;
  final DateTime visitDate;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? medications;
  final String? allergies;
  final String? clinicalNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicalRecord({
    required this.medicalRecordId,
    required this.visitDate,
    this.chiefComplaint,
    this.diagnosis,
    this.medications,
    this.allergies,
    this.clinicalNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      medicalRecordId: json['medicalRecordId'],
      visitDate: DateTime.parse(json['visitDate']),
      chiefComplaint: json['chiefComplaint'],
      diagnosis: json['diagnosis'],
      medications: json['medications'],
      allergies: json['allergies'],
      clinicalNotes: json['clinicalNotes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}