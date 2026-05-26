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
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    try {
      final response = await _searchKnowledgeBase(text.trim());

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
    final lower = input.toLowerCase();

    // Extrai keywords da pergunta do usuário
    final keywords = _extractKeywords(lower);

    if (keywords.isEmpty) return _defaultResponse();

    // Busca no Firestore por documentos que contenham alguma das keywords
    final snapshot = await _firestore
        .collection('knowledge_base')
        .where('keywords', arrayContainsAny: keywords)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return _defaultResponse();

    final doc = snapshot.docs.first.data();
    return doc['resposta'] as String? ?? _defaultResponse();
  }

  List<String> _extractKeywords(String input) {
    final keywordMap = {
      // Saudações e Menu
      'oi': 'saudacao',
      'olá': 'saudacao',
      'ola': 'saudacao',
      'bom dia': 'saudacao',
      'boa tarde': 'saudacao',
      'menu': 'menu',
      'ajuda': 'menu',
      'opções': 'menu',

      // Tipos de Rescisão
      'sem justa causa': 'sem_justa_causa',
      'dispensa': 'sem_justa_causa',
      'pedido de demissão': 'pedido_demissao',
      'pedir demissão': 'pedido_demissao',
      'pedir as contas': 'pedido_demissao',
      'acordo': 'acordo_comum',
      '484': 'acordo_comum',
      'justa causa': 'justa_causa',
      'falta grave': 'justa_causa',
      'comparar': 'tabela_comparativa',
      'diferença': 'tabela_comparativa',
      'tabela': 'tabela_comparativa',

      // Verbas
      'aviso': 'aviso_previo',
      'saldo': 'saldo_salario',
      '13': 'decimo_terceiro_proporcional',
      'décimo': 'decimo_terceiro_proporcional',
      'férias': 'ferias_proporcionais',
      'ferias': 'ferias_proporcionais',
      'fgts': 'fgts_multa',
      'multa': 'fgts_multa',

      // Legislação e Outros
      'mínimo': 'salario_minimo_2026',
      'minimo': 'salario_minimo_2026',
      'feriado': 'feriados_2026',
      'trabalhar feriado': 'feriados_2026',
      'insalubridade': 'insalubridade',
      'periculosidade': 'periculosidade',
      'seguro': 'seguro_desemprego',
    };

    final found = <String>{};
    for (final entry in keywordMap.entries) {
      if (input.contains(entry.key)) {
        found.add(entry.value);
      }
    }
    return found.toList();
  }

  String _defaultResponse() {
    return 'Não encontrei informações específicas sobre isso na minha base de conhecimento.\n\n'
        'Tente digitar **"Menu"** para ver os tópicos que posso explicar ou use termos como "Aviso Prévio", "FGTS" ou "Acordo".';
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearChat() {
    state = build();
  }
}

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  ChatViewModel.new,
);
