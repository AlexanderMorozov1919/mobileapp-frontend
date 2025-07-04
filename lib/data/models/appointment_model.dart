class Appointment {
  final int id;
  final int doctorId;
  final int patientId;
  final DateTime date;
  final String? diagnosis;
  final String? recommendations;
  String status; // Убираем final, чтобы можно было изменять
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    this.diagnosis,
    this.recommendations,
    required this.status,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctor_id'],
      patientId: json['patient_id'],
      date: DateTime.parse(json['date']),
      diagnosis: json['diagnosis'],
      recommendations: json['recommendations'],
      status: json['status'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static List<Appointment> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Appointment.fromJson(json)).toList();
  }
}