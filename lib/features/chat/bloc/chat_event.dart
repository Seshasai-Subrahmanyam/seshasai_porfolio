import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChatSettings extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;
  const SendMessage(this.message);
  @override
  List<Object?> get props => [message];
}

class ChangePersona extends ChatEvent {
  final ChatPersona persona;
  const ChangePersona(this.persona);
  @override
  List<Object?> get props => [persona];
}

class ChangeMode extends ChatEvent {
  final ChatMode mode;
  const ChangeMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ClearChat extends ChatEvent {}
