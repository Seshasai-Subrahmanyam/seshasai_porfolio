import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/data/data.dart';
import '../../../core/models/models.dart';

// Events
abstract class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object> get props => [];
}

class LoadResumeInfo extends ResumeEvent {
  const LoadResumeInfo();
}

// State
enum ResumeStatus { initial, loading, success, failure }

class ResumeState extends Equatable {
  final ResumeStatus status;
  final PersonalInfo? personalInfo;
  final String? errorMessage;

  const ResumeState({
    this.status = ResumeStatus.initial,
    this.personalInfo,
    this.errorMessage,
  });

  ResumeState copyWith({
    ResumeStatus? status,
    PersonalInfo? personalInfo,
    String? errorMessage,
  }) {
    return ResumeState(
      status: status ?? this.status,
      personalInfo: personalInfo ?? this.personalInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, personalInfo, errorMessage];
}

// Bloc
class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final ResumeRepository _repository;

  ResumeBloc({required ResumeRepository repository})
      : _repository = repository,
        super(const ResumeState()) {
    on<LoadResumeInfo>(_onLoadResumeInfo);
  }

  Future<void> _onLoadResumeInfo(
    LoadResumeInfo event,
    Emitter<ResumeState> emit,
  ) async {
    emit(state.copyWith(status: ResumeStatus.loading));
    try {
      final info = await _repository.getPersonalInfo();
      emit(state.copyWith(
        status: ResumeStatus.success,
        personalInfo: info,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ResumeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
