import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Importação necessária para os InputFormatters
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../history/repository/history_repository.dart';
import '../../../shared/utils/tax_utils.dart';

// ✅ Adicionado o formatador de moeda para o campo de salário
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

class InssPage extends StatefulWidget {
  const InssPage({super.key});

  @override
  State<InssPage> createState() => _InssPageState();
}

class _InssPageState extends State<InssPage> {
  final _salaryController = TextEditingController();
  final _dependentesController = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  Map<String, double>? _resultado;
  bool _isSaving = false;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    _salaryController.dispose();
    _dependentesController.dispose();
    super.dispose();
  }

  double _parseSalary() {
    return double.tryParse(
          _salaryController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    final salary = _parseSalary();
    final dependentes = int.tryParse(_dependentesController.text) ?? 0;

    final inss = calculateInss(salary);
    final baseIrrf = salary - inss;
    final irrf = calculateIrrf(baseIrrf, dependentes);

    setState(() {
      _resultado = {
        'salarioBruto': salary,
        'descontoINSS': inss,
        'descontoIRRF': irrf,
        'totalDescontos': inss + irrf,
        'salarioLiquido': salary - inss - irrf,
        'aliquotaEfetivaINSS': salary > 0 ? (inss / salary) * 100 : 0,
      };
    });
  }

  Future<void> _salvarNoHistorico() async {
    if (_resultado == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await historyRepository.saveCalculation({
        'modalidade': 'INSS',
        'salario': _resultado!['salarioBruto'],
        'inss': _resultado!['descontoINSS'],
        'irrf': _resultado!['descontoIRRF'],
        'totalLiquido': _resultado!['salarioLiquido'],
        'dataAdmissao': DateTime.now().toIso8601String(),
        'dataDemissao': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo de INSS salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar no histórico.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              colors: [Color(0xFF0F172A), Color(0xFF192E6A)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Calculadora de INSS 2026',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Info card
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
                      'Tabela progressiva INSS 2026 (Port. MPS/MF nº 02/2026). '
                      'IRRF com isenção até R\$ 5.000,00 (Lei nº 14.848/2024).',
                      style: TextStyle(fontSize: 12, color: Color(0xFF192E6A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInputCard(),
            if (_resultado != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
              const SizedBox(height: 16),
              _buildTabelaINSS(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInputCard() {
    return Card(
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
                'Dados do Salário',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF192E6A),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _BRLInputFormatter(),
                ], // ✅ Formatador BRL aplicado
                decoration: _inputDecoration(
                  label: 'Salário Bruto Mensal',
                  prefixText: 'R\$ ',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o salário';
                  if (_parseSalary() <= 0)
                    return 'O salário deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dependentesController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ], // ✅ Bloqueia letras e pontos
                decoration: _inputDecoration(
                  label: 'Número de Dependentes (IRRF)',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192E6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _calcular,
                  child: const Text(
                    'CALCULAR DESCONTOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final r = _resultado!;
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
              ),
            ),
            const Divider(),
            _resultRow('Salário Bruto:', r['salarioBruto']!),
            _resultRow(
              'Desconto INSS (progressivo):',
              r['descontoINSS']!,
              isNegative: true,
            ),
            _resultRow('Desconto IRRF:', r['descontoIRRF']!, isNegative: true),
            const Divider(height: 20),
            _resultRow('Salário Líquido:', r['salarioLiquido']!, isTotal: true),
            const SizedBox(height: 10),
            // Alíquota efetiva
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF192E6A).withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alíquota efetiva INSS:',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    '${r['aliquotaEfetivaINSS']!.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF192E6A),
                    ),
                  ),
                ],
              ),
            ),
            if (r['descontoIRRF'] == 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Isento de IRRF — base de cálculo abaixo de R\$ 5.000,00',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabelaINSS() {
    final salary = _parseSalary();
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
              'Tabela INSS 2026 (progressiva)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF192E6A),
              ),
            ),
            const Divider(),
            _tabelaFaixa(
              'Até R\$ 1.621,00',
              '7,5%',
              salary > 0 && salary <= 1621.00,
            ),
            _tabelaFaixa(
              'R\$ 1.621,01 a R\$ 2.902,84',
              '9,0%',
              salary > 1621.00 && salary <= 2902.84,
            ),
            _tabelaFaixa(
              'R\$ 2.902,85 a R\$ 4.354,27',
              '12,0%',
              salary > 2902.84 && salary <= 4354.27,
            ),
            _tabelaFaixa(
              'R\$ 4.354,28 a R\$ 8.475,55',
              '14,0%',
              salary > 4354.27 && salary <= 8475.55,
            ),
            _tabelaFaixa(
              'Acima de R\$ 8.475,55',
              'Teto R\$ 951,00',
              salary > 8475.55,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabelaFaixa(String faixa, String aliquota, bool ativa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ativa
            ? const Color(0xFF192E6A).withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: ativa
            ? Border.all(color: const Color(0xFF192E6A).withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            faixa,
            style: TextStyle(
              fontSize: 12,
              color: ativa ? const Color(0xFF192E6A) : Colors.black45,
              fontWeight: ativa ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            aliquota,
            style: TextStyle(
              fontSize: 12,
              color: ativa ? const Color(0xFF192E6A) : Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(
    String label,
    double value, {
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isNegative && value > 0 ? '- ' : ''}${_currencyFormat.format(value)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isNegative && value > 0
                  ? Colors.red
                  : (isTotal ? const Color(0xFF192E6A) : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF192E6A)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isSaving ? null : _salvarNoHistorico,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined, color: Color(0xFF192E6A)),
        label: const Text(
          'SALVAR NO HISTÓRICO',
          style: TextStyle(
            color: Color(0xFF192E6A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF192E6A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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
