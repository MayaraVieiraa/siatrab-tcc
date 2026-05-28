import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../history/repository/history_repository.dart';
import '../../../shared/utils/tax_utils.dart';

// ✅ Formatador de Moeda
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

class FeriasPage extends StatefulWidget {
  const FeriasPage({super.key});

  @override
  State<FeriasPage> createState() => _FeriasPageState();
}

class _FeriasPageState extends State<FeriasPage> {
  final _salaryController = TextEditingController();
  final _diasController = TextEditingController(text: '30');
  final _dependentesController = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  Map<String, double>? _resultado;
  bool _isSaving = false;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    _salaryController.dispose();
    _diasController.dispose();
    _dependentesController.dispose();
    super.dispose();
  }

  double _parseSalary() {
    String cleanString = _salaryController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    if (cleanString.isEmpty) return 0.0;
    // Divide por 100 para tratar os centavos da máscara de moeda corretamente
    return int.parse(cleanString) / 100;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    final salary = _parseSalary();
    final dias = int.tryParse(_diasController.text) ?? 30;
    final dependentes = int.tryParse(_dependentesController.text) ?? 0;

    // Valor das férias proporcional aos dias
    final double valorFerias = (salary / 30) * dias;
    // 1/3 constitucional — Art. 7º, XVII CF/88
    final double umTerco = valorFerias / 3;
    final double bruto = valorFerias + umTerco;

    // INSS e IRRF usando tabelas centralizadas e atualizadas 2026
    final double inss = calculateInss(bruto);
    final double irrf = calculateIrrf(bruto - inss, dependentes);

    setState(() {
      _resultado = {
        'salario': salary,
        'dias': dias.toDouble(),
        'valorFerias': valorFerias,
        'tercoFerias': umTerco,
        'bruto': bruto,
        'inss': inss,
        'irrf': irrf,
        'liquido': bruto - inss - irrf,
      };
    });
  }

  // ✅ MÉTODO CORRIGIDO DE SALVAR NO HISTÓRICO
  Future<void> _salvarNoHistorico() async {
    // Evita múltiplos cliques
    if (_isSaving) return;

    // Verifica se tem resultado
    if (_resultado == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum resultado para salvar.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Verifica autenticação
    if (!historyRepository.isUserAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faça login para salvar cálculos!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final r = _resultado!;
      final dias = r['dias']?.toInt() ?? 30;

      // Prepara dados garantindo que não há valores null
      final dataToSave = <String, dynamic>{
        'modalidade': 'Férias',
        'diasFerias': dias,
        'salario': r['salario'] ?? 0.0,
        'feriasProporcional': r['valorFerias'] ?? 0.0,
        'tercoFerias': r['tercoFerias'] ?? 0.0,
        'totalBruto': r['bruto'] ?? 0.0,
        'inss': r['inss'] ?? 0.0,
        'irrf': r['irrf'] ?? 0.0,
        'totalLiquido': r['liquido'] ?? 0.0,
        'dataCalculo': DateTime.now().toIso8601String(),
      };

      print('📤 Enviando dados de férias para o histórico: $dataToSave');

      await historyRepository.saveCalculation(dataToSave);

      print('✅ Dados de férias salvos com sucesso!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Cálculo de Férias salvo com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar férias no histórico: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Erro ao salvar: ${e.toString().replaceAll('Exception: ', '')}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
              colors: [Color(0xFF0F172A), Color(0xFF192E6A)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Cálculo de Férias 2026',
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
                      'Férias com adicional de 1/3 constitucional (Art. 7º, XVII CF/88). '
                      'INSS e IRRF calculados com tabelas atualizadas 2026.',
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
                'Dados para o Cálculo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF192E6A),
                ),
              ),
              const Divider(),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [_BRLInputFormatter()],
                decoration: _inputDecoration(
                  label: 'Salário Base',
                  prefixText: 'R\$ ',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o salário';
                  if (_parseSalary() <= 0) return 'Deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _diasController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        label: 'Dias de Férias',
                        hint: 'Ex: 30, 45, 60...',
                      ),
                      validator: (v) {
                        final d = int.tryParse(v ?? '');
                        if (d == null || d <= 0) {
                          return 'Informe dias válidos';
                        }
                        if (d > 120) {
                          return 'Máximo de 120 dias';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dependentesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(label: 'Dependentes (IRRF)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    'CALCULAR FÉRIAS',
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
    final dias = r['dias']!.toInt();
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
            _resultRow('Valor das Férias ($dias dias):', r['valorFerias']!),
            _resultRow('Adicional de 1/3 constitucional:', r['tercoFerias']!),
            const Divider(height: 16),
            _resultRow('Total Bruto:', r['bruto']!, bold: true),
            _resultRow('Desconto INSS:', r['inss']!, isNegative: true),
            _resultRow('Desconto IRRF:', r['irrf']!, isNegative: true),
            const Divider(height: 16),
            _resultRow('Líquido a Receber:', r['liquido']!, isTotal: true),
            if (r['irrf'] == 0) ...[
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
                        'Isento de IRRF — base abaixo de R\$ 5.000,00',
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

  Widget _resultRow(
    String label,
    double value, {
    bool isNegative = false,
    bool isTotal = false,
    bool bold = false,
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
              fontWeight: (isTotal || bold)
                  ? FontWeight.bold
                  : FontWeight.normal,
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF192E6A),
                ),
              )
            : const Icon(Icons.save_outlined, color: Color(0xFF192E6A)),
        label: Text(
          _isSaving ? 'SALVANDO...' : 'SALVAR NO HISTÓRICO',
          style: const TextStyle(
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
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      hintText: hint,
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
