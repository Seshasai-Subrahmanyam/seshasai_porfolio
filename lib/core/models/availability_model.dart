import 'package:equatable/equatable.dart';

/// Availability status enum
enum AvailabilityStatus {
  openForWork('OPEN_FOR_WORK'),
  busy('BUSY'),
  notAvailable('NOT_AVAILABLE');

  final String value;
  const AvailabilityStatus(this.value);

  static AvailabilityStatus fromString(String value) {
    return AvailabilityStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AvailabilityStatus.openForWork,
    );
  }

  String get displayText {
    switch (this) {
      case AvailabilityStatus.openForWork:
        return 'Open for Work';
      case AvailabilityStatus.busy:
        return 'Currently Busy';
      case AvailabilityStatus.notAvailable:
        return 'Not Available';
    }
  }
}

/// Availability model
class AvailabilityModel extends Equatable {
  final AvailabilityStatus status;
  final DateTime? lastUpdated;

  const AvailabilityModel({
    required this.status,
    this.lastUpdated,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      status: AvailabilityStatus.fromString(
          json['availability'] as String? ?? 'OPEN_FOR_WORK'),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'availability': status.value,
        if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
      };

  @override
  List<Object?> get props => [status, lastUpdated];
}
