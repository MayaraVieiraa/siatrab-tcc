import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../history/repository/history_repository.dart';

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
    final text = _salaryController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(text) ?? 0.0;
  }

  double _calculateInss(double salary) {
    if (salary <= 1621.00) return salary * 0.075;
    if (salary <= 2902.84)
      return (1621.00 * 0.075) + ((salary - 1621.00) * 0.09);
    if (salary <= 4354.27)
      return (1621.00 * 0.075) + (1281.84 * 0.09) + ((salary - 2902.84) * 0.12);
    if (salary <= 8475.55)
      return (1621.00 * 0.075) +
          (1281.84 * 0.09) +
          (1451.43 * 0.12) +
          ((salary - 4354.27) * 0.14);
    return 951.00;
  }

  double _calculateIrrf(double base, int dependentes) {
    double baseCalculo = base - (dependentes * 189.59);
    if (baseCalculo <= 5000.00) return 0;
    return (baseCalculo * 0.275) - 896.00;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    final salary = _parseSalary();
    final dias = int.tryParse(_diasController.text) ?? 30;
    final dependentes = int.tryParse(_dependentesController.text) ?? 0;

    final valorFerias = (salary / 30) * dias;
    final umTerco = valorFerias / 3;
    final bruto = valorFerias + umTerco;

    final inss = _calculateInss(bruto);
    final irrf = _calculateIrrf(bruto - inss, dependentes);

    setState(() {
      _resultado = {
        'salario': salary,
        'valorFerias': valorFerias,
        'tercoFerias': umTerco,
        'bruto': bruto,
        'inss': inss,
        'irrf': irrf,
        'liquido': bruto - inss - irrf,
      };
    });
  }

  Future<void> _salvarNoHistorico() async {
    if (_resultado == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await historyRepository.saveCalculation({
        'modalidade': 'Férias',
        'salario': _resultado!['salario'],
        'feriasProporcional': _resultado!['valorFerias'],
        'tercoFerias': _resultado!['tercoFerias'],
        'totalBruto': _resultado!['bruto'],
        'inss': _resultado!['inss'],
        'irrf': _resultado!['irrf'],
        'totalLiquido': _resultado!['liquido'],
        'dataAdmissao': DateTime.now().toIso8601String(),
        'dataDemissao': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo de Férias salvo com sucesso!'),
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
          onPressed: () => context.go('/home'),
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
            _buildInputCard(),
            if (_resultado != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
                decoration: InputDecoration(
                  labelText: 'Salário Base',
                  prefixText: 'R\$ ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF192E6A)),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o salário' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _diasController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Dias de Férias',
                        hintText: 'Ex: 30',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF192E6A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dependentesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Dependentes',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF192E6A),
                          ),
                        ),
                      ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _resultRow('Valor das Férias', r['valorFerias']!),
            _resultRow('Adicional de 1/3', r['tercoFerias']!),
            const Divider(),
            _resultRow('Total Bruto', r['bruto']!, bold: true),
            _resultRow('Desconto INSS', r['inss']!, isNegative: true),
            _resultRow('Desconto IRRF', r['irrf']!, isNegative: true),
            const Divider(),
            _resultRow('Líquido a Receber', r['liquido']!, isTotal: true),
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
            '${isNegative ? "- " : ""}${_currencyFormat.format(value)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isNegative
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
            : const Icon(Icons.save_outlined),
        label: const Text(
          'SALVAR NO HISTÓRICO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
