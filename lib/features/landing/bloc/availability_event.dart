import 'package:equatable/equatable.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailability extends AvailabilityEvent {
  const LoadAvailability();
}

class RefreshAvailability extends AvailabilityEvent {
  const RefreshAvailability();
}
