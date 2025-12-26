import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/data/data.dart';
import '../../../core/network/rag_api_client.dart';
import '../../../core/storage/local_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatelessWidget {
  final String? initialQuery;

  const ChatPage({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        ragClient: context.read<RagApiClient>(),
        prefs: context.read<LocalPrefs>(),
        resumeRepository: context.read<ResumeRepository>(),
      )..add(LoadChatSettings()),
      child: _ChatContent(initialQuery: initialQuery),
    );
  }
}

class _ChatContent extends StatefulWidget {
  final String? initialQuery;

  const _ChatContent({this.initialQuery});

  @override
  State<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<_ChatContent> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _initialQuerySent = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text.trim()));
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: AppTheme.animNormal, curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (prev, curr) =>
          prev.status == ChatStateStatus.loading &&
          curr.status == ChatStateStatus.loaded,
      listener: (context, state) {
        // Send initial query after settings are loaded
        if (!_initialQuerySent && widget.initialQuery != null) {
          _initialQuerySent = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            _sendMessage(widget.initialQuery!);
          });
        }
      },
      child: Column(
        children: [
          // Header with toggles
          Container(
            padding: EdgeInsets.all(
                isDesktop ? AppTheme.spacingLg : AppTheme.spacingMd),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                border: Border(
                    bottom: BorderSide(
                        color: AppTheme.textMuted.withValues(alpha: 0.1)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              MediaQuery.of(context).size.width < 400
                                  ? 'JUNNU AI'
                                  : 'Chat with JUNNU AI',
                              style: Theme.of(context).textTheme.headlineMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SvgPicture.asset("assets/icons/junnu_ai.svg",
                              width: 20, height: 20)
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            context.read<ChatBloc>().add(ClearChat()),
                        tooltip: 'New conversation'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Your AI assistant for exploring Seshasai\'s experience, skills, and projects',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                const _ToggleRow(),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.status == ChatStateStatus.loading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  itemCount: state.messages.length +
                      (state.status == ChatStateStatus.sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.messages.length) {
                      return _TypingIndicator();
                    }
                    return _MessageBubble(message: state.messages[index]);
                  },
                );
              },
            ),
          ),

          // Suggested prompts
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.suggestedPrompts.isEmpty)
                return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: state.suggestedPrompts
                        .map((prompt) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                  label: Text(prompt,
                                      style: const TextStyle(fontSize: 12)),
                                  onPressed: () => _sendMessage(prompt)),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                border: Border(
                    top: BorderSide(
                        color: AppTheme.textMuted.withValues(alpha: 0.1)))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'Ask about my experience...'),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: state.status == ChatStateStatus.sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.primaryBlue))
                          : const Icon(Icons.send_rounded,
                              color: AppTheme.primaryBlue),
                      onPressed: state.status == ChatStateStatus.sending
                          ? null
                          : () => _sendMessage(_controller.text),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Wrap(
          spacing: AppTheme.spacingMd,
          runSpacing: AppTheme.spacingSm,
          children: [
            // Persona
            _DropdownToggle<ChatPersona>(
                label: 'Persona',
                value: state.persona,
                items: ChatPersona.values,
                onChanged: (p) =>
                    context.read<ChatBloc>().add(ChangePersona(p)),
                itemBuilder: (p) => '${p.displayName}'
                // ${p.icon}
                //  }',
                ),
            // Mode
            _DropdownToggle<ChatMode>(
              label: 'Mode',
              value: state.mode,
              items: ChatMode.values,
              onChanged: (m) => context.read<ChatBloc>().add(ChangeMode(m)),
              itemBuilder: (m) => m.displayName,
            ),
          ],
        );
      },
    );
  }
}

class _DropdownToggle<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final Function(T) onChanged;
  final String Function(T) itemBuilder;

  const _DropdownToggle(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged,
      required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(itemBuilder(e),
                      style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          dropdownColor: AppTheme.bgElevated,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        constraints:
            BoxConstraints(maxWidth: width * (isSmallScreen ? 0.85 : 0.7)),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
              color: message.isUser
                  ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                  : AppTheme.textMuted.withValues(alpha: 0.1)),
        ),
        child: message.isUser
            ? Text(message.content,
                style: const TextStyle(color: AppTheme.textPrimary))
            : SelectionArea(
                child: MarkdownBody(
                  data: message.content,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: isSmallScreen ? 13 : 14),
                    tableBody: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: isSmallScreen ? 12 : 14),
                    tableHead: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14),
                  ),
                ),
              ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                // Staggered sine wave animation for bouncing effect
                // Offset each dot by pi/2
                final offset = index * 0.5;
                final value =
                    math.sin(_controller.value * 2 * math.pi + offset);

                // Map sine [-1, 1] to opacity [0.4, 1.0]
                final opacity = 0.4 + (0.6 * (0.5 + 0.5 * value));

                // Map sine [-1, 1] to translation Y [-3, 3]
                final translateY = -3.0 * (0.5 + 0.5 * value);

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: AppTheme.primaryBlue, shape: BoxShape.circle),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
