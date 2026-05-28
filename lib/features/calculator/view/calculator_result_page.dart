import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/pdf_service.dart';
import '../../history/repository/history_repository.dart';

class CalculatorResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final String? docId;

  const CalculatorResultPage({super.key, required this.data, this.docId});

  @override
  ConsumerState<CalculatorResultPage> createState() =>
      _CalculatorResultPageState();
}

class _CalculatorResultPageState extends ConsumerState<CalculatorResultPage> {
  int _selectedTab = 0;

  double _d(String key, [String? fallbackKey]) {
    final v = widget.data[key] as num?;
    if (v != null) return v.toDouble();
    if (fallbackKey != null) {
      return (widget.data[fallbackKey] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  String _formatCurrency(double value) => NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  ).format(value);

  String get _modalidade => widget.data['modalidade'] as String? ?? 'Rescisão';
  bool get _isRescisao => _modalidade == 'Rescisão';
  bool get _isFerias => _modalidade == 'Férias';
  bool get _isFgts => _modalidade == 'FGTS';
  bool get _isInss => _modalidade == 'INSS' || _modalidade == 'INSS/IRRF';

  String get _labelMulta => widget.data['tipoDesligamento'] == 'Acordo mútuo'
      ? 'Multa 20% s/ FGTS:'
      : 'Multa 40% s/ FGTS:';

  String? get _labelSaque {
    final t = widget.data['tipoDesligamento'] as String? ?? '';
    if (t == 'Sem justa causa') return 'Saque FGTS disponível (100%):';
    if (t == 'Acordo mútuo') return 'Saque FGTS disponível (80%):';
    return null;
  }

  double get _feriasPropTotal =>
      _d('feriasProporcional') +
      (_d('tercoFeriasProporcional') > 0
          ? _d('tercoFeriasProporcional')
          : _d('tercoFerias'));

  double get _feriasVencidasTotal =>
      _d('feriasVencidas') + _d('tercoFeriasVencidas');

  @override
  Widget build(BuildContext context) {
    final modalidade = _modalidade;
    final tipoDesligamento =
        widget.data['tipoDesligamento'] as String? ?? 'Sem justa causa';
    final mesesTrabalhados = widget.data['mesesTrabalhados'] as int? ?? 0;
    final anosCompletos = widget.data['anosCompletos'] as int? ?? 0;
    final mesesRestantes = mesesTrabalhados % 12;
    final diasAviso = widget.data['diasAviso'] as int? ?? 0;

    String dataFormatada = '—';
    try {
      final createdAt = widget.data['createdAt'];
      if (createdAt != null) {
        final dt = (createdAt as dynamic).toDate() as DateTime;
        dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dt);
      }
    } catch (_) {}

    String admissao = '—', demissao = '—';
    try {
      if (widget.data['dataAdmissao'] != null)
        admissao = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(widget.data['dataAdmissao'] as String));
      if (widget.data['dataDemissao'] != null)
        demissao = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(widget.data['dataDemissao'] as String));
    } catch (_) {}

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E3A8A),
              Color(0xFF192E6A),
              Color(0xFF192E6A),
            ],
            stops: [0.49, 0.58, 0.58, 0.67],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DiagonalPainter())),
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Extrato — $modalidade',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildMenuTabs(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ════════════════════════════════════════
                              // TAB 0 — RESUMO GERAL
                              // ════════════════════════════════════════
                              if (_selectedTab == 0) ...[
                                _sectionTitle('Resumo'),
                                const SizedBox(height: 12),
                                _infoRow('Modalidade:', modalidade),
                                if (_isRescisao)
                                  _infoRow(
                                    'Tipo de desligamento:',
                                    tipoDesligamento,
                                  ),
                                _infoRow('Data do cálculo:', dataFormatada),
                                if (admissao != '—')
                                  _infoRow('Data de Admissão:', admissao),
                                if (demissao != '—')
                                  _infoRow('Data de Demissão:', demissao),
                                if (_isRescisao && mesesTrabalhados > 0)
                                  _infoRow(
                                    'Tempo trabalhado:',
                                    '$anosCompletos anos e $mesesRestantes meses',
                                  ),
                                if (_isRescisao && diasAviso > 0)
                                  _infoRow('Aviso Prévio:', '$diasAviso dias'),
                                if (_isFgts && mesesTrabalhados > 0)
                                  _infoRow(
                                    'Meses trabalhados:',
                                    '$mesesTrabalhados meses',
                                  ),
                                if (_isFerias && (widget.data['dias'] != null || widget.data['diasFerias'] != null))
                                  _infoRow(
                                    'Dias de férias:',
                                    '${widget.data['dias'] ?? widget.data['diasFerias']} dias',
                                  ),

                                const Divider(height: 28),
                                _sectionTitle('Resultado Final'),
                                const SizedBox(height: 12),

                                if (_isRescisao) ...[
                                  _valueRow(
                                    'Valor Bruto da Rescisão:',
                                    _d('totalBruto'),
                                    bold: true,
                                  ),
                                  _valueRow(
                                    'Total de Descontos:',
                                    _d('totalDescontos'),
                                    isNegative: true,
                                  ),
                                  const SizedBox(height: 8),
                                  _valueRow(
                                    'Valor Líquido a Receber:',
                                    _d('totalLiquido'),
                                    bold: true,
                                    highlight: true,
                                    isLarge: true,
                                  ),
                                ] else if (_isFerias) ...[
                                  _valueRow(
                                    'Valor das Férias:',
                                    _d('valorFerias', 'feriasProporcional'),
                                  ),
                                  _valueRow(
                                    'Adicional 1/3:',
                                    _d('tercoFerias'),
                                  ),
                                  const Divider(),
                                  _valueRow(
                                    'Total Bruto:',
                                    _d('bruto', 'totalBruto'),
                                    bold: true,
                                  ),
                                  _valueRow(
                                    'Desconto INSS:',
                                    _d('inss'),
                                    isNegative: true,
                                  ),
                                  _valueRow(
                                    'Desconto IRRF:',
                                    _d('irrf'),
                                    isNegative: true,
                                  ),
                                  const Divider(),
                                  _valueRow(
                                    'Líquido a Receber:',
                                    _d('liquido', 'totalLiquido'),
                                    bold: true,
                                    highlight: true,
                                    isLarge: true,
                                  ),
                                ] else if (_isFgts) ...[
                                  _valueRow('Salário Base:', _d('salario')),
                                  _valueRow(
                                    'Depósito mensal (8%):',
                                    _d('depositoMensal'),
                                  ),
                                  _valueRow(
                                    'Saldo estimado na conta:',
                                    _d('saldoFgts'),
                                  ),
                                  if (_d('multa', 'multaFgts') > 0)
                                    _valueRow(_labelMulta, _d('multa', 'multaFgts')),
                                  if (_d('saqueDisponivel') > 0)
                                    _valueRow(
                                      'Saque FGTS disponível:',
                                      _d('saqueDisponivel'),
                                      bold: true,
                                      highlight: true,
                                      isLarge: true,
                                    ),
                                ] else if (_isInss) ...[
                                  _valueRow(
                                    'Salário Bruto:',
                                    _d('salarioBruto', 'salario'),
                                  ),
                                  _valueRow(
                                    'Desconto INSS:',
                                    _d('descontoINSS', 'inss'),
                                    isNegative: true,
                                  ),
                                  _valueRow(
                                    'Desconto IRRF:',
                                    _d('descontoIRRF', 'irrf'),
                                    isNegative: true,
                                  ),
                                  const Divider(),
                                  _valueRow(
                                    'Salário Líquido:',
                                    _d('salarioLiquido', 'totalLiquido'),
                                    bold: true,
                                    highlight: true,
                                    isLarge: true,
                                  ),
                                ],

                                const Divider(height: 28),
                                _sectionTitle('Informações Adicionais'),
                                const SizedBox(height: 12),

                                if (_isRescisao) ...[
                                  if (tipoDesligamento == 'Sem justa causa')
                                    _buildInfoChip(
                                      Icons.check_circle_outline,
                                      'Direito ao Seguro-Desemprego (verifique carência)',
                                      Colors.green,
                                    ),
                                  if (tipoDesligamento == 'Acordo mútuo')
                                    _buildInfoChip(
                                      Icons.info_outline,
                                      'Acordo mútuo não dá direito ao Seguro-Desemprego',
                                      Colors.orange,
                                    ),
                                  if (tipoDesligamento ==
                                          'Pedido de demissão' ||
                                      tipoDesligamento == 'Com justa causa')
                                    _buildInfoChip(
                                      Icons.cancel_outlined,
                                      'Sem direito ao Seguro-Desemprego nem saque do FGTS',
                                      Colors.red,
                                    ),
                                ],
                                if (_isFgts)
                                  _buildInfoChip(
                                    Icons.info_outline,
                                    'Valor estimado — não contempla juros e correções (JAM) da Caixa',
                                    Colors.blue,
                                  ),

                                _infoRow(
                                  'Prazo para pagamento:',
                                  '10 dias úteis (Art. 477 CLT)',
                                ),
                                _infoRow('Base Legal:', 'Legislação de 2026'),
                              ],

                              // ════════════════════════════════════════
                              // TAB 1 — DETALHAMENTO
                              // ════════════════════════════════════════
                              if (_selectedTab == 1) ...[
                                if (_isRescisao) ...[
                                  _sectionTitle(
                                    'Verbas Rescisórias (Créditos)',
                                  ),
                                  const SizedBox(height: 12),
                                  if (_d('saldoSalario') > 0)
                                    _valueRow(
                                      'Saldo de Salário:',
                                      _d('saldoSalario'),
                                    ),
                                  if (_d('avisoPrevio') > 0)
                                    _valueRow(
                                      'Aviso Prévio Indenizado ($diasAviso dias):',
                                      _d('avisoPrevio'),
                                    ),
                                  if (_d('decimoTerceiroProporcional') > 0)
                                    _valueRow(
                                      '13º Salário Proporcional:',
                                      _d('decimoTerceiroProporcional'),
                                    ),
                                  if (_feriasPropTotal > 0)
                                    _valueRow(
                                      'Férias Proporcionais + 1/3:',
                                      _feriasPropTotal,
                                    ),
                                  if (_feriasVencidasTotal > 0)
                                    _valueRow(
                                      'Férias Vencidas + 1/3:',
                                      _feriasVencidasTotal,
                                    ),
                                  if (_d('insalubridadeProporcional') > 0)
                                    _valueRow(
                                      'Adicional de Insalubridade:',
                                      _d('insalubridadeProporcional'),
                                    ),
                                  if (_d('horasExtrasValor') > 0)
                                    _valueRow(
                                      'Horas Extras:',
                                      _d('horasExtrasValor'),
                                    ),
                                  if (_d('multaFgts') > 0)
                                    _valueRow(_labelMulta, _d('multaFgts')),
                                  const Divider(height: 20),
                                  _valueRow(
                                    'TOTAL BRUTO:',
                                    _d('totalBruto'),
                                    bold: true,
                                    highlight: true,
                                  ),
                                  const Divider(height: 20),
                                  _sectionTitle('Descontos (Débitos)'),
                                  const SizedBox(height: 12),
                                  _valueRow(
                                    'INSS:',
                                    _d('inss'),
                                    isNegative: true,
                                  ),
                                  if (_d('irrf') > 0)
                                    _valueRow(
                                      'IRRF:',
                                      _d('irrf'),
                                      isNegative: true,
                                    ),
                                  const Divider(height: 20),
                                  _valueRow(
                                    'TOTAL DESCONTOS:',
                                    _d('totalDescontos'),
                                    bold: true,
                                    isNegative: true,
                                  ),
                                  const Divider(height: 20),
                                  _sectionTitle('FGTS'),
                                  const SizedBox(height: 12),
                                  _valueRow(
                                    'Depósitos estimados (8% mensal):',
                                    _d('fgtsDepositoEstimado'),
                                  ),
                                  if (_d('multaFgts') > 0)
                                    _valueRow(_labelMulta, _d('multaFgts')),
                                  if (_labelSaque != null)
                                    _valueRow(
                                      _labelSaque!,
                                      _d('fgtsSaqueDisponivel'),
                                      highlight: true,
                                    ),
                                  if (_labelSaque == null)
                                    _buildInfoChip(
                                      Icons.cancel_outlined,
                                      'Saque do FGTS não disponível nesta modalidade',
                                      Colors.red,
                                    ),
                                ] else if (_isFerias) ...[
                                  _sectionTitle('Detalhamento das Férias'),
                                  const SizedBox(height: 12),
                                  _valueRow('Salário Base:', _d('salario')),
                                  _infoRow(
                                    'Dias de férias:',
                                    '${widget.data['dias'] ?? widget.data['diasFerias'] ?? 30} dias',
                                  ),
                                  _valueRow(
                                    'Valor das Férias:',
                                    _d('valorFerias', 'feriasProporcional'),
                                  ),
                                  _valueRow(
                                    'Adicional Constitucional 1/3:',
                                    _d('tercoFerias'),
                                  ),
                                  const Divider(),
                                  _valueRow(
                                    'Subtotal (Bruto):',
                                    _d('bruto', 'totalBruto'),
                                    bold: true,
                                  ),
                                  const Divider(height: 20),
                                  _sectionTitle('Descontos'),
                                  const SizedBox(height: 8),
                                  _valueRow(
                                    'INSS:',
                                    _d('inss'),
                                    isNegative: true,
                                  ),
                                  _valueRow(
                                    'IRRF:',
                                    _d('irrf'),
                                    isNegative: true,
                                  ),
                                  const Divider(),
                                  _valueRow(
                                    'Líquido a Receber:',
                                    _d('liquido', 'totalLiquido'),
                                    bold: true,
                                    highlight: true,
                                  ),
                                ] else if (_isFgts) ...[
                                  _sectionTitle('Detalhamento do FGTS'),
                                  const SizedBox(height: 12),
                                  _valueRow(
                                    'Salário Base Mensal:',
                                    _d('salario'),
                                  ),
                                  _infoRow(
                                    'Meses trabalhados:',
                                    '$mesesTrabalhados meses',
                                  ),
                                  _valueRow(
                                    'Depósito Mensal (8%):',
                                    _d('depositoMensal'),
                                  ),
                                  _valueRow(
                                    'Total Depositado (8% × meses):',
                                    _d('saldoFgts'),
                                  ),
                                  if (_d('multa', 'multaFgts') > 0) ...[
                                    const Divider(),
                                    _valueRow('Multa Rescisória:', _d('multa', 'multaFgts')),
                                    _infoRow(
                                      'Percentual:',
                                      tipoDesligamento == 'Acordo mútuo'
                                          ? '20%'
                                          : '40%',
                                    ),
                                  ],
                                  if (_d('saqueDisponivel') > 0) ...[
                                    const Divider(),
                                    _valueRow(
                                      'Valor disponível para saque:',
                                      _d('saqueDisponivel'),
                                      bold: true,
                                      highlight: true,
                                    ),
                                  ],
                                  _buildInfoChip(
                                    Icons.info_outline,
                                    'Valor estimado. O saldo real pode variar por juros e correções (JAM).',
                                    Colors.blue,
                                  ),
                                ] else if (_isInss) ...[
                                  _sectionTitle('Detalhamento dos Descontos'),
                                  const SizedBox(height: 12),
                                  _valueRow(
                                    'Salário Bruto:',
                                    _d('salarioBruto', 'salario'),
                                  ),
                                  const SizedBox(height: 8),
                                  _sectionTitle(
                                    'Tabela INSS Progressiva 2026:',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInssTable(_d('salarioBruto', 'salario')),
                                  const Divider(),
                                  _valueRow(
                                    'Desconto Total INSS:',
                                    _d('descontoINSS', 'inss'),
                                    bold: true,
                                    isNegative: true,
                                  ),
                                  if (_d('descontoIRRF', 'irrf') > 0) ...[
                                    const SizedBox(height: 8),
                                    _valueRow(
                                      'Desconto IRRF:',
                                      _d('descontoIRRF', 'irrf'),
                                      isNegative: true,
                                    ),
                                    _infoRow(
                                      'Dependentes:',
                                      '${widget.data['dependentes'] ?? 0}',
                                    ),
                                  ],
                                  if (_d('descontoIRRF', 'irrf') == 0)
                                    _buildInfoChip(
                                      Icons.check_circle_outline,
                                      'Isento de IRRF — base abaixo de R\$ 5.000,00',
                                      Colors.green,
                                    ),
                                ],
                              ],

                              // ════════════════════════════════════════
                              // TAB 2 — TABELAS 2026
                              // ════════════════════════════════════════
                              if (_selectedTab == 2) ...[
                                _sectionTitle('Tabelas Vigentes 2026'),
                                const SizedBox(height: 16),
                                _buildTableCard(
                                  title: 'Tabela INSS 2026 (Progressiva)',
                                  subtitle:
                                      'Portaria Interministerial MPS/MF nº 02/2026',
                                  rows: const [
                                    ['Até R\$ 1.621,00', '7,5%'],
                                    ['R\$ 1.621,01 – R\$ 2.902,84', '9,0%'],
                                    ['R\$ 2.902,85 – R\$ 4.354,27', '12,0%'],
                                    ['R\$ 4.354,28 – R\$ 8.475,55', '14,0%'],
                                    [
                                      'Acima de R\$ 8.475,55',
                                      'Teto: R\$ 951,00',
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildTableCard(
                                  title: 'Tabela IRRF 2026',
                                  subtitle:
                                      'Lei nº 14.848/2024 — Isenção até R\$ 5.000,00',
                                  rows: const [
                                    ['Até R\$ 5.000,00', 'Isento'],
                                    ['R\$ 5.000,01 – R\$ 6.000,00', '7,5%'],
                                    ['R\$ 6.000,01 – R\$ 7.500,00', '15,0%'],
                                    ['R\$ 7.500,01 – R\$ 9.000,00', '22,5%'],
                                    ['Acima de R\$ 9.000,00', '27,5%'],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildTableCard(
                                  title: 'Aviso Prévio Proporcional',
                                  subtitle: 'Lei nº 12.506/2011',
                                  rows: const [
                                    ['Base', '30 dias'],
                                    ['Acréscimo por ano trabalhado', '+3 dias'],
                                    ['Limite máximo', '90 dias'],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildTableCard(
                                  title: 'Multa do FGTS por Modalidade',
                                  subtitle:
                                      'Art. 18 §1º Lei nº 8.036/90 e Art. 484-A CLT',
                                  rows: const [
                                    ['Sem justa causa', '40% + saque 100%'],
                                    ['Acordo mútuo', '20% + saque 80%'],
                                    [
                                      'Pedido de demissão',
                                      'Sem multa / Sem saque',
                                    ],
                                    [
                                      'Com justa causa',
                                      'Sem multa / Sem saque',
                                    ],
                                  ],
                                ),
                              ],

                              // ════════════════════════════════════════
                              // TAB 3 — FUNDAMENTAÇÃO LEGAL
                              // ════════════════════════════════════════
                              if (_selectedTab == 3) ...[
                                _sectionTitle('Fundamentação Legal'),
                                const SizedBox(height: 16),
                                _buildLegalCard(
                                  title: 'Rescisão do Contrato',
                                  items: const [
                                    '• Art. 477 CLT — Prazo de 10 dias úteis para pagamento',
                                    '• Art. 487 CLT — Aviso prévio',
                                    '• Lei nº 12.506/2011 — Aviso prévio proporcional',
                                    '• Art. 484-A CLT — Rescisão por acordo mútuo',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildLegalCard(
                                  title: 'Direitos Trabalhistas',
                                  items: const [
                                    '• Art. 7º, XVII CF/88 — Adicional de 1/3 sobre férias',
                                    '• Lei nº 4.090/62 — 13º salário',
                                    '• Art. 192 CLT — Adicional de insalubridade',
                                    '• Art. 59 CLT — Horas extras (mínimo 50%)',
                                    '• Portaria nº 3.665/2023 — Horas extras em feriados (100%)',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildLegalCard(
                                  title: 'FGTS',
                                  items: const [
                                    '• Art. 15 e 18 da Lei nº 8.036/90 — FGTS e multa',
                                    '• Art. 484-A CLT — Multa 20% e saque 80% no acordo mútuo',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildLegalCard(
                                  title: 'Tributação 2026',
                                  items: const [
                                    '• Portaria MPS/MF nº 02/2026 — Tabela INSS progressiva',
                                    '• Lei nº 14.848/2024 — IRRF com isenção até R\$ 5.000,00',
                                    '• Dedução por dependente: R\$ 189,59',
                                    '• Salário mínimo: R\$ 1.621,00 (Decreto nº 12.797/2025)',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildLegalCard(
                                  title: 'Prazos Importantes',
                                  items: const [
                                    '• Pagamento da rescisão: até 10 dias úteis (Art. 477 CLT)',
                                    '• Seguro-Desemprego: solicitar entre 7 e 120 dias após a demissão',
                                    '• Saque do FGTS: até 5 dias úteis após a movimentação',
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Botões de Ação ────────────────────────────
                        _buildActionButton(
                          label: 'EXPORTAR PDF',
                          icon: Icons.picture_as_pdf_outlined,
                          onTap: () => PdfService.generateAndShare(widget.data),
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          label: 'COMPARTILHAR',
                          icon: Icons.share_outlined,
                          onTap: () => PdfService.shareAsText(widget.data),
                        ),
                        const SizedBox(height: 10),
                        if (widget.docId == null)
                          _buildActionButton(
                            label: 'SALVAR NO HISTÓRICO',
                            icon: Icons.save_outlined,
                            onTap: () async {
                              try {
                                await historyRepository.saveCalculation({
                                  ...widget.data,
                                  'modalidade': modalidade,
                                  'tipoDesligamento': tipoDesligamento,
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Cálculo salvo com sucesso!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erro ao salvar: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          label: 'REFAZER CÁLCULO',
                          icon: Icons.refresh,
                          onTap: () => context.go('/calculator'),
                        ),
                        if (widget.docId != null) ...[
                          const SizedBox(height: 10),
                          _buildActionButton(
                            label: 'EXCLUIR CÁLCULO',
                            icon: Icons.delete_outline,
                            isDestructive: true,
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir cálculo'),
                                  content: const Text(
                                    'Tem certeza? Esta ação não pode ser desfeita.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('CANCELAR'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('EXCLUIR'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                try {
                                  await historyRepository.deleteCalculation(
                                    widget.docId!,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cálculo excluído.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    context.pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao excluir: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MENU DE ABAS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMenuTabs() {
    final labels = ['RESUMO', 'DETALHAMENTO', 'TABELAS 2026', 'BASE LEGAL'];
    final totalTabs = labels.length;

    // ✅ Garante que _selectedTab seja válido
    if (_selectedTab >= totalTabs) {
      _selectedTab = 0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            totalTabs,
            (i) => GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedTab == i ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: _selectedTab == i
                        ? const Color(0xFF192E6A)
                        : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildInssTable(double salary) {
    final faixas = [
      ['Até R\$ 1.621,00', '7,5%', salary <= 1621.00],
      [
        'R\$ 1.621,01 a R\$ 2.902,84',
        '9,0%',
        salary > 1621.00 && salary <= 2902.84,
      ],
      [
        'R\$ 2.902,85 a R\$ 4.354,27',
        '12,0%',
        salary > 2902.84 && salary <= 4354.27,
      ],
      [
        'R\$ 4.354,28 a R\$ 8.475,55',
        '14,0%',
        salary > 4354.27 && salary <= 8475.55,
      ],
      ['Acima de R\$ 8.475,55', 'Teto R\$ 951,00', salary > 8475.55],
    ];

    return Column(
      children: faixas.map((f) {
        final ativa = f[2] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ativa
                ? const Color(0xFF192E6A).withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  f[0] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: ativa ? const Color(0xFF192E6A) : Colors.black54,
                  ),
                ),
              ),
              Text(
                f[1] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ativa ? const Color(0xFF192E6A) : Colors.black54,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableCard({
    required String title,
    required String subtitle,
    required List<List<String>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF192E6A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const Divider(height: 16),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(row[0], style: const TextStyle(fontSize: 12)),
                  ),
                  Text(
                    row[1],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard({required String title, required List<String> items}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF192E6A),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : const Color(0xFF5C78FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF192E6A),
      ),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          textAlign: TextAlign.right,
        ),
      ],
    ),
  );

  Widget _valueRow(
    String label,
    double value, {
    bool bold = false,
    bool highlight = false,
    bool isNegative = false,
    bool isLarge = false,
  }) {
    final color = highlight
        ? const Color(0xFF192E6A)
        : isNegative
        ? Colors.red
        : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 15 : 13,
                color: highlight ? const Color(0xFF192E6A) : Colors.black54,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${isNegative && value > 0 ? '- ' : ''}${_formatCurrency(value)}',
            style: TextStyle(
              fontSize: isLarge ? 18 : 13,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
            Color(0xFF192E6A),
            Color(0xFF192E6A),
          ],
          stops: [0.49, 0.58, 0.58, 0.67],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/calculator');
              break;
            case 2:
              context.go('/chat');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate_rounded),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.30, size.height)
      ..lineTo(0, size.height)
      ..close();
    paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E3A8A), Color(0xFF192E6A), Color(0xFF0F172A)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
