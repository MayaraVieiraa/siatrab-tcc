import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChatViewModel extends Notifier<ChatState> {
  final _firestore = FirebaseFirestore.instance;

  @override
  ChatState build() {
    return ChatState(
      messages: [
        ChatMessage(
          text:
              'Olá! Eu sou o Assistente Trabalhista 2026. Como posso ajudar você hoje?\n\nDigite "Menu" para ver os temas que posso explicar!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    final input = text.trim();
    if (input.isEmpty) return;

    final userMessage = ChatMessage(
      text: input,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    try {
      final response = await _searchKnowledgeBase(input);

      final botMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        errorMessage: 'Erro ao buscar resposta. Tente novamente.',
      );
    }
  }

  Future<String> _searchKnowledgeBase(String input) async {
    final query = input.toLowerCase();

    // 1. Tenta busca exata nas keywords
    final exactMatch = await _firestore
        .collection('knowledge_base')
        .where('keywords', arrayContains: query)
        .limit(1)
        .get();

    if (exactMatch.docs.isNotEmpty) {
      return exactMatch.docs.first.data()['resposta'] as String;
    }

    // 2. Tenta busca parcial simples (verifica se alguma keyword contém a query ou vice-versa)
    // Nota: O Firestore não suporta busca por "contém" em arrays de forma nativa e eficiente sem índices externos,
    // então vamos buscar todos os documentos e filtrar localmente (já que a base é pequena).
    final allDocs = await _firestore.collection('knowledge_base').get();

    for (final doc in allDocs.docs) {
      final data = doc.data();
      final keywords = List<String>.from(data['keywords'] ?? []);

      for (final keyword in keywords) {
        if (query.contains(keyword) || keyword.contains(query)) {
          return data['resposta'] as String;
        }
      }
    }

    return _defaultResponse();
  }

  String _defaultResponse() {
    return 'Não encontrei informações específicas sobre isso na minha base de conhecimento.\n\n'
        'Tente digitar **"Menu"** para ver os tópicos que posso explicar ou use termos como "Aviso Prévio", "FGTS" ou "Acordo".';
  }

  void clearChat() {
    state = build();
  }
}

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  ChatViewModel.new,
);
