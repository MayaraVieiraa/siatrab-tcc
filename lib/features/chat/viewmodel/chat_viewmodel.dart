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
              'Olá, eu sou Aly! Assistente virtual focada em direito trabalhista!',
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
      'intervalo': 'intervalo',
      'intrajornada': 'intervalo',
      'repouso': 'intervalo',
      'alimentação': 'intervalo',
      'férias': 'ferias',
      'ferias': 'ferias',
      'período aquisitivo': 'ferias',
      'fgts': 'fgts',
      'fundo de garantia': 'fgts',
      'inss': 'inss',
      'previdência': 'inss',
      'rescisão': 'rescisao',
      'rescisao': 'rescisao',
      'demissão': 'rescisao',
      'demissao': 'rescisao',
      'aviso prévio': 'aviso_previo',
      'aviso previo': 'aviso_previo',
      '13': 'decimo_terceiro',
      'décimo': 'decimo_terceiro',
      'decimo': 'decimo_terceiro',
      'natal': 'decimo_terceiro',
      'justa causa': 'justa_causa',
      'salário mínimo': 'salario_minimo',
      'salario minimo': 'salario_minimo',
      'horas extras': 'horas_extras',
      'hora extra': 'horas_extras',
      'insalubridade': 'insalubridade',
      'insalubre': 'insalubridade',
      'periculosidade': 'periculosidade',
      'perigoso': 'periculosidade',
      'jornada': 'jornada',
      'trabalho noturno': 'trabalho_noturno',
      'noturno': 'trabalho_noturno',
      'estabilidade': 'estabilidade',
      'seguro desemprego': 'seguro_desemprego',
      'seguro-desemprego': 'seguro_desemprego',
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
        'Posso ajudar com temas como:\n'
        '• Férias e 13º salário\n'
        '• FGTS e INSS\n'
        '• Rescisão e aviso prévio\n'
        '• Intervalo intrajornada\n'
        '• Justa causa\n'
        '• Horas extras e insalubridade\n\n'
        'Tente reformular sua pergunta com um desses termos!';
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
