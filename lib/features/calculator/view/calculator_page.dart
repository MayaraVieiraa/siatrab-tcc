import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodel/calculator_viewmodel.dart';

// =============================================================================
// FORMATADORES
// =============================================================================

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

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digits[i];
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static DateTime? parseDate(String text) {
    if (text.length != 10) return null;
    try {
      final parts = text.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;
      if (year < 1950 || year > 2030) return null;
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  // Variável estática para o aviso (sem erros de Provider)
  static bool _avisoTccExibido = false;

  final _salaryController = TextEditingController();
  final _horasExtrasController = TextEditingController(text: '0');
  final _horasExtrasFeriadosController = TextEditingController(text: '0');
  final _feriasVencidasController = TextEditingController(text: '0');
  final _admissaoController = TextEditingController();
  final _demissaoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _tipoAviso = 'Indenizado';
  int _dependentes = 0;
  DateTime? _dataAdmissao;
  DateTime? _dataDemissao;
  String _adicionalInsalubridade = 'Não';
  String _tipoDesligamento = 'Sem justa causa';
  bool _empregadorDispensouAviso = false;

  final List<String> _tiposAviso = ['Indenizado', 'Trabalhado'];
  final List<String> _insalubridades = [
    'Não',
    'Sim, 10%',
    'Sim, 20%',
    'Sim, 40%',
  ];
  final List<String> _tiposDesligamento = [
    'Sem justa causa',
    'Com justa causa',
    'Pedido de demissão',
    'Acordo mútuo',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_avisoTccExibido) {
        _avisoTccExibido = true;
        _showTccAviso();
      }
    });
  }

  void _showTccAviso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Aviso de TCC',
          style: TextStyle(color: Color(0xFF192E6A)),
        ),
        content: const Text(
          'Este sistema é um projeto acadêmico. Cálculos são simulações educativas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double _parseSalary() {
    final text = _salaryController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(text) ?? 0.0;
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _horasExtrasController.dispose();
    _horasExtrasFeriadosController.dispose();
    _feriasVencidasController.dispose();
    _admissaoController.dispose();
    _demissaoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isAdmissao) async {
    DateTime initialDate = DateTime.now();
    if (isAdmissao && _dataAdmissao != null) {
      initialDate = _dataAdmissao!;
    } else if (!isAdmissao && _dataDemissao != null) {
      initialDate = _dataDemissao!;
    }

    // Usando a localidade padrão para não quebrar a aplicação (Inglês)
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isAdmissao) {
          _dataAdmissao = picked;
          _admissaoController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _dataDemissao = picked;
          _demissaoController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Calculadora Rescisão',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Dados Contratuais',
                children: [
                  _buildCurrencyField(
                    label: 'Salário Bruto Mensal',
                    controller: _salaryController,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Motivo do Desligamento',
                    value: _tipoDesligamento,
                    items: _tiposDesligamento,
                    onChanged: (v) => setState(() => _tipoDesligamento = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Período Trabalhado',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Admissão',
                          _admissaoController,
                          () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          'Demissão',
                          _demissaoController,
                          () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Aviso e Férias Vencidas',
                children: [
                  _buildDropdown(
                    label: 'Tipo de Aviso',
                    value: _tipoAviso,
                    items: _tiposAviso,
                    onChanged: (v) => setState(() => _tipoAviso = v!),
                  ),
                  if (_tipoDesligamento == 'Pedido de demissão' &&
                      _tipoAviso == 'Indenizado')
                    SwitchListTile(
                      title: const Text(
                        'Empregador dispensou o aviso?',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _empregadorDispensouAviso,
                      onChanged: (v) =>
                          setState(() => _empregadorDispensouAviso = v),
                    ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Dias de Férias Vencidas',
                    controller: _feriasVencidasController,
                    hint: 'Ex: 30',
                    icon: Icons.beach_access,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Adicionais e Dependentes',
                children: [
                  _buildDropdown(
                    label: 'Insalubridade',
                    value: _adicionalInsalubridade,
                    items: _insalubridades,
                    onChanged: (v) =>
                        setState(() => _adicionalInsalubridade = v!),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Horas Extras 50%',
                    controller: _horasExtrasController,
                    hint: '0',
                    icon: Icons.more_time,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Horas Extras 100%',
                    controller: _horasExtrasFeriadosController,
                    hint: '0',
                    icon: Icons.event_busy,
                  ),
                  const SizedBox(height: 16),
                  _buildStepperField(
                    label: 'Dependentes',
                    value: _dependentes,
                    onDecrement: () => setState(
                      () => _dependentes > 0 ? _dependentes-- : null,
                    ),
                    onIncrement: () => setState(() => _dependentes++),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192E6A),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: calcState.isLoading ? null : _onCalculate,
                child: calcState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CALCULAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(
        context,
      ), // ✅ AQUI ESTÁ O MENU INFERIOR
    );
  }

  void _onCalculate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataAdmissao == null || _dataDemissao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione as datas.')),
      );
      return;
    }

    if (_dataDemissao!.isBefore(_dataAdmissao!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data de demissão não pode ser antes da admissão.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final input = CalculatorInput(
      salary: _parseSalary(),
      tipoAviso: _tipoAviso,
      feriasVencidasDias: int.tryParse(_feriasVencidasController.text) ?? 0,
      dependentes: _dependentes,
      dataAdmissao: _dataAdmissao!,
      dataDemissao: _dataDemissao!,
      insalubridade: _adicionalInsalubridade,
      horasExtras: int.tryParse(_horasExtrasController.text) ?? 0,
      horasExtrasFeriados:
          int.tryParse(_horasExtrasFeriadosController.text) ?? 0,
      tipoDesligamento: _tipoDesligamento,
      empregadorDispensouAviso: _empregadorDispensouAviso,
    );

    await ref.read(calculatorViewModelProvider.notifier).calculate(input);

    if (mounted) {
      final result = ref.read(calculatorViewModelProvider).result;

      if (result != null) {
        context.push(
          '/calculator/result',
          extra: {
            'modalidade': 'Rescisão',
            'dataAdmissao': _dataAdmissao?.toIso8601String(),
            'dataDemissao': _dataDemissao?.toIso8601String(),
            'tipoDesligamento': _tipoDesligamento,
            'saldoSalario': result.saldoSalario,
            'insalubridadeProporcional': result.insalubridadeProporcional,
            'horasExtrasValor': result.horasExtrasValor,
            'avisoPrevio': result.avisoPrevio,
            'decimoTerceiroProporcional': result.decimoTerceiroProporcional,
            'feriasProporcional': result.feriasProporcional,
            'tercoFeriasProporcional': result.tercoFeriasProporcional,
            'feriasVencidas': result.feriasVencidas,
            'tercoFeriasVencidas': result.tercoFeriasVencidas,
            'multaFgts': result.multaFgts,
            'fgtsDepositoEstimado': result.fgtsDepositoEstimado,
            'fgtsSaqueDisponivel': result.fgtsSaqueDisponivel,
            'inss': result.inss,
            'irrf': result.irrf,
            'descontoAviso': result.descontoAviso,
            'totalBruto': result.totalBruto,
            'totalDescontos': result.totalDescontos,
            'totalLiquido': result.totalLiquido,
            'mesesTrabalhados': result.mesesTrabalhados,
            'diasAviso': result.diasAviso,
            'anosCompletos': result.anosCompletos,
          },
        );
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192E6A),
              ),
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCurrencyField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_BRLInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'R\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
    );
  }

  Widget _buildStepperField({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
            Text(
              '$value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
          ],
        ),
      ],
    );
  }

  // ✅ MÉTODO DO MENU INFERIOR (PADRÃO SIATRAB)
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
        currentIndex: 1, // 1 representa a página "Calculator"
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
