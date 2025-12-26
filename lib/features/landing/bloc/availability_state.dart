import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

enum AvailabilityStateStatus { initial, loading, loaded, error }

class AvailabilityState extends Equatable {
  final AvailabilityStateStatus status;
  final AvailabilityModel? availability;
  final String? errorMessage;

  const AvailabilityState({
    this.status = AvailabilityStateStatus.initial,
    this.availability,
    this.errorMessage,
  });

  AvailabilityState copyWith({
    AvailabilityStateStatus? status,
    AvailabilityModel? availability,
    String? errorMessage,
  }) {
    return AvailabilityState(
      status: status ?? this.status,
      availability: availability ?? this.availability,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, availability, errorMessage];
}
