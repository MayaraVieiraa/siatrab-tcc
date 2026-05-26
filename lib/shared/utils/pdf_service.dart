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

  static String _fmt(dynamic value) =>
      _currencyFormat.format((value as num?)?.toDouble() ?? 0.0);

  static Future<void> generateAndShare(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final modalidade = data['modalidade'] ?? 'Rescisão';
    final tipoDesligamento = data['tipoDesligamento'] ?? '';

    // Label da multa conforme modalidade
    final labelMulta = tipoDesligamento == 'Acordo mútuo'
        ? 'Multa de 20% s/ FGTS:'
        : 'Multa de 40% s/ FGTS:';

    // Label do saque conforme modalidade
    final labelSaque = tipoDesligamento == 'Acordo mútuo'
        ? 'Saque FGTS disponível (80%):'
        : tipoDesligamento == 'Sem justa causa'
        ? 'Saque FGTS disponível (100%):'
        : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
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
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 11),
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

              // Identificação
              pw.Text(
                'Modalidade: $modalidade'
                '${tipoDesligamento.isNotEmpty ? ' — $tipoDesligamento' : ''}',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              if (data['mesesTrabalhados'] != null)
                _pdfRow(
                  'Meses trabalhados:',
                  '${data['mesesTrabalhados']} meses',
                ),
              pw.SizedBox(height: 12),

              // Verbas rescisórias
              _pdfSection('Verbas Rescisórias'),
              if (data['saldoSalario'] != null)
                _pdfRow('Saldo de Salário:', _fmt(data['saldoSalario'])),
              if (_pos(data['avisoPrevio']))
                _pdfRow('Aviso Prévio:', _fmt(data['avisoPrevio'])),
              if (data['decimoTerceiro'] != null)
                _pdfRow('13º Proporcional:', _fmt(data['decimoTerceiro'])),
              if (data['feriasProporcional'] != null)
                _pdfRow(
                  'Férias Proporcionais + 1/3:',
                  _fmt(
                    (data['feriasProporcional'] as num).toDouble() +
                        ((data['tercoFerias'] as num?)?.toDouble() ?? 0),
                  ),
                ),
              if (_pos(data['feriasVencidas']))
                _pdfRow('Férias Vencidas:', _fmt(data['feriasVencidas'])),
              if (_pos(data['insalubridade']))
                _pdfRow(
                  'Adicional de Insalubridade:',
                  _fmt(data['insalubridade']),
                ),
              if (_pos(data['horasExtras']))
                _pdfRow('Horas Extras:', _fmt(data['horasExtras'])),
              if (_pos(data['multaFgts']))
                _pdfRow(labelMulta, _fmt(data['multaFgts'])),
              pw.SizedBox(height: 12),

              // Descontos
              _pdfSection('Descontos'),
              if (_pos(data['inss']))
                _pdfRow('INSS:', '- ${_fmt(data['inss'])}'),
              if (_pos(data['irrf']))
                _pdfRow('IRRF:', '- ${_fmt(data['irrf'])}'),
              pw.SizedBox(height: 12),

              // FGTS
              if (data['fgtsDeposito'] != null) ...[
                _pdfSection('FGTS'),
                _pdfRow('Saldo estimado na conta:', _fmt(data['fgtsDeposito'])),
                if (labelSaque != null && _pos(data['fgtsSaqueDisponivel']))
                  _pdfRow(labelSaque, _fmt(data['fgtsSaqueDisponivel'])),
                pw.SizedBox(height: 12),
              ],

              // Totais
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),
              _pdfRow(
                'Total Bruto:',
                _fmt(data['totalBruto'] ?? data['bruto'] ?? 0),
              ),
              _pdfRow(
                'Total de Descontos:',
                '- ${_fmt(data['totalDescontos'] ?? 0)}',
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                child: _pdfRow(
                  'VALOR LÍQUIDO A RECEBER:',
                  _fmt(
                    data['totalLiquido'] ??
                        data['liquido'] ??
                        data['salarioLiquido'] ??
                        data['totalSaque'] ??
                        0,
                  ),
                  isBold: true,
                ),
              ),
              pw.Spacer(),

              // Rodapé
              pw.Divider(),
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
                    'Documento informativo e educativo',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
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

  // Seção com título em negrito + linha
  static pw.Widget _pdfSection(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
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

  // Retorna true se o valor existe e é positivo
  static bool _pos(dynamic value) =>
      value != null && (value as num).toDouble() > 0;

  static Future<void> shareAsText(Map<String, dynamic> data) async {
    final modalidade = data['modalidade'] ?? 'Cálculo';
    final tipoDesligamento = data['tipoDesligamento'] ?? '';

    final totalLiquido = _fmt(
      data['totalLiquido'] ??
          data['liquido'] ??
          data['salarioLiquido'] ??
          data['totalSaque'] ??
          0,
    );

    final buffer = StringBuffer();
    buffer.writeln('📋 SIATRAB — Resumo do Cálculo');
    buffer.writeln(
      'Modalidade: $modalidade'
      '${tipoDesligamento.isNotEmpty ? ' ($tipoDesligamento)' : ''}',
    );
    buffer.writeln('');

    if (data['mesesTrabalhados'] != null)
      buffer.writeln('⏱ Meses trabalhados: ${data['mesesTrabalhados']}');
    if (data['saldoSalario'] != null)
      buffer.writeln('💰 Saldo de Salário: ${_fmt(data['saldoSalario'])}');
    if (_pos(data['avisoPrevio']))
      buffer.writeln('📢 Aviso Prévio: ${_fmt(data['avisoPrevio'])}');
    if (data['decimoTerceiro'] != null)
      buffer.writeln('🎄 13º Proporcional: ${_fmt(data['decimoTerceiro'])}');
    if (data['feriasProporcional'] != null) {
      final totalFerias =
          (data['feriasProporcional'] as num).toDouble() +
          ((data['tercoFerias'] as num?)?.toDouble() ?? 0);
      buffer.writeln('🏖 Férias + 1/3: ${_fmt(totalFerias)}');
    }
    if (_pos(data['feriasVencidas']))
      buffer.writeln('📅 Férias Vencidas: ${_fmt(data['feriasVencidas'])}');
    if (_pos(data['multaFgts']))
      buffer.writeln('⚖️ Multa FGTS: ${_fmt(data['multaFgts'])}');
    buffer.writeln('');
    buffer.writeln('➖ INSS: - ${_fmt(data['inss'] ?? 0)}');
    if (_pos(data['irrf'])) buffer.writeln('➖ IRRF: - ${_fmt(data['irrf'])}');
    buffer.writeln('');
    buffer.writeln('✅ TOTAL LÍQUIDO: $totalLiquido');

    if (_pos(data['fgtsSaqueDisponivel'])) {
      final pct = tipoDesligamento == 'Acordo mútuo' ? '80%' : '100%';
      buffer.writeln(
        '🏦 Saque FGTS disponível ($pct): ${_fmt(data['fgtsSaqueDisponivel'])}',
      );
    }

    buffer.writeln('');
    buffer.writeln('Calcule seus direitos no SIATRAB!');

    await Share.share(
      buffer.toString(),
      subject: 'Meu Cálculo Trabalhista — SIATRAB',
    );
  }
}
