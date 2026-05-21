import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../history/repository/history_repository.dart';

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

  double _parseSalary() {
    return double.tryParse(
          _salaryController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    final salary = _parseSalary();
    final meses = int.tryParse(_mesesController.text) ?? 0;

    final fgtsDepositado = salary * 0.08 * meses;
    double multaFgts = 0;
    double valorSaqueFgts = 0;

    if (_tipoDesligamento == 'Sem justa causa') {
      multaFgts = fgtsDepositado * 0.40;
      valorSaqueFgts = fgtsDepositado + multaFgts;
    } else if (_tipoDesligamento == 'Acordo mútuo') {
      multaFgts = fgtsDepositado * 0.20;
      valorSaqueFgts = (fgtsDepositado * 0.80) + multaFgts;
    } else {
      multaFgts = 0;
      valorSaqueFgts = 0;
    }

    setState(() {
      _resultado = {
        'salario': salary,
        'meses': meses.toDouble(),
        'depositoMensal': salary * 0.08,
        'saldoFgts': fgtsDepositado,
        'multa': multaFgts,
        'totalSaque': valorSaqueFgts,
      };
    });
  }

  Future<void> _salvarNoHistorico() async {
    if (_resultado == null) return;
    try {
      await historyRepository.saveCalculation({
        'modalidade': 'FGTS',
        'salario': _resultado!['salario'],
        'mesesTrabalhados': _resultado!['meses']?.toInt(),
        'saldoFgts': _resultado!['saldoFgts'],
        'multaFgts': _resultado!['multa'],
        'totalLiquido': _resultado!['totalSaque'],
        'dataAdmissao': DateTime.now().toIso8601String(),
        'dataDemissao': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo de FGTS salvo!'),
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
          onPressed: () => context.go('/home'),
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
                      'Cálculo de 8% mensal + multa rescisória conforme modalidade.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF192E6A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      _buildLabel('Salário Bruto'),
                      TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(prefixText: 'R\$ '),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe o salário'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Meses Trabalhados'),
                      TextFormField(
                        controller: _mesesController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hintText: 'Ex: 12'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe os meses'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Motivo do Desligamento'),
                      DropdownButtonFormField<String>(
                        value: _tipoDesligamento,
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
              ),
              onPressed: _calcular,
              child: const Text(
                'CALCULAR FGTS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                ),
                onPressed: _salvarNoHistorico,
                icon: const Icon(Icons.save_outlined),
                label: const Text('SALVAR NO HISTÓRICO'),
              ),
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

  Widget _buildResultado() {
    final r = _resultado!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Saldo FGTS:', r['saldoFgts']!),
            if (r['multa']! > 0) _row('Multa:', r['multa']!),
            const Divider(),
            _row('Total Saque:', r['totalSaque']!, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double val, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _currencyFormat.format(val),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
  );

  InputDecoration _inputDecoration({String? prefixText, String? hintText}) =>
      InputDecoration(
        prefixText: prefixText,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );
}
