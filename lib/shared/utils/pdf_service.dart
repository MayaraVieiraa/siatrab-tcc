import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // Helper para formatar moeda com segurança
  static String _fmt(dynamic value) =>
      _currencyFormat.format((value as num?)?.toDouble() ?? 0.0);

  // Helper para extrair valores com segurança e evitar null
  static double _val(Map<String, dynamic> data, String key) =>
      (data[key] as num?)?.toDouble() ?? 0.0;

  // Retorna true se o valor for maior que zero
  static bool _pos(Map<String, dynamic> data, String key) =>
      _val(data, key) > 0;

  static Future<void> generateAndShare(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final modalidade = data['modalidade'] ?? 'Rescisão';
    final tipoDesligamento = data['tipoDesligamento'] ?? '';

    final labelMulta = tipoDesligamento == 'Acordo mútuo'
        ? 'Multa de 20% s/ FGTS:'
        : 'Multa de 40% s/ FGTS:';

    final labelSaque = tipoDesligamento == 'Acordo mútuo'
        ? 'Saque FGTS disponível (80%):'
        : tipoDesligamento == 'Sem justa causa'
        ? 'Saque FGTS disponível (100%):'
        : null;

    // Consolidação das férias
    final feriasPropTotal =
        _val(data, 'feriasProporcional') +
        _val(data, 'tercoFeriasProporcional');
    final feriasVencidasTotal =
        _val(data, 'feriasVencidas') + _val(data, 'tercoFeriasVencidas');

    // ✅ CONTROLES DE EXIBIÇÃO (Garante que seções não fiquem vazias em casos extremos)
    final bool hasCreditos =
        _pos(data, 'saldoSalario') ||
        _pos(data, 'avisoPrevio') ||
        _pos(data, 'decimoTerceiroProporcional') ||
        feriasPropTotal > 0 ||
        feriasVencidasTotal > 0 ||
        _pos(data, 'insalubridadeProporcional') ||
        _pos(data, 'horasExtrasValor') ||
        _pos(data, 'multaFgts');

    final bool hasFgts =
        _pos(data, 'fgtsDepositoEstimado') || _pos(data, 'fgtsSaqueDisponivel');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho ───────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SIATRAB — Extrato de Cálculo',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Este documento tem fins meramente educativos e informativos.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 8),

              // ── Identificação ───────────────────────────────────────
              pw.Text(
                'Modalidade: $modalidade${tipoDesligamento.isNotEmpty ? ' — $tipoDesligamento' : ''}',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              if (_val(data, 'mesesTrabalhados') > 0)
                _pdfRow(
                  'Tempo trabalhado:',
                  '${data['anosCompletos'] ?? 0} anos e ${(_val(data, 'mesesTrabalhados').toInt() % 12)} meses',
                ),
              if (_val(data, 'diasAviso') > 0)
                _pdfRow(
                  'Aviso Prévio Proporcional:',
                  '${data['diasAviso']} dias',
                ),
              pw.SizedBox(height: 12),

              // ── Verbas Rescisórias (Créditos) ───────────────────────
              _pdfSection('VERBAS RESCISÓRIAS (CRÉDITOS)'),
              if (hasCreditos) ...[
                if (_pos(data, 'saldoSalario'))
                  _pdfRow(
                    'Saldo de Salário:',
                    _fmt(_val(data, 'saldoSalario')),
                  ),
                if (_pos(data, 'avisoPrevio'))
                  _pdfRow(
                    'Aviso Prévio Indenizado:',
                    _fmt(_val(data, 'avisoPrevio')),
                  ),
                if (_pos(data, 'decimoTerceiroProporcional'))
                  _pdfRow(
                    '13º Salário Proporcional:',
                    _fmt(_val(data, 'decimoTerceiroProporcional')),
                  ),
                if (feriasPropTotal > 0)
                  _pdfRow('Férias Proporcionais + 1/3:', _fmt(feriasPropTotal)),
                if (feriasVencidasTotal > 0)
                  _pdfRow('Férias Vencidas + 1/3:', _fmt(feriasVencidasTotal)),
                if (_pos(data, 'insalubridadeProporcional'))
                  _pdfRow(
                    'Adicional de Insalubridade:',
                    _fmt(_val(data, 'insalubridadeProporcional')),
                  ),
                if (_pos(data, 'horasExtrasValor'))
                  _pdfRow(
                    'Horas Extras:',
                    _fmt(_val(data, 'horasExtrasValor')),
                  ),
                if (_pos(data, 'multaFgts'))
                  _pdfRow(labelMulta, _fmt(_val(data, 'multaFgts'))),
              ] else ...[
                // ✅ Fallback se o usuário não preencheu verbas
                pw.Text(
                  'Sem verbas rescisórias a receber.',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
              pw.SizedBox(height: 12),

              // ── Descontos (Débitos) ─────────────────────────────────
              _pdfSection('DESCONTOS (DÉBITOS)'),
              if (_pos(data, 'inss'))
                _pdfRow('INSS:', '- ${_fmt(_val(data, 'inss'))}'),
              if (_pos(data, 'irrf'))
                _pdfRow('IRRF:', '- ${_fmt(_val(data, 'irrf'))}'),
              if (_pos(data, 'descontoAviso'))
                _pdfRow(
                  'Desconto Aviso Prévio:',
                  '- ${_fmt(_val(data, 'descontoAviso'))}',
                ),
              if (!_pos(data, 'inss') &&
                  !_pos(data, 'irrf') &&
                  !_pos(data, 'descontoAviso'))
                // ✅ Fallback se o usuário simulou algo sem INSS/IRRF
                pw.Text(
                  'Sem descontos aplicáveis.',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
              pw.SizedBox(height: 12),

              // ── FGTS ────────────────────────────────────────────────
              // ✅ Agora exibe a seção de FGTS se existir saldo estimativa OU saldo para saque
              if (hasFgts) ...[
                _pdfSection('FUNDO DE GARANTIA (FGTS)'),
                if (_pos(data, 'fgtsDepositoEstimado'))
                  _pdfRow(
                    'Depósitos estimados (8% mensal):',
                    _fmt(_val(data, 'fgtsDepositoEstimado')),
                  ),
                if (labelSaque != null && _pos(data, 'fgtsSaqueDisponivel'))
                  _pdfRow(labelSaque, _fmt(_val(data, 'fgtsSaqueDisponivel'))),
                pw.SizedBox(height: 12),
              ],

              // ── Totais Finais ───────────────────────────────────────
              _pdfSection('TOTAIS FINAIS'),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 6),
              _pdfRow('Total Bruto:', _fmt(_val(data, 'totalBruto'))),
              _pdfRow(
                'Total de Descontos:',
                '- ${_fmt(_val(data, 'totalDescontos'))}',
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                child: _pdfRow(
                  'VALOR LÍQUIDO A RECEBER:',
                  _fmt(_val(data, 'totalLiquido')),
                  isBold: true,
                ),
              ),
              pw.Spacer(),

              // ── Rodapé com informações legais ────────────────────────
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Gerado pelo SIATRAB',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Prazo: 10 dias úteis (Art. 477 CLT)',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Lei nº 14.848/2024 · Port. MPS/MF nº 02/2026 · Valores referentes à legislação de 2026',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'extrato_siatrab_${modalidade.toLowerCase().replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _pdfSection(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 11,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 2),
      ],
    );
  }

  static pw.Widget _pdfRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> shareAsText(Map<String, dynamic> data) async {
    final modalidade = data['modalidade'] ?? 'Cálculo';
    final tipoDesligamento = data['tipoDesligamento'] ?? '';

    final totalLiquido = _fmt(_val(data, 'totalLiquido'));
    final feriasPropTotal =
        _val(data, 'feriasProporcional') +
        _val(data, 'tercoFeriasProporcional');
    final feriasVencidasTotal =
        _val(data, 'feriasVencidas') + _val(data, 'tercoFeriasVencidas');

    final buffer = StringBuffer();
    buffer.writeln('📋 SIATRAB — Resumo do Cálculo');
    buffer.writeln(
      'Modalidade: $modalidade${tipoDesligamento.isNotEmpty ? ' ($tipoDesligamento)' : ''}',
    );
    buffer.writeln('');

    if (_val(data, 'mesesTrabalhados') > 0) {
      buffer.writeln(
        '⏱ Tempo trabalhado: ${data['anosCompletos'] ?? 0} anos e ${(_val(data, 'mesesTrabalhados').toInt() % 12)} meses',
      );
    }
    if (_val(data, 'diasAviso') > 0) {
      buffer.writeln('📢 Aviso Prévio Proporcional: ${data['diasAviso']} dias');
    }
    buffer.writeln('');

    buffer.writeln('💰 CRÉDITOS:');
    final bool hasCreditosText =
        _pos(data, 'saldoSalario') ||
        _pos(data, 'avisoPrevio') ||
        _pos(data, 'decimoTerceiroProporcional') ||
        feriasPropTotal > 0 ||
        feriasVencidasTotal > 0 ||
        _pos(data, 'insalubridadeProporcional') ||
        _pos(data, 'horasExtrasValor') ||
        _pos(data, 'multaFgts');

    if (hasCreditosText) {
      if (_pos(data, 'saldoSalario'))
        buffer.writeln(
          '  • Saldo de Salário: ${_fmt(_val(data, 'saldoSalario'))}',
        );
      if (_pos(data, 'avisoPrevio'))
        buffer.writeln(
          '  • Aviso Prévio Indenizado: ${_fmt(_val(data, 'avisoPrevio'))}',
        );
      if (_pos(data, 'decimoTerceiroProporcional'))
        buffer.writeln(
          '  • 13º Salário Proporcional: ${_fmt(_val(data, 'decimoTerceiroProporcional'))}',
        );
      if (feriasPropTotal > 0)
        buffer.writeln(
          '  • Férias Proporcionais + 1/3: ${_fmt(feriasPropTotal)}',
        );
      if (feriasVencidasTotal > 0)
        buffer.writeln(
          '  • Férias Vencidas + 1/3: ${_fmt(feriasVencidasTotal)}',
        );
      if (_pos(data, 'insalubridadeProporcional'))
        buffer.writeln(
          '  • Adicional de Insalubridade: ${_fmt(_val(data, 'insalubridadeProporcional'))}',
        );
      if (_pos(data, 'horasExtrasValor'))
        buffer.writeln(
          '  • Horas Extras: ${_fmt(_val(data, 'horasExtrasValor'))}',
        );
      if (_pos(data, 'multaFgts')) {
        final labelMultaText = tipoDesligamento == 'Acordo mútuo'
            ? 'Multa 20% FGTS'
            : 'Multa 40% FGTS';
        buffer.writeln('  • $labelMultaText: ${_fmt(_val(data, 'multaFgts'))}');
      }
    } else {
      buffer.writeln('  • Sem verbas rescisórias a receber');
    }
    buffer.writeln('');

    buffer.writeln('➖ DÉBITOS:');
    if (_pos(data, 'inss'))
      buffer.writeln('  • INSS: - ${_fmt(_val(data, 'inss'))}');
    if (_pos(data, 'irrf'))
      buffer.writeln('  • IRRF: - ${_fmt(_val(data, 'irrf'))}');
    if (_pos(data, 'descontoAviso'))
      buffer.writeln(
        '  • Desconto Aviso Prévio: - ${_fmt(_val(data, 'descontoAviso'))}',
      );
    if (!_pos(data, 'inss') &&
        !_pos(data, 'irrf') &&
        !_pos(data, 'descontoAviso')) {
      buffer.writeln('  • Sem descontos aplicáveis');
    }
    buffer.writeln('');

    buffer.writeln('✅ TOTAL LÍQUIDO: $totalLiquido');

    if (_pos(data, 'fgtsSaqueDisponivel')) {
      final pct = tipoDesligamento == 'Acordo mútuo' ? '80%' : '100%';
      buffer.writeln(
        '🏦 Saque FGTS disponível ($pct): ${_fmt(_val(data, 'fgtsSaqueDisponivel'))}',
      );
    }

    buffer.writeln('');
    buffer.writeln('📅 Prazo para pagamento: 10 dias úteis (Art. 477 CLT)');
    buffer.writeln('');
    buffer.writeln('Calcule seus direitos no SIATRAB!');

    await Share.share(
      buffer.toString(),
      subject: 'Meu Cálculo Trabalhista — SIATRAB',
    );
  }
}
