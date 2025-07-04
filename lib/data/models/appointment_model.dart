class Appointment {
  final int id;
  final String patientName;
  final String cabinet;
  final DateTime time;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.cabinet,
    required this.time,
    this.status = AppointmentStatus.scheduled,
  });
}

enum AppointmentStatus {
  scheduled,  // Запланирован
  completed,  // Приём завершен
  noShow,     // Не явился
}