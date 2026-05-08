import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await populateKnowledgeBase();
  print('✅ Knowledge Base populada com sucesso!');
}

Future<void> populateKnowledgeBase() async {
  final db = FirebaseFirestore.instance;
  final collection = db.collection('knowledge_base');

  final articles = [
    {
      'id': 'intervalo',
      'keywords': ['intervalo'],
      'tema': 'Intervalo Intrajornada',
      'artigo': 'Art. 71 da CLT',
      'resposta':
          'O intervalo intrajornada é o descanso obrigatório durante a jornada de trabalho.\n\n'
          '• Jornada acima de 6h → intervalo mínimo de 1 hora (máx. 2 horas)\n'
          '• Jornada entre 4h e 6h → intervalo de 15 minutos\n'
          '• Jornada até 4h → não é obrigatório intervalo\n\n'
          '⚠️ Se o intervalo não for concedido, o empregador deve pagar o período com acréscimo de 50% sobre a hora normal.\n\n'
          'Base legal: Art. 71 da CLT.',
    },
    {
      'id': 'ferias',
      'keywords': ['ferias'],
      'tema': 'Férias',
      'artigo': 'Arts. 129 e 130 da CLT',
      'resposta':
          'Todo empregado tem direito a férias anuais remuneradas após 12 meses de trabalho (período aquisitivo).\n\n'
          'Duração conforme faltas no período:\n'
          '• Até 5 faltas → 30 dias\n'
          '• 6 a 14 faltas → 24 dias\n'
          '• 15 a 23 faltas → 18 dias\n'
          '• 24 a 32 faltas → 12 dias\n\n'
          'O pagamento inclui o salário + 1/3 constitucional. As férias podem ser fracionadas em até 3 períodos por acordo.\n\n'
          'Base legal: Arts. 129 e 130 da CLT.',
    },
    {
      'id': 'fgts',
      'keywords': ['fgts'],
      'tema': 'FGTS',
      'artigo': 'Lei 8.036/90',
      'resposta':
          'O FGTS (Fundo de Garantia do Tempo de Serviço) corresponde a 8% do salário bruto mensal, depositado pelo empregador.\n\n'
          'Direito ao saque conforme tipo de desligamento:\n'
          '• Demissão sem justa causa → saque + multa de 40%\n'
          '• Acordo mútuo → saque + multa de 20%\n'
          '• Pedido de demissão → sem multa (saque bloqueado, exceto situações especiais)\n'
          '• Demissão por justa causa → sem multa e sem saque\n\n'
          'Base legal: Lei 8.036/90.',
    },
    {
      'id': 'inss',
      'keywords': ['inss'],
      'tema': 'INSS',
      'artigo': 'Tabela progressiva 2024',
      'resposta':
          'A contribuição ao INSS é descontada do salário do trabalhador conforme tabela progressiva:\n\n'
          '• Até R\$ 1.412,00 → 7,5%\n'
          '• De R\$ 1.412,01 até R\$ 2.666,68 → 9%\n'
          '• De R\$ 2.666,69 até R\$ 4.000,03 → 12%\n'
          '• De R\$ 4.000,04 até R\$ 7.786,02 → 14%\n\n'
          'O desconto é progressivo: cada faixa incide apenas sobre o valor dentro dela, não sobre o total.',
    },
    {
      'id': 'rescisao',
      'keywords': ['rescisao'],
      'tema': 'Rescisão Contratual',
      'artigo': 'Art. 477 da CLT',
      'resposta':
          'As verbas rescisórias variam conforme o tipo de desligamento:\n\n'
          '📌 Demissão sem justa causa:\n'
          '• Saldo de salário\n'
          '• Aviso prévio (indenizado ou trabalhado)\n'
          '• 13º proporcional\n'
          '• Férias proporcionais + 1/3\n'
          '• Férias vencidas (se houver)\n'
          '• Multa de 40% do FGTS\n'
          '• Seguro-desemprego\n\n'
          '📌 Pedido de demissão: perde aviso prévio indenizado, multa do FGTS e seguro-desemprego.\n\n'
          '📌 Justa causa: perde aviso prévio, 13º, multa do FGTS e seguro-desemprego.\n\n'
          'Base legal: Art. 477 da CLT.',
    },
    {
      'id': 'aviso_previo',
      'keywords': ['aviso_previo'],
      'tema': 'Aviso Prévio',
      'artigo': 'Art. 487 da CLT e Lei 12.506/2011',
      'resposta':
          'O aviso prévio é a comunicação antecipada do encerramento do contrato.\n\n'
          '• Prazo mínimo: 30 dias\n'
          '• Acréscimo: 3 dias por ano trabalhado (máximo 60 dias adicionais → total máximo de 90 dias)\n\n'
          'Modalidades:\n'
          '• Trabalhado: empregado cumpre o período normalmente\n'
          '• Indenizado: empregador paga o valor correspondente sem exigir o cumprimento\n\n'
          '⚠️ Durante o aviso trabalhado, a jornada é reduzida 2 horas diárias sem desconto no salário.\n\n'
          'Base legal: Art. 487 da CLT e Lei 12.506/2011.',
    },
    {
      'id': 'decimo_terceiro',
      'keywords': ['decimo_terceiro'],
      'tema': '13º Salário',
      'artigo': 'Lei 4.090/62',
      'resposta':
          'O 13º salário é uma gratificação natalina equivalente a 1 salário mensal por ano trabalhado.\n\n'
          'Pagamento em duas parcelas:\n'
          '• 1ª parcela: entre fevereiro e novembro (50% do salário)\n'
          '• 2ª parcela: até 20 de dezembro\n\n'
          'Em caso de rescisão, é pago proporcionalmente: divide-se por 12 e multiplica-se pelos meses trabalhados no ano.\n\n'
          '⚠️ Na demissão por justa causa, o empregado perde o direito ao 13º proporcional.\n\n'
          'Base legal: Lei 4.090/62.',
    },
    {
      'id': 'justa_causa',
      'keywords': ['justa_causa'],
      'tema': 'Justa Causa',
      'artigo': 'Art. 482 da CLT',
      'resposta':
          'A demissão por justa causa ocorre quando o empregado comete falta grave prevista em lei.\n\n'
          'Principais motivos (Art. 482 da CLT):\n'
          '• Ato de improbidade\n'
          '• Abandono de emprego\n'
          '• Indisciplina ou insubordinação\n'
          '• Incontinência de conduta\n'
          '• Condenação criminal transitada em julgado\n'
          '• Embriaguez habitual ou em serviço\n'
          '• Violação de segredo da empresa\n\n'
          '⚠️ O trabalhador demitido por justa causa perde: aviso prévio, 13º proporcional, multa do FGTS e seguro-desemprego.\n\n'
          'Base legal: Art. 482 da CLT.',
    },
    {
      'id': 'salario_minimo',
      'keywords': ['salario_minimo'],
      'tema': 'Salário Mínimo',
      'artigo': 'Arts. 76 e 81 da CLT',
      'resposta':
          'O salário mínimo nacional vigente em 2024 é de R\$ 1.412,00.\n\n'
          'Nenhum trabalhador pode receber valor inferior ao salário mínimo, salvo categorias com piso próprio definido em convenção coletiva.\n\n'
          'O salário mínimo serve de base para cálculo de:\n'
          '• Adicional de insalubridade\n'
          '• Benefícios previdenciários\n'
          '• Multas e indenizações trabalhistas\n\n'
          'Base legal: Arts. 76 e 81 da CLT.',
    },
    {
      'id': 'horas_extras',
      'keywords': ['horas_extras'],
      'tema': 'Horas Extras',
      'artigo': 'Art. 59 da CLT',
      'resposta':
          'A jornada normal é de 8 horas diárias e 44 horas semanais. Horas além disso são extras.\n\n'
          '• Máximo de 2 horas extras por dia\n'
          '• Remuneração mínima: 50% acima da hora normal (art. 7º, XVI da CF/88)\n'
          '• Por convenção coletiva pode ser 100%\n\n'
          'Em caso de rescisão sem compensação das horas extras acumuladas, o trabalhador tem direito ao pagamento calculado sobre o salário da data da rescisão.\n\n'
          'Base legal: Art. 59 da CLT.',
    },
    {
      'id': 'insalubridade',
      'keywords': ['insalubridade'],
      'tema': 'Adicional de Insalubridade',
      'artigo': 'Art. 192 da CLT',
      'resposta':
          'O adicional de insalubridade é devido ao trabalhador exposto a agentes nocivos à saúde acima dos limites de tolerância.\n\n'
          'Percentuais sobre o salário mínimo:\n'
          '• Grau mínimo → 10%\n'
          '• Grau médio → 20%\n'
          '• Grau máximo → 40%\n\n'
          'A caracterização é feita por laudo técnico de médico ou engenheiro do trabalho. O adicional cessa com a eliminação do risco (EPI adequado ou mudança de função).\n\n'
          'Base legal: Art. 192 da CLT.',
    },
    {
      'id': 'periculosidade',
      'keywords': ['periculosidade'],
      'tema': 'Adicional de Periculosidade',
      'artigo': 'Art. 193 da CLT',
      'resposta':
          'O adicional de periculosidade é devido ao trabalhador exposto permanentemente a situações de risco acentuado.\n\n'
          'Atividades que geram o adicional:\n'
          '• Inflamáveis, explosivos ou energia elétrica\n'
          '• Segurança pessoal ou patrimonial\n\n'
          'Valor: 30% sobre o salário base (sem gratificações ou prêmios).\n\n'
          '⚠️ O trabalhador não pode receber insalubridade e periculosidade simultaneamente — deve escolher o mais vantajoso.\n\n'
          'Base legal: Art. 193 da CLT.',
    },
    {
      'id': 'jornada',
      'keywords': ['jornada'],
      'tema': 'Jornada de Trabalho',
      'artigo': 'Art. 58 da CLT',
      'resposta':
          'A jornada normal de trabalho é de:\n\n'
          '• 8 horas diárias\n'
          '• 44 horas semanais\n\n'
          'Tipos especiais:\n'
          '• Tempo parcial: até 30 horas semanais (sem horas extras)\n'
          '• Turno ininterrupto de revezamento: 6 horas (salvo negociação coletiva)\n'
          '• Trabalho remoto: segue as mesmas regras de jornada\n\n'
          'Entre duas jornadas deve haver intervalo mínimo de 11 horas (interjornada).\n\n'
          'Base legal: Art. 58 da CLT.',
    },
    {
      'id': 'trabalho_noturno',
      'keywords': ['trabalho_noturno'],
      'tema': 'Trabalho Noturno',
      'artigo': 'Art. 73 da CLT',
      'resposta':
          'Considera-se trabalho noturno o realizado entre 22h e 5h.\n\n'
          '• Adicional noturno: mínimo de 20% sobre a hora diurna\n'
          '• Hora noturna reduzida: computada como 52 minutos e 30 segundos\n\n'
          'Isso significa que 8 horas noturnas equivalem a aproximadamente 7 horas reais, gerando hora extra se ultrapassado.\n\n'
          'Base legal: Art. 73 da CLT.',
    },
    {
      'id': 'estabilidade',
      'keywords': ['estabilidade'],
      'tema': 'Estabilidade no Emprego',
      'artigo': 'Art. 492 da CLT',
      'resposta':
          'Além da estabilidade decenal (10 anos), existem estabilidades provisórias:\n\n'
          '• Gestante: desde a confirmação da gravidez até 5 meses após o parto\n'
          '• Acidente de trabalho: 12 meses após o retorno ao trabalho\n'
          '• Membro de CIPA: desde o registro até 1 ano após o mandato\n'
          '• Dirigente sindical: desde o registro até 1 ano após o mandato\n\n'
          '⚠️ A estabilidade não impede demissão por justa causa devidamente comprovada.\n\n'
          'Base legal: Art. 492 da CLT.',
    },
    {
      'id': 'seguro_desemprego',
      'keywords': ['seguro_desemprego'],
      'tema': 'Seguro-Desemprego',
      'artigo': 'Lei 7.998/90',
      'resposta':
          'O seguro-desemprego é um benefício pago ao trabalhador demitido sem justa causa.\n\n'
          'Requisitos para receber:\n'
          '• Ter trabalhado pelo menos 12 meses nos últimos 18 meses (1ª solicitação)\n'
          '• Não possuir renda própria suficiente\n'
          '• Não estar recebendo outro benefício previdenciário\n\n'
          'Número de parcelas:\n'
          '• 12 a 23 meses trabalhados → 3 parcelas\n'
          '• 24 meses ou mais → 4 ou 5 parcelas\n\n'
          'Base legal: Lei 7.998/90.',
    },
  ];

  for (final article in articles) {
    final id = article['id'] as String;
    await collection.doc(id).set(article);
    print('✅ Inserido: $id');
  }
}
