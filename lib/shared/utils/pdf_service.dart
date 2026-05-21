import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static Future<void> generateAndShare(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final modalidade = data['modalidade'] ?? 'Rescisão';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SIATRAB - Extrato de Cálculo',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Modalidade: $modalidade',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildPdfRow(
                'Salário Base:',
                _currencyFormat.format(data['salario'] ?? 0),
              ),
              _buildPdfRow(
                'Meses Trabalhados:',
                '${data['mesesTrabalhados'] ?? '—'}',
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Detalhamento de Verbas',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Divider(),
              if (data['saldoSalario'] != null)
                _buildPdfRow(
                  'Saldo de Salário:',
                  _currencyFormat.format(data['saldoSalario']),
                ),
              if (data['avisoPrevio'] != null)
                _buildPdfRow(
                  'Aviso Prévio:',
                  _currencyFormat.format(data['avisoPrevio']),
                ),
              if (data['decimoTerceiro'] != null)
                _buildPdfRow(
                  '13º Proporcional:',
                  _currencyFormat.format(data['decimoTerceiro']),
                ),
              if (data['feriasProporcional'] != null)
                _buildPdfRow(
                  'Férias + 1/3:',
                  _currencyFormat.format(
                    (data['feriasProporcional'] ?? 0) +
                        (data['tercoFerias'] ?? 0),
                  ),
                ),
              if (data['multaFgts'] != null)
                _buildPdfRow(
                  'Multa FGTS:',
                  _currencyFormat.format(data['multaFgts']),
                ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Descontos',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Divider(),
              if (data['inss'] != null)
                _buildPdfRow(
                  'INSS:',
                  '- ${_currencyFormat.format(data['inss'])}',
                ),
              if (data['irrf'] != null)
                _buildPdfRow(
                  'IRRF:',
                  '- ${_currencyFormat.format(data['irrf'])}',
                ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                child: _buildPdfRow(
                  'VALOR LÍQUIDO TOTAL:',
                  _currencyFormat.format(data['totalLiquido'] ?? 0),
                  isBold: true,
                ),
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Este documento tem fins meramente educativos.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Compartilhar o PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'extrato_siatrab_${modalidade.toLowerCase()}.pdf',
    );
  }

  static pw.Widget _buildPdfRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> shareAsText(Map<String, dynamic> data) async {
    final modalidade = data['modalidade'] ?? 'Cálculo';
    final total = _currencyFormat.format(data['totalLiquido'] ?? 0);

    final text =
        'SIATRAB - Resumo do Cálculo ($modalidade)\n\n'
        'Salário: ${_currencyFormat.format(data['salario'] ?? 0)}\n'
        'Total Líquido: $total\n\n'
        'Calcule você também no SIATRAB!';

    await Share.share(text, subject: 'Meu Cálculo Trabalhista');
  }
}
