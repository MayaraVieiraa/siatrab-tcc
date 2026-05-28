import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para o TextInputFormatter
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../history/repository/history_repository.dart';

// ✅ Adicionado o formatador de moeda para garantir que o campo de salário funciona
class _BRLInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final value = int.parse(digits);
    final formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    ).format(value / 100);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class FgtsPage extends StatefulWidget {
  const FgtsPage({super.key});

  @override
  State<FgtsPage> createState() => _FgtsPageState();
}

class _FgtsPageState extends State<FgtsPage> {
  final _salaryController = TextEditingController();
  final _mesesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _tipoDesligamento = 'Sem justa causa';
  Map<String, double>? _resultado;

  final _tiposDesligamento = [
    'Sem justa causa',
    'Com justa causa',
    'Pedido de demissão',
    'Acordo mútuo',
  ];

  final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _salaryController.dispose();
    _mesesController.dispose();
    super.dispose();
  }

  // ✅ Atualizado para lidar corretamente com a máscara de moeda
  double _parseSalary() {
    final text = _salaryController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(text) ?? 0.0;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    final salary = _parseSalary();
    final meses = int.tryParse(_mesesController.text) ?? 0;

    // ✅ Correção matemática: A cada 12 meses, há 1 mês de 13º e 1/3 de férias que também geram FGTS.
    // Fator de correção: 1 (salário base) + 0.0833 (13º) + 0.0277 (1/3 férias) ≈ 1.111
    final double fatorProporcionalAnual = 1 + (1 / 12) + (1 / 36);

    // Depósito estimado = (Salário * 8%) * Meses * Fator de verbas sazonais
    final fgtsDepositado = (salary * 0.08) * meses * fatorProporcionalAnual;

    double multaFgts = 0;
    double saqueDisponivel = 0;

    if (_tipoDesligamento == 'Sem justa causa') {
      multaFgts = fgtsDepositado * 0.40;
      saqueDisponivel = fgtsDepositado;
    } else if (_tipoDesligamento == 'Acordo mútuo') {
      multaFgts = fgtsDepositado * 0.20;
      saqueDisponivel = fgtsDepositado * 0.80;
    } else {
      multaFgts = 0;
      saqueDisponivel = 0;
    }

    setState(() {
      _resultado = {
        'salario': salary,
        'meses': meses.toDouble(),
        'depositoMensal': salary * 0.08,
        'saldoFgts': fgtsDepositado,
        'multa': multaFgts,
        'saqueDisponivel': saqueDisponivel,
        'totalSaque': saqueDisponivel,
      };
    });
  }

  Future<void> _salvarNoHistorico() async {
    if (_resultado == null) return;
    try {
      await historyRepository.saveCalculation({
        'modalidade': 'FGTS',
        'tipoDesligamento': _tipoDesligamento,
        'salario': _resultado!['salario'],
        'mesesTrabalhados': _resultado!['meses']?.toInt(),
        'depositoMensal': _resultado!['depositoMensal'],
        'saldoFgts': _resultado!['saldoFgts'],
        'multaFgts': _resultado!['multa'],
        'saqueDisponivel': _resultado!['saqueDisponivel'],
        'totalLiquido':
            _resultado!['totalSaque'], // Neste contexto de ferramenta isolada, o líquido é o que ele pode sacar
        'dataAdmissao': DateTime.now()
            .toIso8601String(), // Poderia pedir as datas exatas, mas o fallback atual atende a lógica de histórico.
        'dataDemissao': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo de FGTS salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar cálculo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF192E6A)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () =>
              context.pop(), // Note: se a estrutura for baseada em go_router
        ),
        title: const Text(
          'Calcular FGTS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nota informativa
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF192E6A).withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF192E6A).withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF192E6A),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Estimativa que inclui projeções de 13º e 1/3 de Férias. '
                      'Multa e saque variam conforme a modalidade de desligamento '
                      '(Art. 484-A CLT e Art. 18 §1º Lei nº 8.036/90).',
                      style: TextStyle(fontSize: 12, color: Color(0xFF192E6A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Formulário
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados do Contrato',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF192E6A),
                        ),
                      ),
                      const Divider(),
                      _buildLabel('Salário Bruto Mensal'),
                      TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_BRLInputFormatter()], // ✅ Aplicado
                        decoration: _inputDecoration(prefixText: 'R\$ '),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Informe o salário';
                          if (_parseSalary() <= 0)
                            return 'Valor deve ser maior que zero';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Meses Trabalhados'),
                      TextFormField(
                        controller: _mesesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ], // ✅ Bloqueia caracteres
                        decoration: _inputDecoration(hintText: 'Ex: 12, 24...'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe os meses'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Motivo do Desligamento'),
                      DropdownButtonFormField<String>(
                        value: _tipoDesligamento,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        items: _tiposDesligamento
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _tipoDesligamento = v!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192E6A),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _calcular,
              child: const Text(
                'CALCULAR FGTS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            if (_resultado != null) ...[
              const SizedBox(height: 20),
              _buildResultado(),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Color(0xFF192E6A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _salvarNoHistorico,
                icon: const Icon(Icons.save_outlined, color: Color(0xFF192E6A)),
                label: const Text(
                  'SALVAR NO HISTÓRICO',
                  style: TextStyle(
                    color: Color(0xFF192E6A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
      // Mantenha o seu _buildBottomNav original aqui se necessário
    );
  }

  Widget _buildResultado() {
    final r = _resultado!;
    final bool temDireito =
        _tipoDesligamento == 'Sem justa causa' ||
        _tipoDesligamento == 'Acordo mútuo';

    final String labelMulta = _tipoDesligamento == 'Acordo mútuo'
        ? 'Multa Rescisória (20%):'
        : 'Multa Rescisória (40%):';
    final String labelSaque = _tipoDesligamento == 'Acordo mútuo'
        ? 'Saque disponível (80% do saldo):'
        : 'Saque disponível (100% do saldo):';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF192E6A),
                fontSize: 16,
              ),
            ),
            const Divider(height: 24),

            _row('Depósito mensal base (8%):', r['depositoMensal']!),
            _row('Saldo estimado na conta:', r['saldoFgts']!),

            // Nota sobre JAM
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 4),
              child: Text(
                '* Valor não contempla juros e correções monetárias (JAM) da Caixa.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const Divider(height: 8),

            if (temDireito) ...[
              const SizedBox(height: 8),
              _row(labelMulta, r['multa']!),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'A multa é encargo do empregador e adicionada ao valor do saque.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _row(
                  labelSaque,
                  r['saqueDisponivel']!,
                  bold: true,
                  highlight: true,
                  isLarge: true,
                ),
              ),
            ] else ...[
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Não há direito ao saque do FGTS nem à multa rescisória nesta modalidade.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            if (_tipoDesligamento == 'Sem justa causa')
              _infoChip(
                Icons.check_circle_outline,
                'Direito ao Seguro-Desemprego (verifique carência)',
                Colors.green,
              )
            else if (_tipoDesligamento == 'Acordo mútuo')
              _infoChip(
                Icons.info_outline,
                'Acordo mútuo não dá direito ao Seguro-Desemprego',
                Colors.orange,
              )
            else
              _infoChip(
                Icons.cancel_outlined,
                'Sem direito ao Seguro-Desemprego',
                Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _row(
    String label,
    double val, {
    bool bold = false,
    bool highlight = false,
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: isLarge ? 14 : 13,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            _currencyFormat.format(val),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: isLarge ? 16 : 13,
              color: highlight ? const Color(0xFF192E6A) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  InputDecoration _inputDecoration({String? prefixText, String? hintText}) =>
      InputDecoration(
        prefixText: prefixText,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );
}
