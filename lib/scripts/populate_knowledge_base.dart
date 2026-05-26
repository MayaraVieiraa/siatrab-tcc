import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await populateKnowledgeBase();
  print(
    '✅ Knowledge Base populada com sucesso! (Versão Explicativa + Calculadora)',
  );
}

Future<void> populateKnowledgeBase() async {
  final db = FirebaseFirestore.instance;
  final collection = db.collection('knowledge_base');

  final articles = [
    // ====================================================
    // 1. SAUDAÇÃO
    // ====================================================
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
      ],
      'tema': 'Boas-vindas',
      'artigo': 'N/A',
      'resposta':
          'Olá! Eu sou o **Assistente Trabalhista 2026**.\n\n'
          '💡 **Minha função é explicar as regras** da CLT e como as verbas rescisórias funcionam.\n'
          '🧮 **Quem faz os cálculos** é a **Calculadora Trabalhista** do sistema (basta preencher os dados lá).\n\n'
          '**Digite "Menu"** para ver os tópicos que posso explicar:\n'
          '- Dispensa sem Justa Causa\n'
          '- Pedido de Demissão\n'
          '- Acordo Comum (Art. 484-A)\n'
          '- Justa Causa\n'
          '- Como calcular Aviso Prévio\n'
          '- Como calcular Férias Proporcionais\n'
          '- Multa do FGTS\n'
          '- Trabalho em Feriados (2026)\n'
          '- e muito mais.\n\n'
          'Como posso ajudar?',
    },
    {
      'id': 'menu',
      'keywords': ['menu', 'ajuda', 'opções', 'help', 'o que fazer'],
      'tema': 'Menu Central',
      'artigo': 'N/A',
      'resposta':
          '📋 **MENU DE CONSULTAS TRABALHISTAS**\n\n'
          '**Tipos de Rescisão (explique a diferença):**\n'
          '➡️ Dispensa Sem Justa Causa\n'
          '➡️ Pedido de Demissão\n'
          '➡️ Acordo Comum (Art. 484-A)\n'
          '➡️ Demissão por Justa Causa\n\n'
          '**Verbas Rescisórias (explique como calcular):**\n'
          '➡️ Saldo de Salário\n'
          '➡️ Aviso Prévio (Lei 12.506/2011)\n'
          '➡️ 13º Salário Proporcional\n'
          '➡️ Férias Proporcionais + 1/3\n'
          '➡️ Multa do FGTS (40% ou 20%)\n'
          '➡️ Seguro-Desemprego\n\n'
          '**Legislação 2025/2026:**\n'
          '➡️ Trabalho em Feriados (Portaria 3.665)\n'
          '➡️ Licença Paternidade\n'
          '➡️ CPF no eSocial\n\n'
          '**Digite o termo desejado** (ex: "Acordo Comum" ou "Aviso Prévio").',
    },

    // ====================================================
    // 2. TIPOS DE RESCISÃO (EXPLICATIVO)
    // ====================================================
    {
      'id': 'sem_justa_causa',
      'keywords': [
        'sem justa causa',
        'demissão sem justa causa',
        'dispensa sem justa causa',
      ],
      'tema': 'Dispensa sem Justa Causa',
      'artigo': 'Art. 477 da CLT',
      'resposta':
          '**Dispensa SEM JUSTA CAUSA** (iniciativa do empregador)\n\n'
          'Esta modalidade garante o maior número de direitos ao trabalhador:\n\n'
          '✅ **Verbas devidas:**\n'
          '• Saldo de salário (dias trabalhados no mês)\n'
          '• Aviso prévio (30 dias + 3 dias por ano trabalhado)\n'
          '• 13º salário proporcional\n'
          '• Férias vencidas + 1/3 (se houver)\n'
          '• Férias proporcionais + 1/3\n'
          '• Saque total do FGTS\n'
          '• Multa de 40% sobre o FGTS\n'
          '• Seguro-desemprego (desde que cumpra os requisitos)\n\n'
          '🧮 **Use a CALCULADORA TRABALHISTA para saber os valores exatos do seu caso.**',
    },
    {
      'id': 'pedido_demissao',
      'keywords': [
        'pedido de demissão',
        'me demitir',
        'sair da empresa',
        'pedir as contas',
      ],
      'tema': 'Pedido de Demissão',
      'artigo': 'Art. 487 da CLT',
      'resposta':
          '**PEDIDO DE DEMISSÃO** (iniciativa do empregado)\n\n'
          '✅ **O que você recebe:**\n'
          '• Saldo de salário\n'
          '• 13º salário proporcional\n'
          '• Férias vencidas + 1/3 (se houver)\n'
          '• Férias proporcionais + 1/3\n\n'
          '❌ **O que você NÃO recebe:**\n'
          '• Aviso prévio (se não cumprir, a empresa pode descontar o valor)\n'
          '• Saque do FGTS (regra geral, exceto saque-aniversário)\n'
          '• Multa de 40% do FGTS\n'
          '• Seguro-desemprego\n\n'
          '⚠️ **Aviso prévio no pedido de demissão:**\n'
          'Você deve cumprir os 30 dias trabalhando. Se não cumprir, a empresa tem direito de descontar o valor equivalente da sua rescisão.\n\n'
          '🧮 **Use a CALCULADORA para ver quanto você vai receber de fato.**',
    },
    {
      'id': 'acordo_comum',
      'keywords': [
        'acordo comum',
        'rescisão amigável',
        '484-a',
        'art 484',
        'saída consensual',
      ],
      'tema': 'Rescisão por Acordo Comum',
      'artigo': 'Art. 484-A da CLT (Reforma Trabalhista)',
      'resposta':
          '**RESCISÃO POR ACORDO COMUM** (Art. 484-A da CLT)\n\n'
          'Criada pela Reforma Trabalhista, é a "saída amigável" onde empregado e empregador concordam em terminar o contrato.\n\n'
          '✅ **Verbas devidas:**\n'
          '• Saldo de salário (100%)\n'
          '• 13º salário proporcional (100%)\n'
          '• Férias vencidas + 1/3 (100%)\n'
          '• Férias proporcionais + 1/3 (100%)\n'
          '• Aviso prévio: se **indenizado**, paga-se **50%**; se **trabalhado**, paga-se 100%\n'
          '• Saque de **80%** do FGTS\n'
          '• Multa do FGTS de **20%** (metade da multa da dispensa sem justa causa)\n\n'
          '❌ **O que você NÃO recebe:**\n'
          '• Seguro-desemprego\n\n'
          '💡 **Vantagem:** O trabalhador que quer sair não perde totalmente o direito ao FGTS (como acontece no pedido de demissão).\n\n'
          '🧮 **Use a CALCULADORA para simular os valores do seu acordo.**',
    },
    {
      'id': 'justa_causa',
      'keywords': ['justa causa', 'demissão por justa causa', 'falta grave'],
      'tema': 'Demissão por Justa Causa',
      'artigo': 'Art. 482 da CLT',
      'resposta':
          '**DISPENSA POR JUSTA CAUSA** (penalidade máxima ao empregado)\n\n'
          'Ocorre quando o empregado comete uma **falta grave** prevista no Art. 482 da CLT. Exemplos:\n'
          '• Ato de improbidade (furto, roubo)\n'
          '• Abandono de emprego\n'
          '• Indisciplina ou insubordinação\n'
          '• Embriaguez habitual ou em serviço\n'
          '• Violação de segredo da empresa\n'
          '• Condenação criminal transitada em julgado\n\n'
          '✅ **O que você recebe (apenas):**\n'
          '• Saldo de salário\n'
          '• Férias vencidas + 1/3 (se houver)\n\n'
          '❌ **O que você PERDE:**\n'
          '• Aviso prévio\n'
          '• 13º salário proporcional\n'
          '• Férias proporcionais\n'
          '• Saque do FGTS\n'
          '• Multa de 40% do FGTS\n'
          '• Seguro-desemprego\n\n'
          '⚠️ **É uma penalidade grave.** A empresa precisa comprovar a falta em inquérito administrativo ou judicial.',
    },

    // ====================================================
    // 3. TABELA COMPARATIVA
    // ====================================================
    {
      'id': 'tabela_comparativa',
      'keywords': [
        'diferença rescisão',
        'comparação verbas',
        'tabela demissão',
        'qual tipo de demissão',
      ],
      'tema': 'Resumo Comparativo de Verbas',
      'artigo': 'Comparativo CLT',
      'resposta':
          '📊 **COMPARATIVO ENTRE OS TIPOS DE RESCISÃO**\n\n'
          '| Verba                | Sem Justa Causa | Pedido Demissão | Acordo Comum | Justa Causa |\n'
          '|----------------------|----------------|-----------------|--------------|-------------|\n'
          '| Saldo de Salário     | ✅ Sim         | ✅ Sim          | ✅ Sim       | ✅ Sim      |\n'
          '| Aviso Prévio         | ✅ Sim         | ⚠️ Desconta     | ⚠️ 50%       | ❌ Não      |\n'
          '| 13º Proporcional     | ✅ Sim         | ✅ Sim          | ✅ Sim       | ❌ Não      |\n'
          '| Férias Proporcionais | ✅ Sim         | ✅ Sim          | ✅ Sim       | ❌ Não      |\n'
          '| Férias Vencidas      | ✅ Sim         | ✅ Sim          | ✅ Sim       | ✅ Sim      |\n'
          '| Multa FGTS           | 40%            | 0%              | 20%          | 0%          |\n'
          '| Saque FGTS           | 100%           | ❌ Não          | 80%          | ❌ Não      |\n'
          '| Seguro-Desemprego    | ✅ Sim         | ❌ Não          | ❌ Não       | ❌ Não      |\n\n'
          '🧮 **Para calcular os valores exatos, utilize a CALCULADORA TRABALHISTA do sistema.**',
    },

    // ====================================================
    // 4. VERBAS INDIVIDUAIS (SÓ EXPLICA A FÓRMULA)
    // ====================================================
    {
      'id': 'aviso_previo',
      'keywords': [
        'aviso prévio',
        'calcular aviso prévio',
        'aviso proporcional',
        'lei 12506',
        'quantos dias aviso',
      ],
      'tema': 'Aviso Prévio',
      'artigo': 'Art. 487 da CLT + Lei 12.506/2011',
      'resposta':
          '**AVISO PRÉVIO**\n\n'
          'É a comunicação antecipada da rescisão do contrato.\n\n'
          '📆 **Como calcular o prazo (Lei 12.506/2011):**\n'
          '• Base: **30 dias**\n'
          '• Acréscimo: **+ 3 dias por ano completo trabalhado** na mesma empresa\n'
          '• Limite máximo: **90 dias** (30 + 60)\n\n'
          '🧮 **Fórmula do prazo:**\n'
          '`Dias de aviso = 30 + (3 × anos trabalhados)`\n\n'
          '💰 **Modalidades:**\n'
          '• **Trabalhado:** Você cumpre o expediente (com redução de 2h/dia ou 7 dias corridos de folga).\n'
          '• **Indenizado:** O empregador paga o valor, mas você não precisa trabalhar.\n\n'
          '🧮 **Para saber o VALOR do seu aviso prévio, use a CALCULADORA TRABALHISTA.**',
    },
    {
      'id': 'saldo_salario',
      'keywords': [
        'saldo de salário',
        'calcular saldo',
        'dias trabalhados',
        'rescisão dias',
      ],
      'tema': 'Saldo de Salário',
      'artigo': 'Art. 457 da CLT',
      'resposta':
          '**SALDO DE SALÁRIO**\n\n'
          'Corresponde aos dias que você **trabalhou no mês da rescisão**.\n\n'
          '🧮 **Como calcular:**\n'
          '`Saldo = (Salário mensal ÷ 30) × Dias trabalhados no mês`\n\n'
          '📌 **Exemplo:** Se você ganha R\$ 1.621,00 e trabalhou 15 dias no mês da demissão:\n'
          '• Valor por dia = R\$ 1.621 ÷ 30 = R\$ 54,03\n'
          '• Saldo de salário = 54,03 × 15 = R\$ 810,50\n\n'
          '✅ **Sobre ele incidem:** INSS (conforme tabela progressiva) e IRRF (se ultrapassar a faixa de isenção).\n\n'
          '🧮 **Use a CALCULADORA para simular o seu caso exato.**',
    },
    {
      'id': 'decimo_terceiro_proporcional',
      'keywords': [
        '13º proporcional',
        'décimo terceiro cálculo',
        'calcular 13º rescisão',
      ],
      'tema': '13º Salário Proporcional',
      'artigo': 'Lei 4.090/62',
      'resposta':
          '**13º SALÁRIO PROPORCIONAL**\n\n'
          'Na rescisão, você recebe o 13º proporcional aos meses trabalhados no ano.\n\n'
          '🧮 **Como calcular:**\n'
          '`13º proporcional = (Salário mensal ÷ 12) × Meses trabalhados no ano`\n\n'
          '📌 **Regra do mês trabalhado:**\n'
          '• Acima de **15 dias** no mês → conta como 1 mês cheio\n'
          '• Até 14 dias → não entra no cálculo\n\n'
          '⚠️ **Atenção:** Na demissão **sem justa causa**, o aviso prévio indenizado é projetado (conta como +1 mês para o 13º).\n\n'
          '❌ Na **justa causa**, você perde o 13º proporcional.\n\n'
          '🧮 **A CALCULADORA faz esse cálculo automaticamente.**',
    },
    {
      'id': 'ferias_proporcionais',
      'keywords': [
        'férias proporcionais',
        'calcular férias rescisão',
        '1/3 de férias',
        'terço constitucional',
      ],
      'tema': 'Férias Proporcionais + 1/3',
      'artigo': 'Arts. 130 e 146 da CLT + CF/88 Art. 7º',
      'resposta':
          '**FÉRIAS PROPORCIONAIS + 1/3 CONSTITUCIONAL**\n\n'
          'Você tem direito a férias proporcionais ao tempo trabalhado no período aquisitivo atual.\n\n'
          '🧮 **Como calcular (dois passos):**\n\n'
          '**Passo 1 - Calcular o valor das férias proporcionais:**\n'
          '`Férias = (Salário mensal ÷ 12) × Meses trabalhados`\n\n'
          '**Passo 2 - Adicionar o 1/3 constitucional:**\n'
          '`Total = Férias + (Férias ÷ 3)`\n\n'
          '📌 **Exemplo (salário R\$ 1.621,00, 6 meses de trabalho):**\n'
          '• Férias = (1.621 ÷ 12) × 6 = R\$ 810,50\n'
          '• 1/3 = 810,50 ÷ 3 = R\$ 270,17\n'
          '• Total = R\$ 1.080,67\n\n'
          '⚠️ Se você tiver **Férias Vencidas** (não gozou do período anterior), a empresa paga em dobro ou o valor cheio + 1/3.\n\n'
          '🧮 **Use a CALCULADORA para saber o valor exato das suas férias.**',
    },
    {
      'id': 'fgts_multa',
      'keywords': [
        'multa fgts',
        '40% fgts',
        '20% fgts',
        'calcular multa rescisão',
        'multa do FGTS',
      ],
      'tema': 'Multa do FGTS',
      'artigo': 'Lei 8.036/90 e Art. 484-A',
      'resposta':
          '**MULTA DO FGTS**\n\n'
          'A multa incide sobre o **saldo total da sua conta vinculada do FGTS** e é paga pelo empregador.\n\n'
          '📊 **Percentuais por tipo de rescisão:**\n'
          '• **Dispensa sem Justa Causa:** 40%\n'
          '• **Acordo Comum (Art. 484-A):** 20%\n'
          '• **Pedido de Demissão ou Justa Causa:** 0% (sem multa)\n\n'
          '🧮 **Como calcular:**\n'
          '`Multa = Saldo do FGTS × Percentual`\n\n'
          '📌 **Exemplo:** Se seu FGTS tem saldo de R\$ 3.500,00:\n'
          '• Demissão sem Justa Causa: Multa de R\$ 1.400,00 (40%)\n'
          '• Acordo Comum: Multa de R\$ 700,00 (20%)\n\n'
          '🧮 **A CALCULADORA usa o saldo informado por você para calcular a multa.**',
    },

    // ====================================================
    // 5. LEGISLAÇÃO ESPECÍFICA 2025-2026
    // ====================================================
    {
      'id': 'salario_minimo_2026',
      'keywords': [
        'salário mínimo 2026',
        'valor salário mínimo',
        'quanto é o salário mínimo 2026',
      ],
      'tema': 'Salário Mínimo 2026',
      'artigo': 'Decreto nº 12.797/2025',
      'resposta':
          '**SALÁRIO MÍNIMO 2026**\n\n'
          'De acordo com o **Decreto nº 12.797/2025**, o salário mínimo vigente a partir de **1º de janeiro de 2026** é de **R\$ 1.621,00**.\n\n'
          'Ele serve como base para:\n'
          '• Adicional de insalubridade (10%, 20%, 40%)\n'
          '• Piso salarial de categorias sem convenção coletiva\n'
          '• Limites para benefícios da Previdência Social\n'
          '• Cálculo de algumas verbas rescisórias\n\n'
          '🧮 **A CALCULADORA já usa este valor como referência automática.**',
    },
    {
      'id': 'trabalho_feriados',
      'keywords': [
        'trabalho em feriados',
        'domingo trabalhado',
        'hora extra 100%',
        'portaria 3665',
      ],
      'tema': 'Trabalho em Feriados',
      'artigo': 'Portaria nº 3.665/2023',
      'resposta':
          '**TRABALHO EM FERIADOS E DOMINGOS (2026)**\n\n'
          'A **Portaria nº 3.665/2023** entrou plenamente em vigor em março de 2026.\n\n'
          '📌 **Principais mudanças:**\n'
          '• Para o trabalhador do **comércio**, o trabalho em feriados só é permitido se **autorizado por Convenção Coletiva de Trabalho (CCT)**.\n'
          '• Se autorizado, o empregado tem direito ao **adicional de 100%** sobre a hora normal (ou percentual maior se a convenção assim determinar).\n\n'
          '📌 **Regra geral para horas extras (se não houver convenção específica):**\n'
          '• Dias úteis → adicional de **50%**\n'
          '• Domingos e feriados → adicional de **100%**\n\n'
          '💡 **Consulte o sindicato da sua categoria para ver o que foi acordado.**',
    },
    {
      'id': 'licenca_paternidade',
      'keywords': [
        'licença paternidade',
        'licença paternidade 2025',
        'dias de licença pai',
        'alta hospitalar',
      ],
      'tema': 'Licença Paternidade',
      'artigo': 'Leis nº 15.156 e 15.222/2025',
      'resposta':
          '**LICENÇA-PATERNIDADE (Mudanças 2025/2026)**\n\n'
          'A principal mudança é a forma de **contagem do prazo**.\n\n'
          '📌 **Nova regra:**\n'
          'O período da licença-paternidade (geralmente 5 a 20 dias, conforme a empresa) começa a contar **após a alta hospitalar da mãe ou do bebê**, caso haja internação.\n\n'
          'Isso garante que o pai possa estar efetivamente em casa após a família receber alta médica.\n\n'
          '✅ **Benefício:** Maior proteção à primeira infância e apoio à mãe no pós-parto imediato.\n\n'
          '📌 *Para servidores públicos e empresas que adotaram a regra, o prazo pode ser maior (ex: 20 dias). Verifique sua convenção coletiva.*',
    },
    {
      'id': 'cpf_esocial',
      'keywords': [
        'cpf rescisão',
        'esocial cpf',
        'identificador único',
        'documentação trabalho',
      ],
      'tema': 'CPF no eSocial',
      'artigo': 'Manual eSocial v. S-1.3',
      'resposta':
          '**CPF COMO IDENTIFICADOR ÚNICO (eSocial)**\n\n'
          'O sistema eSocial consolidou o uso do **CPF** como chave principal para todas as operações trabalhistas.\n\n'
          '📌 **O que muda na prática:**\n'
          '• Para **admissão, rescisão ou envio de processos trabalhistas** (eventos S-2299 e S-2500), o CPF é o único número necessário.\n'
          '• Extinguiu-se a necessidade de outros registros antigos (PIS, NIT, etc.) para identificação do trabalhador nesses sistemas.\n\n'
          '✅ **Vantagem:** Redução de erros e mais agilidade no processamento das verbas rescisórias e liberação do FGTS Digital.\n\n'
          '📌 **Vigência:** Obrigatório para processos trabalhistas via eSocial a partir de maio de 2026.',
    },
  ];

  for (final article in articles) {
    final id = article['id'] as String;
    await collection.doc(id).set(article, SetOptions(merge: true));
    print('✅ Inserido/Atualizado: ${article['tema']} (${id})');
  }
}
