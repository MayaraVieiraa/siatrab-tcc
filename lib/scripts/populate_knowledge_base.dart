import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await populateKnowledgeBase();
  print(
    '✅ Knowledge Base populada com sucesso! (30 artigos - CLT oficial + 2026)',
  );
}

Future<void> populateKnowledgeBase() async {
  final db = FirebaseFirestore.instance;
  final collection = db.collection('knowledge_base');

  final articles = [
    // ============================================================
    // 1. SAUDAÇÃO E MENU (2 artigos)
    // ============================================================
    {
      'id': 'saudacao',
      'keywords': [
        'oi',
        'olá',
        'ola',
        'bom dia',
        'boa tarde',
        'start',
        'iniciar',
        'ajuda',
      ],
      'tema': 'Boas-vindas',
      'artigo': 'N/A',
      'resposta':
          'Olá! Eu sou o **Assistente Trabalhista 2026**.\n\n'
          '💡 **Minha função é explicar as regras** da CLT e como as verbas trabalhistas funcionam.\n'
          '🧮 **Quem faz os cálculos** é a **Calculadora Trabalhista** do sistema.\n\n'
          '**Digite "Menu"** para ver os tópicos que posso explicar:\n'
          '- Tipos de demissão (Sem justa causa, Pedido, Acordo, Justa causa)\n'
          '- Verbas rescisórias (Aviso prévio, 13º, Férias, FGTS)\n'
          '- Jornada de trabalho (Horas extras, Intervalo, Trabalho noturno)\n'
          '- Adicionais (Insalubridade, Periculosidade)\n'
          '- Estabilidade (Gestante, CIPA, Acidente)\n'
          '- Trabalho do menor e Aprendiz\n'
          '- Licença-maternidade\n'
          '- Prescrição trabalhista\n'
          '- e muito mais.\n\n'
          'Como posso ajudar?',
    },
    {
      'id': 'menu',
      'keywords': [
        'menu',
        'opções',
        'o que fazer',
        'ajuda',
        'temas',
        'topicos',
      ],
      'tema': 'Menu Central',
      'artigo': 'N/A',
      'resposta':
          '📋 **MENU DE CONSULTAS TRABALHISTAS (30 tópicos)**\n\n'
          '**📍 CONCEITOS BÁSICOS**\n'
          '➡️ Conceito de Empregador (Art. 2º)\n'
          '➡️ Conceito de Empregado (Art. 3º)\n'
          '➡️ Trabalho Remoto / Home Office (Art. 6º)\n'
          '➡️ Quem NÃO é regido pela CLT (Art. 7º)\n'
          '➡️ Fraude e desvirtuamento (Art. 9º)\n'
          '➡️ Prescrição trabalhista (Art. 11)\n\n'
          '**⏰ JORNADA DE TRABALHO**\n'
          '➡️ Jornada normal (Art. 58)\n'
          '➡️ Horas extras (Art. 59)\n'
          '➡️ Força maior e prorrogação (Art. 61)\n'
          '➡️ Exceções (cargos de confiança) (Art. 62)\n'
          '➡️ Descanso entre jornadas (Art. 66)\n'
          '➡️ Descanso semanal (Art. 67)\n'
          '➡️ Trabalho em feriados (Art. 70)\n'
          '➡️ Intervalo intrajornada (Art. 71)\n'
          '➡️ Trabalho noturno (Art. 73)\n'
          '➡️ Controle de horário (Art. 74)\n\n'
          '**🏖️ FÉRIAS**\n'
          '➡️ Direito a férias (Art. 129)\n'
          '➡️ Duração das férias (Art. 130)\n'
          '➡️ Concessão de férias (Art. 134)\n'
          '➡️ Férias em dobro (Art. 137)\n'
          '➡️ Abono de férias (vender férias) (Art. 143)\n\n'
          '**💰 SALÁRIO E ADICIONAIS**\n'
          '➡️ Salário mínimo (Art. 76)\n'
          '➡️ Salário por empreitada/tarefa (Art. 78)\n'
          '➡️ Insalubridade (Art. 192)\n'
          '➡️ Periculosidade (Art. 193)\n'
          '➡️ Gorjetas (Art. 457)\n'
          '➡️ Salário-utilidade (Art. 458)\n'
          '➡️ Pagamento do salário (Art. 459)\n'
          '➡️ Igualdade salarial (Art. 461)\n'
          '➡️ Descontos salariais (Art. 462)\n\n'
          '**📄 RESCISÃO CONTRATUAL**\n'
          '➡️ Verbas rescisórias (Art. 477)\n'
          '➡️ Indenização por tempo de serviço (Art. 478)\n'
          '➡️ Rescisão de contrato a prazo (Art. 479-480)\n'
          '➡️ Justa causa (Art. 482)\n'
          '➡️ Rescisão indireta (Art. 483)\n'
          '➡️ Culpa recíproca (Art. 484)\n'
          '➡️ Aviso prévio (Art. 487)\n'
          '➡️ Redução de jornada no aviso (Art. 488)\n\n'
          '**🛡️ ESTABILIDADE**\n'
          '➡️ Estabilidade decenal (Art. 492)\n'
          '➡️ Cargos de confiança (Art. 499)\n'
          '➡️ CIPA (Art. 165)\n'
          '➡️ Estabilidade gestante (Art. 391-A)\n\n'
          '**👷 SAÚDE E SEGURANÇA**\n'
          '➡️ Normas de segurança (Art. 154)\n'
          '➡️ Obrigações da empresa (Art. 157)\n'
          '➡️ Obrigações do empregado (Art. 158)\n'
          '➡️ Serviços especializados (Art. 162)\n'
          '➡️ CIPA (Art. 163)\n'
          '➡️ EPI (Art. 166)\n'
          '➡️ Exames médicos (Art. 168)\n\n'
          '**🤰 PROTEÇÃO ESPECIAL**\n'
          '➡️ Licença-maternidade (Art. 392)\n'
          '➡️ Trabalho do menor (Art. 403-408)\n'
          '➡️ Contrato de aprendizagem (Art. 428-433)\n\n'
          '**🧮 Use a CALCULADORA TRABALHISTA para valores exatos!**',
    },

    // ============================================================
    // 2. CONCEITOS BÁSICOS (Arts. 2º, 3º, 6º, 7º, 8º, 9º, 11)
    // ============================================================
    {
      'id': 'conceito_empregador',
      'keywords': [
        'empregador',
        'o que é empregador',
        'quem é empregador',
        'empresa',
        'grupo econômico',
      ],
      'tema': 'Conceito de Empregador',
      'artigo': 'Art. 2º da CLT',
      'resposta':
          '**CONCEITO DE EMPREGADOR (Art. 2º da CLT)**\n\n'
          'Empregador é a **empresa individual ou coletiva** que:\n'
          '• Assume os riscos da atividade econômica\n'
          '• Admite, assalaria e dirige a prestação pessoal de serviços\n\n'
          '📌 **Também são equiparados a empregadores:**\n'
          '• Profissionais liberais (médicos, advogados, dentistas)\n'
          '• Instituições de beneficência\n'
          '• Associações recreativas sem fins lucrativos\n'
          '• Instituições sem fins lucrativos em geral\n\n'
          '⚠️ **Grupo econômico (Art. 2º, §2º):**\n'
          'Empresas que estão sob direção, controle ou administração de outra respondem SOLIDARIAMENTE pelas obrigações trabalhistas.\n\n'
          '✅ **Base legal:** Art. 2º da CLT.',
    },
    {
      'id': 'conceito_empregado',
      'keywords': [
        'empregado',
        'o que é empregado',
        'quem é empregado',
        'requisitos empregado',
        'relação de emprego',
      ],
      'tema': 'Conceito de Empregado',
      'artigo': 'Art. 3º da CLT',
      'resposta':
          '**CONCEITO DE EMPREGADO (Art. 3º da CLT)**\n\n'
          'Empregado é toda **pessoa física** que presta serviços com 4 requisitos essenciais:\n\n'
          '✅ **1. Pessoalidade** (prestado pela própria pessoa)\n'
          '✅ **2. Não eventualidade** (habitual, contínuo)\n'
          '✅ **3. Subordinação** (dependência ao empregador)\n'
          '✅ **4. Onerosidade** (mediante salário)\n\n'
          '📌 **Não há distinção entre:**\n'
          '• Trabalho intelectual, técnico e manual\n'
          '• Espécie de emprego ou condição do trabalhador\n\n'
          '⚠️ **Importante:** Se você trabalha para alguém, todos os dias, seguindo ordens e recebendo salário, você é empregado e tem todos os direitos da CLT.\n\n'
          '✅ **Base legal:** Art. 3º da CLT.',
    },
    {
      'id': 'trabalho_remoto',
      'keywords': [
        'home office',
        'remoto',
        'teletrabalho',
        'trabalho a distância',
        'trabalho remoto',
      ],
      'tema': 'Trabalho Remoto (Home Office)',
      'artigo': 'Art. 6º da CLT',
      'resposta':
          '**TRABALHO REMOTO / HOME OFFICE (Art. 6º da CLT)**\n\n'
          'A lei não faz distinção entre o trabalho feito:\n'
          '• No estabelecimento do empregador\n'
          '• No domicílio do empregado\n'
          '• A distância\n\n'
          '📌 **O que importa:** Se estão presentes os requisitos da relação de emprego (pessoa física, subordinação, habitualidade e salário), os direitos são os mesmos!\n\n'
          '⚠️ **Prova de subordinação:**\n'
          'Os meios telemáticos e informatizados (WhatsApp, e-mail, sistemas de gestão, controle remoto) também servem como prova de subordinação jurídica.\n\n'
          '✅ **Base legal:** Art. 6º e parágrafo único da CLT (Lei 12.551/2011).',
    },
    {
      'id': 'excecoes_clt',
      'keywords': [
        'quem não tem direito',
        'exceções clt',
        'não se aplica clt',
        'empregado doméstico',
        'trabalhador rural',
        'funcionário público',
      ],
      'tema': 'Exceções da CLT',
      'artigo': 'Art. 7º da CLT',
      'resposta':
          '**EXCEÇÕES - A QUEM NÃO SE APLICA A CLT (Art. 7º)**\n\n'
          'Os preceitos da CLT NÃO se aplicam a:\n\n'
          '❌ **Empregados domésticos** (serviços não-econômicos à pessoa/família no âmbito residencial)\n'
          '❌ **Trabalhadores rurais** (desde que não sejam empregados em atividades industriais/comerciais)\n'
          '❌ **Funcionários públicos** da União, Estados e Municípios\n'
          '❌ **Servidores de autarquias paraestatais** (sujeitos a regime próprio)\n\n'
          '📌 **Atenção:** Essas categorias podem ter direitos específicos em outras leis (ex: Lei do Doméstico - 150/2015; Lei do Rural - 5.889/73).\n\n'
          '✅ **Base legal:** Art. 7º da CLT (redação dada pelo Decreto-Lei 8.079/1945).',
    },
    {
      'id': 'fraude_clt',
      'keywords': [
        'fraude',
        'desvirtuar',
        'nulidade',
        'ato nulo',
        'fraudar a lei',
      ],
      'tema': 'Fraude e Desvirtuamento',
      'artigo': 'Art. 9º da CLT',
      'resposta':
          '**ATOS FRAUDULENTOS (Art. 9º da CLT)**\n\n'
          'Serão nulos de pleno direito os atos praticados com o objetivo de:\n'
          '• Desvirtuar a aplicação da CLT\n'
          '• Impedir a aplicação da CLT\n'
          '• Fraudar a aplicação dos preceitos da CLT\n\n'
          '⚠️ **Exemplos comuns:**\n'
          '• Contrato de PJ para encobrir relação de emprego\n'
          '• Cooperativa fraudulenta para não registrar empregados\n'
          '• Contrato de estágio simulado\n'
          '• "Pejotização" para evitar direitos trabalhistas\n\n'
          '📌 A Justiça do Trabalho pode declarar a nulidade e reconhecer o vínculo empregatício.\n\n'
          '✅ **Base legal:** Art. 9º da CLT.',
    },
    {
      'id': 'prescricao',
      'keywords': [
        'prescrição',
        'prazo para reclamar',
        'perder direito',
        'decadência',
        '5 anos',
        '2 anos',
      ],
      'tema': 'Prescrição Trabalhista',
      'artigo': 'Art. 11 da CLT',
      'resposta':
          '**PRAZO PRESCRICIONAL (Art. 11 da CLT)**\n\n'
          'O trabalhador tem **5 anos** para reclamar seus direitos na Justiça do Trabalho, contados da data da saída do emprego.\n\n'
          '⚠️ **Regra dos 2 anos:**\n'
          'Só podem ser cobrados direitos dos **últimos 2 anos do contrato**.\n\n'
          '📌 **Exemplo prático:**\n'
          'Se você trabalhou 10 anos e foi demitido hoje, pode cobrar:\n'
          '• Direitos dos últimos **5 anos** (prazo total)\n'
          '• Limitado aos **2 anos finais** do contrato\n\n'
          '📌 **Exceção:**\n'
          'Não se aplica a ações que tenham por objeto anotações para fins de prova junto à Previdência Social.\n\n'
          '✅ **Base legal:** Art. 11 da CLT (redação dada pela Lei 9.658/1998).',
    },

    // ============================================================
    // 3. JORNADA DE TRABALHO (Arts. 58, 59, 61, 62, 66, 67, 70, 71, 72, 73, 74)
    // ============================================================
    {
      'id': 'jornada_normal',
      'keywords': [
        'jornada',
        'carga horária',
        'horas por dia',
        '8 horas',
        '44 horas semanais',
      ],
      'tema': 'Jornada Normal de Trabalho',
      'artigo': 'Art. 58 da CLT',
      'resposta':
          '**JORNADA NORMAL DE TRABALHO (Art. 58 da CLT)**\n\n'
          'A duração normal do trabalho não excederá de:\n'
          '• **8 horas diárias**\n'
          '• **44 horas semanais** (média)\n\n'
          '📌 **Tolerância (Art. 58, §1º):**\n'
          'Variações no registro de ponto de até **5 minutos** não são descontadas, desde que não ultrapassem **10 minutos diários**.\n\n'
          '📌 **Tempo de deslocamento (Art. 58, §2º):**\n'
          '• Regra geral: não é computado na jornada\n'
          '• Exceção: local de difícil acesso sem transporte público (se o empregador fornecer condução)\n\n'
          '📌 **Tempo parcial (Art. 58-A):**\n'
          '• Até 25 horas semanais\n'
          '• Salário proporcional\n'
          '• Sem horas extras\n\n'
          '✅ **Base legal:** Art. 58 e 58-A da CLT.',
    },
    {
      'id': 'horas_extras',
      'keywords': [
        'hora extra',
        'horas extras',
        'adicional 50%',
        'hora extra 100%',
        'banco de horas',
        'compensação',
      ],
      'tema': 'Horas Extras e Banco de Horas',
      'artigo': 'Art. 59 da CLT',
      'resposta':
          '**HORAS EXTRAS E BANCO DE HORAS (Art. 59 da CLT)**\n\n'
          'A jornada normal de 8h/dia pode ser acrescida de horas suplementares.\n\n'
          '⏰ **Limite:** Máximo de **2 horas extras por dia** (necessitando de acordo ou convenção coletiva).\n\n'
          '💰 **Remuneração:** Mínimo de **50% a mais** que a hora normal (adicional).\n\n'
          '📌 **Banco de Horas (Art. 59, §2º):**\n'
          '• Compensa horas extras com folgas\n'
          '• Prazo máximo: 1 ano para compensação\n'
          '• Pode ser acordado por convenção coletiva\n'
          '• Limite diário: 10 horas\n\n'
          '⚠️ **Rescisão:** Se não houver compensação integral, o trabalhador recebe as horas extras calculadas sobre o salário da data da rescisão.\n\n'
          '✅ **Base legal:** Art. 59 da CLT.',
    },
    {
      'id': 'forca_maior_jornada',
      'keywords': [
        'força maior',
        'urgência',
        'prorrogação excepcional',
        '12 horas',
        'necessidade imperiosa',
      ],
      'tema': 'Jornada em Caso de Força Maior',
      'artigo': 'Art. 61 da CLT',
      'resposta':
          '**PRORROGAÇÃO EXCEPCIONAL (Art. 61 da CLT)**\n\n'
          'Ocorrendo necessidade imperiosa, poderá a duração do trabalho exceder o limite legal por:\n'
          '• Motivo de força maior\n'
          '• Atender à realização de serviços inadiáveis\n\n'
          '📌 **Regras:**\n'
          '• Independe de acordo ou contrato coletivo\n'
          '• Deve ser comunicado à autoridade competente em 10 dias\n'
          '• No caso de força maior, hora excedente ≥ hora normal\n'
          '• Nos demais casos, adicional mínimo de 25%\n'
          '• Limite máximo de 12 horas diárias\n\n'
          '📌 **Recuperação de tempo perdido (Art. 61, §3º):**\n'
          '• Até 2 horas extras para recuperar paralisação\n'
          '• Até 10 horas diárias\n'
          '• Máximo 45 dias por ano\n'
          '• Exige prévia autorização\n\n'
          '✅ **Base legal:** Art. 61 da CLT.',
    },
    {
      'id': 'excecoes_jornada',
      'keywords': [
        'cargo de confiança',
        'gerente',
        'atividade externa',
        'sem controle de horário',
        'art 62',
      ],
      'tema': 'Exceções ao Controle de Jornada',
      'artigo': 'Art. 62 da CLT',
      'resposta':
          '**TRABALHADORES SEM CONTROLE DE JORNADA (Art. 62 da CLT)**\n\n'
          'Não se aplica o regime de controle de jornada aos seguintes empregados:\n\n'
          '❌ **Atividade externa incompatível com fixação de horário**\n'
          '• Ex: Vendedores externos, entregadores (que não têm horário fixo)\n'
          '• Condição deve ser anotada na CTPS\n\n'
          '❌ **Gerentes e cargos de gestão**\n'
          '• Gerentes, diretores, chefes de departamento/filial\n'
          '• Exercem cargo de confiança com poder de mando\n\n'
          '⚠️ **Exceção à exceção (Art. 62, parágrafo único):**\n'
          'O regime de jornada se aplica se o salário do cargo de confiança for inferior ao salário efetivo + 40%.\n\n'
          '✅ **Base legal:** Art. 62 da CLT (redação dada pela Lei 8.966/1994).',
    },
    {
      'id': 'intervalo_interjornada',
      'keywords': [
        'intervalo entre jornadas',
        'descanso entre dias',
        '11 horas',
        'interjornada',
      ],
      'tema': 'Intervalo Interjornada',
      'artigo': 'Art. 66 da CLT',
      'resposta':
          '**INTERVALO INTERJORNADA (Art. 66 da CLT)**\n\n'
          'Entre 2 (duas) jornadas de trabalho, haverá um período mínimo de **11 horas consecutivas** para descanso.\n\n'
          '📌 **Importância:**\n'
          '• Garante o descanso do trabalhador entre um dia e outro\n'
          '• Visa proteger a saúde e segurança do trabalhador\n'
          '• A falta desse intervalo gera direito a horas extras\n\n'
          '⚠️ **Consequência da não concessão:**\n'
          'A jurisprudência considera que a redução ou supressão do intervalo interjornada gera direito ao pagamento das horas suprimidas como extras, com adicional.\n\n'
          '✅ **Base legal:** Art. 66 da CLT.',
    },
    {
      'id': 'descanso_semanal',
      'keywords': [
        'descanso semanal',
        'folga semanal',
        'domingo',
        '24 horas',
        'repouso semanal remunerado',
      ],
      'tema': 'Descanso Semanal Remunerado (DSR)',
      'artigo': 'Art. 67 da CLT',
      'resposta':
          '**DESCANSO SEMANAL REMUNERADO (Art. 67 da CLT)**\n\n'
          'Todo empregado tem direito a um descanso semanal de **24 horas consecutivas**.\n\n'
          '📌 **Regra geral:** Deve coincidir com o domingo, no todo ou em parte.\n\n'
          '📌 **Exceções:**\n'
          '• Motivo de conveniência pública\n'
          '• Necessidade imperiosa do serviço\n'
          '• Trabalho aos domingos exige permissão prévia (Art. 68)\n\n'
          '📌 **Revezamento:**\n'
          'Nos serviços que exigem trabalho aos domingos, deve haver escala de revezamento mensal.\n\n'
          '⚠️ **Trabalho em feriados (Art. 70):**\n'
          'É vedado o trabalho em feriados nacionais e religiosos, salvo disposição em contrário.\n\n'
          '✅ **Base legal:** Arts. 67, 68 e 70 da CLT.',
    },
    {
      'id': 'intervalo_intrajornada',
      'keywords': [
        'intervalo',
        'almoço',
        'descanso',
        'hora do almoço',
        '1 hora',
        '15 minutos',
      ],
      'tema': 'Intervalo Intrajornada (Almoço)',
      'artigo': 'Art. 71 da CLT',
      'resposta':
          '**INTERVALO INTRAJORNADA (HORA DO ALMOÇO) - Art. 71 da CLT**\n\n'
          '📌 **Duração conforme a jornada:**\n'
          '• **Jornada > 6 horas:** Intervalo mínimo de **1 hora** e máximo de **2 horas**\n'
          '• **Jornada entre 4 e 6 horas:** Intervalo de **15 minutos**\n'
          '• **Jornada < 4 horas:** Não há intervalo obrigatório\n\n'
          '⚠️ **Consequência da não concessão (Art. 71, §4º):**\n'
          'Se o intervalo não for concedido integralmente, o empregador deve pagar o período correspondente com **acréscimo de 50%** sobre o valor da hora normal.\n\n'
          '📌 **Motoristas (Art. 71, §5º):**\n'
          'O intervalo pode ser reduzido e/ou fracionado quando previsto em convenção coletiva.\n\n'
          '✅ **Base legal:** Art. 71 da CLT.',
    },
    {
      'id': 'descanso_mecanografia',
      'keywords': [
        'mecanografia',
        'datilografia',
        'pausa',
        '90 minutos',
        '10 minutos',
      ],
      'tema': 'Descanso para Mecanografia',
      'artigo': 'Art. 72 da CLT',
      'resposta':
          '**DESCANSO EM SERVIÇOS DE MECANOGRAFIA (Art. 72 da CLT)**\n\n'
          'Para serviços permanentes de mecanografia (datilografia, escrituração ou cálculo):\n\n'
          '📌 **Regra:**\n'
          'A cada período de **90 minutos** de trabalho consecutivo corresponde um repouso de **10 minutos**.\n\n'
          '⚠️ **Importante:**\n'
          'Esse repouso NÃO é deduzido da duração normal do trabalho. Ou seja, as 10 minutos são computados como trabalho efetivo.\n\n'
          '✅ **Base legal:** Art. 72 da CLT.',
    },
    {
      'id': 'trabalho_noturno',
      'keywords': [
        'trabalho noturno',
        'adicional noturno',
        'horário noturno',
        'das 22h',
        'hora noturna reduzida',
      ],
      'tema': 'Trabalho Noturno (Urbano)',
      'artigo': 'Art. 73 da CLT',
      'resposta':
          '**TRABALHO NOTURNO URBANO (Art. 73 da CLT)**\n\n'
          'Considera-se trabalho noturno o realizado entre **22h de um dia e 5h do dia seguinte**.\n\n'
          '🌙 **Direitos do trabalho noturno:**\n\n'
          '1️⃣ **Adicional noturno:** Mínimo de **20%** sobre o valor da hora diurna\n'
          '2️⃣ **Hora reduzida:** A hora noturna é computada como **52 minutos e 30 segundos** (relógio de ponto marca 60 minutos, mas você só trabalha 52:30)\n\n'
          '📌 **Exemplo prático:**\n'
          'Das 22h às 5h = 7 horas no relógio, mas para a lei você trabalhou apenas **6 horas e 52 minutos**.\n\n'
          '⚠️ **Revezamento:** Em caso de revezamento semanal ou quinzenal, o adicional pode ser reduzido.\n\n'
          '✅ **Base legal:** Art. 73 da CLT.',
    },
    {
      'id': 'controle_horario',
      'keywords': [
        'ponto',
        'registro de ponto',
        'controle de horário',
        'marcar ponto',
        'quadro de horário',
      ],
      'tema': 'Controle de Horário',
      'artigo': 'Art. 74 da CLT',
      'resposta':
          '**CONTROLE DE HORÁRIO (Art. 74 da CLT)**\n\n'
          '📌 **Quadro de horário (Art. 74, caput):**\n'
          'O horário do trabalho deve constar de quadro afixado em lugar bem visível.\n\n'
          '📌 **Registro de ponto (Art. 74, §2º):**\n'
          'Estabelecimentos com mais de 10 trabalhadores devem ter registro de entrada e saída (manual, mecânico ou eletrônico).\n\n'
          '📌 **Trabalho externo (Art. 74, §3º):**\n'
          'Se o trabalho for executado fora do estabelecimento, o horário deve constar de ficha ou papeleta em poder do empregado.\n\n'
          '⚠️ **Consequência da falta de controle:**\n'
          'A falta de registro de ponto gera presunção relativa de veracidade da jornada alegada pelo empregado (Súmula 338 do TST).\n\n'
          '✅ **Base legal:** Art. 74 da CLT.',
    },

    // ============================================================
    // 4. FÉRIAS (Arts. 129, 130, 134, 137, 143)
    // ============================================================
    {
      'id': 'direito_ferias',
      'keywords': [
        'férias',
        'direito a férias',
        '12 meses',
        'período aquisitivo',
      ],
      'tema': 'Direito a Férias',
      'artigo': 'Art. 129 da CLT',
      'resposta':
          '**DIREITO A FÉRIAS (Art. 129 da CLT)**\n\n'
          'Todo empregado tem direito anualmente ao gozo de um período de **férias**, sem prejuízo da remuneração.\n\n'
          '📌 **Período aquisitivo:**\n'
          'O direito a férias é adquirido após **12 meses de trabalho** (período aquisitivo).\n\n'
          '📌 **Período concessivo:**\n'
          'As férias devem ser concedidas nos **12 meses seguintes** ao período aquisitivo (Art. 134).\n\n'
          '⚠️ **Consequência do atraso (Art. 137):**\n'
          'Se as férias forem concedidas após o prazo de 12 meses do período aquisitivo, o empregador paga em dobro.\n\n'
          '✅ **Base legal:** Arts. 129 e 134 da CLT.\n\n'
          '🧮 **Use a CALCULADORA TRABALHISTA para calcular o valor das suas férias.**',
    },
    {
      'id': 'duracao_ferias',
      'keywords': [
        'quantos dias de férias',
        'duração férias',
        '30 dias',
        'férias proporcionais faltas',
      ],
      'tema': 'Duração das Férias',
      'artigo': 'Art. 130 da CLT',
      'resposta':
          '**DURAÇÃO DAS FÉRIAS (Art. 130 da CLT)**\n\n'
          'A duração das férias varia conforme o número de faltas não justificadas no período aquisitivo:\n\n'
          '📌 **Tabela de dias de férias:**\n'
          '• **30 dias** → até 5 faltas\n'
          '• **24 dias** → de 6 a 14 faltas\n'
          '• **18 dias** → de 15 a 23 faltas\n'
          '• **12 dias** → de 24 a 32 faltas\n\n'
          '⚠️ **Faltas que NÃO contam (Art. 131):**\n'
          '• Falecimento de familiar\n'
          '• Casamento (3 dias)\n'
          '• Licença-maternidade\n'
          '• Acidente de trabalho ou doença (atestado)\n'
          '• Dias sem serviço na empresa\n'
          '• Serviço militar\n\n'
          '✅ **Base legal:** Arts. 130 e 131 da CLT.',
    },
    {
      'id': 'ferias_vencidas_dobro',
      'keywords': [
        'férias vencidas',
        'férias em dobro',
        'atraso férias',
        'pagamento em dobro',
      ],
      'tema': 'Férias Vencidas (Atraso)',
      'artigo': 'Art. 137 da CLT',
      'resposta':
          '**FÉRIAS VENCIDAS - PAGAMENTO EM DOBRO (Art. 137 da CLT)**\n\n'
          'O empregador tem até **12 meses após o período aquisitivo** para conceder as férias.\n\n'
          '⚠️ **Consequência do atraso:**\n'
          'Sempre que as férias forem concedidas após esse prazo, o empregador pagará **em dobro** a respectiva remuneração.\n\n'
          '📌 **Exemplo:**\n'
          'Período aquisitivo: 01/01/2025 a 31/12/2025\n'
          'Prazo para conceder: até 31/12/2026\n'
          'Se conceder em 01/01/2027 → paga em dobro!\n\n'
          '📌 **Ação do empregado:**\n'
          'Vencido o prazo, o empregado pode ajuizar reclamação pedindo a fixação da época de gozo das férias.\n\n'
          '✅ **Base legal:** Art. 137 da CLT.',
    },
    {
      'id': 'abono_ferias',
      'keywords': [
        'vender férias',
        'abono de férias',
        'converter férias',
        '1/3 férias dinheiro',
      ],
      'tema': 'Abono de Férias (Vender Férias)',
      'artigo': 'Art. 143 da CLT',
      'resposta':
          '**ABONO DE FÉRIAS - VENDER FÉRIAS (Art. 143 da CLT)**\n\n'
          'O empregado pode converter (vender) até **1/3 do período de férias** a que tiver direito em abono pecuniário.\n\n'
          '📌 **Como funciona:**\n'
          '• Você vende parte das férias (até 10 dias, se tem 30 dias)\n'
          '• Recebe o valor correspondente a esses dias em dinheiro\n'
          '• As férias restantes devem ser gozadas (mínimo de 20 dias)\n\n'
          '📌 **Prazo para requerer:**\n'
          'Até **15 dias antes do término do período aquisitivo**.\n\n'
          '📌 **Férias coletivas:**\n'
          'A conversão deve ser objeto de acordo coletivo entre empresa e sindicato.\n\n'
          '⚠️ **Não se aplica a regime de tempo parcial.**\n\n'
          '✅ **Base legal:** Art. 143 da CLT.',
    },

    // ============================================================
    // 5. SALÁRIO E ADICIONAIS (Arts. 76, 78, 192, 193, 457, 458, 459, 461, 462)
    // ============================================================
    {
      'id': 'salario_minimo',
      'keywords': [
        'salário mínimo',
        'salario minimo',
        'valor do salário',
        'quanto é o mínimo',
        '1621',
      ],
      'tema': 'Salário Mínimo',
      'artigo': 'Art. 76 da CLT',
      'resposta':
          '**SALÁRIO MÍNIMO (Art. 76 da CLT)**\n\n'
          'O salário mínimo é a contraprestação básica devida e paga diretamente pelo empregador a todo trabalhador por um dia normal de serviço.\n\n'
          '📌 **Valor nacional 2026:** **R\$ 1.621,00** (Conforme Decreto nº 12.797/2025).\n\n'
          '📌 **Finalidade:**\n'
          'Deve ser capaz de satisfazer as necessidades básicas de:\n'
          '• Alimentação, Habitação, Vestuário, Higiene e Transporte.\n\n'
          '⚠️ **Atenção:** É nulo qualquer contrato que estipule remuneração inferior ao salário mínimo vigente (Art. 117 da CLT).\n\n'
          '✅ **Base legal:** Arts. 76 e 117 da CLT.',
    },
    {
      'id': 'salario_empreitada',
      'keywords': [
        'empreitada',
        'tarefa',
        'por produção',
        'comissão',
        'salário variável',
      ],
      'tema': 'Salário por Empreitada/Tarefa',
      'artigo': 'Art. 78 da CLT',
      'resposta':
          '**SALÁRIO POR EMPREITADA OU TAREFA (Art. 78 da CLT)**\n\n'
          'Quando o salário for ajustado por empreitada, tarefa ou peça, será garantida ao trabalhador uma remuneração diária **nunca inferior ao salário mínimo**.\n\n'
          '📌 **Empregado à comissão (parágrafo único):**\n'
          '• Se o salário for integrado por parte fixa e parte variável (comissões)\n'
          '• Ser-lhe-á sempre garantido o salário mínimo\n'
          '• É vedado qualquer desconto em mês subsequente a título de compensação\n\n'
          '⚠️ **Importante:**\n'
          'Se no mês as comissões forem baixas, o empregador deve complementar até o salário mínimo.\n'
          'A diferença NÃO pode ser descontada nos meses seguintes.\n\n'
          '✅ **Base legal:** Art. 78 da CLT.',
    },
    {
      'id': 'insalubridade',
      'keywords': [
        'insalubridade',
        'adicional de insalubridade',
        'agente nocivo',
        'grau insalubridade',
        '10% 20% 40%',
      ],
      'tema': 'Adicional de Insalubridade',
      'artigo': 'Art. 192 da CLT',
      'resposta':
          '**ADICIONAL DE INSALUBRIDADE (Art. 192 da CLT)**\n\n'
          'O adicional de insalubridade é pago a quem trabalha exposto a agentes nocivos à saúde acima dos limites de tolerância.\n\n'
          '📌 **Percentuais sobre o SALÁRIO MÍNIMO:**\n'
          '• **Grau máximo:** 40%\n'
          '• **Grau médio:** 20%\n'
          '• **Grau mínimo:** 10%\n\n'
          '📌 **Como comprovar:**\n'
          'É necessária **perícia** de Médico do Trabalho ou Engenheiro do Trabalho (Art. 195).\n\n'
          '📌 **Cessação do direito (Art. 194):**\n'
          'O direito ao adicional cessa com a eliminação do risco à saúde, seja por:\n'
          '• Medidas de proteção coletiva\n'
          '• Uso de EPI eficaz\n'
          '• Mudança de função\n\n'
          '✅ **Base legal:** Arts. 189 a 195 da CLT.',
    },
    {
      'id': 'periculosidade',
      'keywords': [
        'periculosidade',
        'adicional de periculosidade',
        'inflamáveis',
        'eletricidade',
        'segurança',
        'motoboy',
      ],
      'tema': 'Adicional de Periculosidade',
      'artigo': 'Art. 193 da CLT',
      'resposta':
          '**ADICIONAL DE PERICULOSIDADE (Art. 193 da CLT)**\n\n'
          'São consideradas atividades perigosas aquelas que impliquem risco acentuado em virtude de exposição permanente do trabalhador a:\n\n'
          '📌 **Atividades que geram o adicional:**\n'
          '• Inflamáveis e explosivos\n'
          '• Energia elétrica (alta tensão)\n'
          '• Roubos ou violência física (segurança pessoal/patrimonial)\n'
          '• Trabalhador em **motocicleta (motoboy)** - Lei 12.997/2014\n\n'
          '💰 **Valor do adicional:** **30%** sobre o salário base (sem gratificações, prêmios ou participação nos lucros).\n\n'
          '⚠️ **Insalubridade vs Periculosidade:**\n'
          'O empregado pode optar pelo adicional de insalubridade ou periculosidade (o que for mais vantajoso), não podendo acumular ambos.\n\n'
          '✅ **Base legal:** Art. 193 da CLT.',
    },
    {
      'id': 'gorjetas',
      'keywords': [
        'gorjeta',
        'garçom',
        '10%',
        'taxa de serviço',
        'adicional de gorjeta',
      ],
      'tema': 'Gorjetas',
      'artigo': 'Art. 457 da CLT',
      'resposta':
          '**GORJETAS (Art. 457 da CLT)**\n\n'
          'As gorjetas integram a remuneração do empregado para todos os efeitos legais.\n\n'
          '📌 **O que é considerado gorjeta (Art. 457, §3º):**\n'
          '• Importância espontaneamente dada pelo cliente ao empregado\n'
          '• Valor cobrado pela empresa ao cliente como adicional nas contas (ex: 10% de serviço)\n'
          '• Destinada à distribuição aos empregados\n\n'
          '📌 **Impacto da gorjeta:**\n'
          '• Integra a base de cálculo do FGTS\n'
          '• Integra a base de cálculo do 13º salário\n'
          '• Integra a base de cálculo das férias\n'
          '• NÃO integra a base de cálculo do INSS? (verificar legislação específica)\n\n'
          '⚠️ **Atenção:** A Lei 13.419/2017 trouxe novas regras sobre a distribuição de gorjetas.\n\n'
          '✅ **Base legal:** Art. 457 e 458 da CLT.',
    },
    {
      'id': 'salario_utilidade',
      'keywords': [
        'salário in natura',
        'vale-transporte',
        'vale-alimentação',
        'plano de saúde',
        'salário-utilidade',
      ],
      'tema': 'Salário-Utilidade',
      'artigo': 'Art. 458 da CLT',
      'resposta':
          '**SALÁRIO-UTILIDADE (Art. 458 da CLT)**\n\n'
          'Além do pagamento em dinheiro, compreende-se no salário a alimentação, habitação, vestuário ou outras prestações **in natura** fornecidas habitualmente pela empresa.\n\n'
          '📌 **O que NÃO é salário-utilidade (Art. 458, §2º):**\n'
          '• Vestuários e EPIs utilizados no local de trabalho\n'
          '• Educação em estabelecimento de ensino (mensalidade, livros)\n'
          '• Transporte para deslocamento trabalho-casa\n'
          '• Assistência médica, hospitalar e odontológica\n'
          '• Seguros de vida e acidentes pessoais\n'
          '• Previdência privada\n'
          '• Vale-cultura\n\n'
          '⚠️ **Limites (Art. 458, §3º):**\n'
          '• Habitação: não pode exceder 25% do salário-contratual\n'
          '• Alimentação: não pode exceder 20% do salário-contratual\n\n'
          '✅ **Base legal:** Art. 458 da CLT.',
    },
    {
      'id': 'pagamento_salario',
      'keywords': [
        'pagamento salário',
        '5º dia útil',
        'quando pagar salário',
        'atraso salário',
      ],
      'tema': 'Pagamento do Salário',
      'artigo': 'Art. 459 da CLT',
      'resposta':
          '**PAGAMENTO DO SALÁRIO (Art. 459 da CLT)**\n\n'
          'O pagamento do salário não deve ser estipulado por período superior a **1 mês**.\n\n'
          '📌 **Prazo para pagamento (Art. 459, §1º):**\n'
          'Quando o pagamento for estipulado por mês, deverá ser efetuado o mais tardar até o **5º dia útil do mês subsequente ao vencido**.\n\n'
          '⚠️ **Consequência do atraso:**\n'
          '• O atraso no pagamento do salário constitui infração administrativa\n'
          '• Pode gerar multa e rescisão indireta do contrato (Art. 483, d)\n'
          '• O empregado pode pleitear rescisão indireta com todas as verbas de uma demissão sem justa causa\n\n'
          '✅ **Base legal:** Art. 459 da CLT.',
    },
    {
      'id': 'igualdade_salarial',
      'keywords': [
        'igualdade salarial',
        'mesmo salário',
        'discriminação salarial',
        'art 461',
        'isonomia',
      ],
      'tema': 'Igualdade Salarial',
      'artigo': 'Art. 461 da CLT',
      'resposta':
          '**IGUALDADE SALARIAL (Art. 461 da CLT)**\n\n'
          'Sendo idêntica a função, a todo trabalho de igual valor, prestado ao mesmo empregador na mesma localidade, corresponderá **igual salário**, sem distinção de sexo, nacionalidade ou idade.\n\n'
          '📌 **Trabalho de igual valor (Art. 461, §1º):**\n'
          '• Feito com igual produtividade\n'
          '• Com a mesma perfeição técnica\n'
          '• Diferença de tempo de serviço ≤ 2 anos\n\n'
          '📌 **Exceção (Art. 461, §2º):**\n'
          'Não se aplica quando o empregador tem quadro de carreira (promoção por antiguidade e merecimento).\n\n'
          '📌 **Trabalhador readaptado (Art. 461, §4º):**\n'
          'O trabalhador readaptado por deficiência física ou mental não serve de paradigma.\n\n'
          '✅ **Base legal:** Art. 461 da CLT.',
    },
    {
      'id': 'descontos_salariais',
      'keywords': [
        'desconto salário',
        'pode descontar',
        'desconto dano',
        'vale adiantamento',
      ],
      'tema': 'Descontos Salariais',
      'artigo': 'Art. 462 da CLT',
      'resposta':
          '**DESCONTOS SALARIAIS (Art. 462 da CLT)**\n\n'
          'É vedado ao empregador efetuar qualquer desconto nos salários do empregado, **salvo**:\n\n'
          '📌 **Exceções permitidas:**\n'
          '• Adiantamentos (vale)\n'
          '• Dispositivos de lei (ex: IRRF, INSS, pensão alimentícia)\n'
          '• Contrato coletivo\n'
          '• Dano causado pelo empregado (desde que acordado ou com dolo)\n\n'
          '⚠️ **Proibições específicas (Art. 462, §2º):**\n'
          '• Empresa que mantém armazém para venda de mercadorias NÃO pode coagir empregado a comprar lá\n'
          '• Empresa NÃO pode limitar liberdade do empregado de dispor do salário\n\n'
          '✅ **Base legal:** Art. 462 da CLT.',
    },

    // ============================================================
    // 6. RESCISÃO (Arts. 477, 478, 479, 480, 482, 483, 484, 487, 488)
    // ============================================================
    {
      'id': 'verbas_rescisorias',
      'keywords': [
        'rescisão',
        'demissão',
        'quanto vou receber',
        'verbas rescisórias',
        'cálculo rescisão',
        'sem justa causa',
      ],
      'tema': 'Verbas Rescisórias (Sem Justa Causa)',
      'artigo': 'Art. 477 da CLT',
      'resposta':
          '**VERBAS RESCISÓRIAS - DISPENSA SEM JUSTA CAUSA (Art. 477 da CLT)**\n\n'
          '✅ **Verbas devidas:**\n\n'
          '1️⃣ **Saldo de salário** (dias trabalhados no mês da demissão)\n'
          '2️⃣ **Aviso prévio** (indenizado ou trabalhado) - 30 dias + 3 dias/ano\n'
          '3️⃣ **13º salário proporcional** (meses trabalhados no ano)\n'
          '4️⃣ **Férias vencidas + 1/3** (se houver)\n'
          '5️⃣ **Férias proporcionais + 1/3**\n'
          '6️⃣ **Saque total do FGTS**\n'
          '7️⃣ **Multa de 40% sobre o FGTS**\n'
          '8️⃣ **Seguro-desemprego** (requisitos)\n\n'
          '📌 **Prazo para pagamento (Art. 477, §6º):**\n'
          '• Com aviso prévio trabalhado: até 1º dia útil após o término\n'
          '• Com aviso indenizado: até 10 dias após a notificação\n\n'
          '⚠️ **Homologação (Art. 477, §1º):**\n'
          'Para empregados com mais de 1 ano de serviço, o recibo deve ser homologado pelo sindicato ou Ministério do Trabalho.\n\n'
          '✅ **Base legal:** Art. 477 da CLT.\n\n'
          '🧮 **Use a CALCULADORA TRABALHISTA para calcular os valores exatos!**',
    },
    {
      'id': 'indenizacao_tempo_servico',
      'keywords': [
        'indenização tempo de serviço',
        '1 mês por ano',
        'estabilidade decenal',
      ],
      'tema': 'Indenização por Tempo de Serviço',
      'artigo': 'Art. 478 da CLT',
      'resposta':
          '**INDENIZAÇÃO POR TEMPO DE SERVIÇO (Art. 478 da CLT)**\n\n'
          '⚠️ **Atenção:** Este artigo trata da antiga estabilidade decenal (10 anos).\n\n'
          'Atualmente, a estabilidade decenal foi revogada pela Constituição de 1988, que instituiu o FGTS como regime geral.\n\n'
          '📌 **O que vigora hoje:**\n'
          '• FGTS com multa de 40% para demissão sem justa causa\n'
          '• Aviso prévio proporcional (Lei 12.506/2011)\n'
          '• Indenização adicional para dispensas sem justa causa (Art. 9º da Lei 7.238/84)\n\n'
          '📌 **Mantém-se aplicável para contratos anteriores à CF/88?**\n'
          '• Sim, em situações muito específicas de contratos antigos.\n'
          '• Para contratos regidos pela CF/88, aplica-se o regime do FGTS.\n\n'
          '✅ **Base legal:** Art. 478 da CLT (redação original).',
    },
    {
      'id': 'justa_causa_detalhado',
      'keywords': [
        'justa causa motivos',
        'falta grave exemplos',
        'demissão por justa causa motivos',
      ],
      'tema': 'Justa Causa - Detalhamento',
      'artigo': 'Art. 482 da CLT',
      'resposta':
          '**JUSTA CAUSA - MOTIVOS PREVISTOS NO ART. 482 DA CLT**\n\n'
          'O empregador pode dispensar o empregado por justa causa nos seguintes casos:\n\n'
          '❌ **a) Ato de improbidade** (roubo, furto, apropriação indébita)\n'
          '❌ **b) Incontinência de conduta ou mau procedimento** (atitude imoral)\n'
          '❌ **c) Negociação habitual por conta própria** (concorrência)\n'
          '❌ **d) Condenação criminal** (passada em julgado, sem suspensão)\n'
          '❌ **e) Desídia** (preguiça, falta de interesse no trabalho)\n'
          '❌ **f) Embriaguez habitual ou em serviço**\n'
          '❌ **g) Violação de segredo da empresa**\n'
          '❌ **h) Indisciplina ou insubordinação** (desobedecer ordens)\n'
          '❌ **i) Abandono de emprego** (ausência injustificada)\n'
          '❌ **j) Ato lesivo da honra contra qualquer pessoa no serviço**\n'
          '❌ **k) Ato lesivo da honra contra empregador ou superiores**\n'
          '❌ **l) Prática constante de jogos de azar**\n\n'
          '⚠️ **Consequências:** Perde aviso prévio, 13º proporcional, férias proporcionais, multa FGTS, saque FGTS e seguro-desemprego.\n\n'
          '✅ **Base legal:** Art. 482 da CLT.',
    },
    {
      'id': 'rescisao_indireta',
      'keywords': [
        'rescisão indireta',
        'justa causa do empregador',
        'pedir demissão com direitos',
      ],
      'tema': 'Rescisão Indireta',
      'artigo': 'Art. 483 da CLT',
      'resposta':
          '**RESCISÃO INDIRETA (Art. 483 da CLT)**\n\n'
          'O empregado pode considerar rescindido o contrato e pleitear indenização (como se fosse demissão sem justa causa) quando:\n\n'
          '✅ **Motivos:**\n'
          'a) Exigirem serviços superiores às suas forças ou ilegais\n'
          'b) For tratado com rigor excessivo\n'
          'c) Correr perigo manifesto de mal considerável\n'
          'd) Empregador não cumprir as obrigações do contrato (ex: atraso salarial)\n'
          'e) Empregador praticar ato lesivo à honra\n'
          'f) Empregador ofender fisicamente\n'
          'g) Empregador reduzir o trabalho (peça/tarefa) afetando salário\n\n'
          '📌 **Efeitos:**\n'
          'O empregado tem direito a todas as verbas de uma demissão sem justa causa (aviso prévio, 13º proporcional, férias proporcionais + 1/3, multa FGTS, saque FGTS).\n\n'
          '✅ **Base legal:** Art. 483 da CLT.',
    },
    {
      'id': 'culpa_reciproca',
      'keywords': [
        'culpa recíproca',
        'culpa de ambos',
        'demissão por culpa dos dois',
      ],
      'tema': 'Culpa Recíproca',
      'artigo': 'Art. 484 da CLT',
      'resposta':
          '**CULPA RECÍPROCA NA RESCISÃO (Art. 484 da CLT)**\n\n'
          'Ocorre quando ambas as partes (empregado e empregador) têm culpa no ato que determinou a rescisão do contrato de trabalho.\n\n'
          '📌 **Consequência:**\n'
          'O tribunal reduzirá a indenização à que seria devida em caso de culpa exclusiva do empregador, **por metade**.\n\n'
          '📌 **Exemplo prático:**\n'
          '• Em uma briga no trabalho onde ambos se agridem\n'
          '• Empregado falta e empresa também descumpre obrigações\n\n'
          '⚖️ **Resultado:**\n'
          'O empregado recebe metade das verbas que teria direito em uma demissão sem justa causa.\n\n'
          '✅ **Base legal:** Art. 484 da CLT.',
    },

    // ============================================================
    // 7. ESTABILIDADE (Arts. 492, 499, 165, 391-A)
    // ============================================================
    {
      'id': 'estabilidade_decenal',
      'keywords': [
        'estabilidade decenal',
        '10 anos de empresa',
        'estabilidade 10 anos',
      ],
      'tema': 'Estabilidade Decenal',
      'artigo': 'Art. 492 da CLT',
      'resposta':
          '**ESTABILIDADE DECENAL (Art. 492 da CLT)**\n\n'
          '⚠️ **Atenção:** Este artigo foi **revogado tacitamente pela Constituição Federal de 1988**, que instituiu o regime do FGTS.\n\n'
          '📌 **O que dizia o artigo (histórico):**\n'
          'O empregado que contar mais de 10 anos de serviço na mesma empresa não poderia ser despedido senão por falta grave ou força maior.\n\n'
          '📌 **Situação atual:**\n'
          '• Para contratos iniciados a partir de 05/10/1988, aplica-se o FGTS\n'
          '• Não há mais estabilidade decenal automática\n'
          '• Existem apenas estabilidades provisórias (gestante, CIPA, acidente, dirigente sindical)\n\n'
          '⚠️ **Exceção:**\n'
          'Empregados admitidos antes da CF/88 e que optaram pelo regime anterior podem ter direito adquirido.\n\n'
          '✅ **Base legal:** Art. 492 da CLT (histórico).',
    },
    {
      'id': 'cargo_confianca_estabilidade',
      'keywords': [
        'cargo de confiança estabilidade',
        'gerente perde estabilidade',
        'art 499',
      ],
      'tema': 'Cargo de Confiança e Estabilidade',
      'artigo': 'Art. 499 da CLT',
      'resposta':
          '**CARGO DE CONFIANÇA E ESTABILIDADE (Art. 499 da CLT)**\n\n'
          'Não haverá estabilidade no exercício dos cargos de:\n'
          '• Diretoria\n'
          '• Gerência\n'
          '• Outros cargos de confiança imediata do empregador\n\n'
          '📌 **Ressalva:**\n'
          'O tempo de serviço nesses cargos é computado para todos os efeitos legais.\n\n'
          '📌 **Reversão ao cargo efetivo (Art. 499, §1º):**\n'
          'Ao empregado estável que deixar de exercer cargo de confiança, é assegurada a reversão ao cargo efetivo anterior (salvo falta grave).\n\n'
          '📌 **Indenização (Art. 499, §2º):**\n'
          'Se despedido sem justa causa, empregado que só exerceu cargo de confiança e tem mais de 10 anos de serviço → indenização proporcional.\n\n'
          '✅ **Base legal:** Art. 499 da CLT.',
    },
    {
      'id': 'estabilidade_cipa',
      'keywords': [
        'cipa',
        'estabilidade cipa',
        'comissão interna de prevenção de acidentes',
        'membro cipa estabilidade',
      ],
      'tema': 'Estabilidade do Membro da CIPA',
      'artigo': 'Art. 165 da CLT',
      'resposta':
          '**ESTABILIDADE DO MEMBRO DA CIPA (Art. 165 da CLT)**\n\n'
          'Os titulares da representação dos empregados nas CIPAs não poderão sofrer **despedida arbitrária**.\n\n'
          '📌 **Entende-se como despedida arbitrária:**\n'
          '• A que não se fundar em motivo disciplinar\n'
          '• A que não se fundar em motivo técnico\n'
          '• A que não se fundar em motivo econômico\n'
          '• A que não se fundar em motivo financeiro\n\n'
          '📌 **Prazo da estabilidade (Súmula 339 do TST):**\n'
          'Desde o registro da candidatura até **1 ano após o término do mandato** (para eleitos).\n\n'
          '⚠️ **Ônus da prova (Art. 165, parágrafo único):**\n'
          'Caberá ao empregador comprovar a existência dos motivos para a dispensa.\n\n'
          '✅ **Base legal:** Art. 165 da CLT.',
    },
    {
      'id': 'estabilidade_gestante',
      'keywords': [
        'gestante',
        'gravidez',
        'estabilidade gestante',
        'licença maternidade',
        '391-a',
      ],
      'tema': 'Estabilidade da Gestante',
      'artigo': 'Art. 391-A da CLT',
      'resposta':
          '**ESTABILIDADE DA GESTANTE (Art. 391-A da CLT)**\n\n'
          'A confirmação do estado de gravidez, ainda que durante o prazo do aviso prévio trabalhado ou indenizado, garante à empregada gestante a **estabilidade provisória**.\n\n'
          '📌 **Prazo da estabilidade:**\n'
          'Desde a confirmação da gravidez até **5 meses após o parto** (Art. 10, II, "b" do ADCT).\n\n'
          '🤰 **Direitos garantidos:**\n'
          '• Não pode ser demitida sem justa causa durante esse período\n'
          '• Se demitida, deve ser reintegrada ou indenizada\n'
          '• A estabilidade vale mesmo no aviso prévio\n'
          '• Aplica-se também em caso de aborto não criminoso (Art. 395)\n\n'
          '✅ **Base legal:** Art. 391-A da CLT (Lei 12.812/2013).',
    },

    // ============================================================
    // 8. SAÚDE E SEGURANÇA (Arts. 154, 157, 158, 162, 163, 166, 168)
    // ============================================================
    {
      'id': 'seguranca_trabalho_empresa',
      'keywords': [
        'segurança do trabalho',
        'obrigações da empresa',
        'nr',
        'normas regulamentadoras',
      ],
      'tema': 'Segurança do Trabalho - Obrigações da Empresa',
      'artigo': 'Arts. 154 e 157 da CLT',
      'resposta':
          '**SEGURANÇA DO TRABALHO - OBRIGAÇÕES DA EMPRESA (Arts. 154 e 157)**\n\n'
          'A empresa deve:\n\n'
          '✅ **Art. 157:**\n'
          '• Cumprir e fazer cumprir as normas de segurança e medicina do trabalho\n'
          '• Instruir os empregados sobre precauções para evitar acidentes\n'
          '• Adotar as medidas determinadas pelo órgão regional competente\n'
          '• Facilitar o exercício da fiscalização\n\n'
          '✅ **Art. 154:**\n'
          'A observância das normas da CLT não desobriga a empresa de cumprir:\n'
          '• Códigos de obras\n'
          '• Regulamentos sanitários estaduais/municipais\n'
          '• Convenções coletivas de trabalho\n\n'
          '⚠️ **Fiscalização:** Delegacias Regionais do Trabalho (Art. 156).\n\n'
          '✅ **Base legal:** Arts. 154 a 157 da CLT.',
    },
    {
      'id': 'seguranca_trabalho_empregado',
      'keywords': [
        'deveres do empregado',
        'obrigações empregado segurança',
        'uso epi obrigatório',
      ],
      'tema': 'Segurança do Trabalho - Obrigações do Empregado',
      'artigo': 'Art. 158 da CLT',
      'resposta':
          '**SEGURANÇA DO TRABALHO - OBRIGAÇÕES DO EMPREGADO (Art. 158)**\n\n'
          'Cabe aos empregados:\n\n'
          '✅ **Obrigações:**\n'
          '• Observar as normas de segurança e medicina do trabalho\n'
          '• Observar as instruções expedidas pelo empregador\n'
          '• Colaborar com a empresa na aplicação dos dispositivos de segurança\n\n'
          '⚠️ **Ato faltoso (parágrafo único):**\n'
          'Constitui ato faltoso do empregado a recusa injustificada:\n'
          '• À observância das instruções do empregador\n'
          '• Ao uso dos equipamentos de proteção individual (EPIs) fornecidos pela empresa\n\n'
          '📌 **Consequência:** A recusa pode configurar justa causa.\n\n'
          '✅ **Base legal:** Art. 158 da CLT.',
    },
    {
      'id': 'servicos_especializados',
      'keywords': [
        'sesmt',
        'engenheiro segurança',
        'médico trabalho',
        'serviços especializados segurança',
      ],
      'tema': 'Serviços Especializados em Segurança (SESMT)',
      'artigo': 'Art. 162 da CLT',
      'resposta':
          '**SERVIÇOS ESPECIALIZADOS EM SEGURANÇA (SESMT) - Art. 162**\n\n'
          'As empresas são obrigadas a manter serviços especializados em segurança e medicina do trabalho.\n\n'
          '📌 **Normas estabelecidas pelo Ministério do Trabalho definem:**\n'
          '• Classificação das empresas (número de empregados e grau de risco)\n'
          '• Número mínimo de profissionais especializados\n'
          '• Qualificação exigida para os profissionais\n'
          '• Regime de trabalho\n'
          '• Demais atribuições dos serviços\n\n'
          '📌 **Profissionais envolvidos:**\n'
          '• Engenheiro de Segurança do Trabalho\n'
          '• Médico do Trabalho\n'
          '• Técnico de Segurança do Trabalho\n'
          '• Enfermeiro do Trabalho\n'
          '• Auxiliar de Enfermagem do Trabalho\n\n'
          '✅ **Base legal:** Art. 162 da CLT.',
    },
    {
      'id': 'cipa',
      'keywords': [
        'cipa',
        'comissão interna',
        'prevenção acidentes',
        'como funciona cipa',
      ],
      'tema': 'CIPA - Comissão Interna de Prevenção de Acidentes',
      'artigo': 'Art. 163 da CLT',
      'resposta':
          '**CIPA - COMISSÃO INTERNA DE PREVENÇÃO DE ACIDENTES (Art. 163)**\n\n'
          'A CIPA é obrigatória nos estabelecimentos conforme especificado pelo Ministério do Trabalho.\n\n'
          '📌 **Composição (Art. 164):**\n'
          '• Metade representantes da empresa (designados pelo empregador)\n'
          '• Metade representantes dos empregados (eleitos em escrutínio secreto)\n\n'
          '📌 **Mandato (Art. 164, §3º):**\n'
          '• Duração de **1 ano**\n'
          '• Permitida uma reeleição\n\n'
          '📌 **Estabilidade (Art. 165):**\n'
          'Os titulares não podem sofrer despedida arbitrária desde o registro da candidatura até 1 ano após o mandato.\n\n'
          '✅ **Base legal:** Arts. 163 a 165 da CLT.',
    },
    {
      'id': 'epi',
      'keywords': [
        'epi',
        'equipamento proteção individual',
        'fornecimento epi',
        'luvas óculos máscara',
      ],
      'tema': 'Equipamento de Proteção Individual (EPI)',
      'artigo': 'Art. 166 da CLT',
      'resposta':
          '**EQUIPAMENTO DE PROTEÇÃO INDIVIDUAL (EPI) - Art. 166**\n\n'
          'A empresa é **obrigada a fornecer gratuitamente** EPI adequado ao risco, em perfeito estado de conservação e funcionamento.\n\n'
          '📌 **Quando fornecer:**\n'
          'Sempre que as medidas de ordem geral não ofereçam completa proteção contra:\n'
          '• Riscos de acidentes\n'
          '• Danos à saúde dos empregados\n\n'
          '📌 **Obrigações do empregador (Art. 158):**\n'
          '• Fornecer o EPI (Art. 166)\n'
          '• Exigir o uso\n\n'
          '⚠️ **Recusa do empregado (Art. 158, parágrafo único):**\n'
          '• Recusa injustificada = ato faltoso\n'
          '• Pode configurar justa causa\n\n'
          '✅ **Base legal:** Art. 166 da CLT.',
    },
    {
      'id': 'exames_medicos',
      'keywords': [
        'exame admissional',
        'exame demissional',
        'exame periódico',
        'aso',
        'exame médico obrigatório',
      ],
      'tema': 'Exames Médicos Obrigatórios',
      'artigo': 'Art. 168 da CLT',
      'resposta':
          '**EXAMES MÉDICOS OBRIGATÓRIOS (Art. 168 da CLT)**\n\n'
          'Exames médicos por conta do empregador:\n\n'
          '✅ **Exames obrigatórios:**\n'
          '1️⃣ **Admissional** (antes de começar a trabalhar)\n'
          '2️⃣ **Periódico** (regularmente, conforme o risco)\n'
          '3️⃣ **Demissional** (na rescisão do contrato)\n\n'
          '📌 **Exames complementares (a critério médico):**\n'
          'Para apuração de capacidade ou aptidão física/mental para a função.\n\n'
          '📌 **Motoristas profissionais (Art. 168, §6º):**\n'
          '• Exames toxicológicos na admissão e no desligamento\n'
          '• Janela de detecção mínima de 90 dias\n'
          '• Confidencialidade dos resultados\n\n'
          '✅ **Base legal:** Art. 168 da CLT.',
    },

    // ============================================================
    // 9. PROTEÇÃO ESPECIAL (Art. 392, Arts. 403-408, Arts. 428-433)
    // ============================================================
    {
      'id': 'licenca_maternidade',
      'keywords': [
        'licença maternidade',
        '120 dias',
        'salário maternidade',
        'afastamento gestante',
      ],
      'tema': 'Licença-Maternidade',
      'artigo': 'Art. 392 da CLT',
      'resposta':
          '**LICENÇA-MATERNIDADE (Art. 392 da CLT)**\n\n'
          'A empregada gestante tem direito à licença-maternidade de **120 dias**, sem prejuízo do emprego e do salário.\n\n'
          '📌 **Período de afastamento (Art. 392, §1º):**\n'
          '• Pode começar entre o 28º dia antes do parto e a data do parto\n'
          '• Em caso de parto antecipado, mantém-se os 120 dias (Art. 392, §3º)\n\n'
          '📌 **Aumento do período (Art. 392, §2º):**\n'
          'Pode ser aumentado em 2 semanas antes e 2 semanas depois do parto, mediante atestado médico.\n\n'
          '📌 **Adoção ou guarda judicial (Art. 392-A):**\n'
          '• Também tem direito à licença-maternidade\n'
          '• Concedida mediante apresentação do termo judicial de guarda\n\n'
          '✅ **Base legal:** Arts. 392 e 392-A da CLT.',
    },
    {
      'id': 'trabalho_menor',
      'keywords': [
        'menor',
        'trabalho adolescente',
        'menor de idade',
        'proibição trabalho menor',
        'aprendiz',
      ],
      'tema': 'Trabalho do Menor',
      'artigo': 'Arts. 402 a 408 da CLT',
      'resposta':
          '**TRABALHO DO MENOR (Arts. 402 a 408 da CLT)**\n\n'
          '📌 **Idades (Art. 402):**\n'
          '• Menor: 14 a 18 anos\n'
          '• Proibido trabalho para menores de **16 anos**\n'
          '• Exceção: aprendiz a partir de **14 anos**\n\n'
          '📌 **Proibições:**\n'
          '• Trabalho noturno (22h às 5h) para < 18 anos (Art. 404)\n'
          '• Locais perigosos ou insalubres (Art. 405, I)\n'
          '• Locais prejudiciais à moralidade (Art. 405, II)\n'
          'Trabalho em ruas/praças depende de autorização do Juiz de Menores (Art. 405, §2º)\n\n'
          '✅ **Base legal:** Arts. 402 a 408 da CLT.',
    },
    {
      'id': 'contrato_aprendizagem',
      'keywords': [
        'aprendiz',
        'aprendizagem',
        'contrato de aprendiz',
        'jovem aprendiz',
        'menor aprendiz',
      ],
      'tema': 'Contrato de Aprendizagem',
      'artigo': 'Arts. 428 a 433 da CLT',
      'resposta':
          '**CONTRATO DE APRENDIZAGEM (Arts. 428 a 433 da CLT)**\n\n'
          '📌 **Requisitos (Art. 428):**\n'
          '• Idade: 14 a 24 anos\n'
          '• Inscrição em programa de aprendizagem (teoria + prática)\n'
          '• Matrícula e frequência na escola (se não concluiu ensino médio)\n\n'
          '📌 **Duração (Art. 428, §3º):**\n'
          '• Máximo de **2 anos**\n'
          '• Exceção: aprendiz com deficiência (sem limite de idade)\n\n'
          '📌 **Jornada (Art. 432):**\n'
          '• Máximo 6 horas diárias\n'
          '• Se já completou ensino fundamental: até 8 horas (incluindo horas teóricas)\n\n'
          '📌 **Cota para empresas (Art. 429):**\n'
          '• Empresas com 7+ empregados: 5% a 15% de aprendizes\n'
          '• Entidades sem fins lucrativos estão dispensadas\n\n'
          '⚠️ **Salário mínimo hora garantido (Art. 428, §2º).**\n\n'
          '✅ **Base legal:** Arts. 428 a 433 da CLT.',
    },
  ];

  final insertedIds = <String>[];

  for (final article in articles) {
    final id = article['id'] as String;
    final docRef = collection.doc(id);

    await docRef.set(article, SetOptions(merge: true));
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw StateError('Falha ao criar/atualizar o documento: $id');
    }

    insertedIds.add(id);
    print('✅ Inserido/Atualizado: ${article['tema']} (${id})');
  }

  print(
    '✅ Knowledge Base atualizada com sucesso! Total: ${insertedIds.length} documentos (30 artigos).',
  );
}
