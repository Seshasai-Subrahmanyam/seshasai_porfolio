import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/data.dart';
import '../../../core/models/models.dart';
import 'availability_event.dart';
import 'availability_state.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final ResumeRepository _resumeRepository;

  AvailabilityBloc({required ResumeRepository resumeRepository})
      : _resumeRepository = resumeRepository,
        super(const AvailabilityState()) {
    on<LoadAvailability>(_onLoadAvailability);
    on<RefreshAvailability>(_onRefreshAvailability);
  }

  Future<void> _onLoadAvailability(
    LoadAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(state.copyWith(status: AvailabilityStateStatus.loading));

    try {
      final personalInfo = await _resumeRepository.getPersonalInfo();
      final availability = _extractAvailability(personalInfo);
      emit(state.copyWith(
        status: AvailabilityStateStatus.loaded,
        availability: availability,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvailabilityStateStatus.error,
        errorMessage: e.toString(),
        // Fallback to default availability
        availability: const AvailabilityModel(
          status: AvailabilityStatus.openForWork,
        ),
      ));
    }
  }

  Future<void> _onRefreshAvailability(
    RefreshAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      // Clear cache and reload
      _resumeRepository.clearCache();
      final personalInfo = await _resumeRepository.getPersonalInfo();
      final availability = _extractAvailability(personalInfo);
      emit(state.copyWith(
        status: AvailabilityStateStatus.loaded,
        availability: availability,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvailabilityStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Extract availability from PersonalInfo
  AvailabilityModel _extractAvailability(PersonalInfo info) {
    return AvailabilityModel(
      status:
          AvailabilityStatus.fromString(info.availability ?? 'OPEN_FOR_WORK'),
      lastUpdated: info.availabilityUpdated,
    );
  }
}
