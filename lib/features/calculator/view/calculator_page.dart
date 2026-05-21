import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodel/calculator_viewmodel.dart';

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

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  final _salaryController = TextEditingController();
  final _horasExtrasController = TextEditingController(text: '0');
  final _feriasVencidasController = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();

  String _tipoAviso = 'Indenizado';
  int _dependentes = 0;
  DateTime? _dataAdmissao;
  DateTime? _dataDemissao;
  String _adicionalInsalubridade = 'Não';
  String _tipoDesligamento = 'Sem justa causa';

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
    _feriasVencidasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isAdmissao) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isAdmissao)
          _dataAdmissao = picked;
        else
          _dataDemissao = picked;
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF192E6A)],
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
                  _buildCurrencyField(),
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
                          _dataAdmissao,
                          () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          'Demissão',
                          _dataDemissao,
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Total de Dias de Férias Vencidas',
                    controller: _feriasVencidasController,
                    hint: 'Ex: 30, 45, 60...',
                    icon: Icons.beach_access_rounded,
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
                    label: 'Horas Extras no Mês (Quantidade)',
                    controller: _horasExtrasController,
                    hint: 'Ex: 10, 50, 200...',
                    icon: Icons.more_time_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildStepperField(
                    label: 'Nº de Dependentes',
                    value: _dependentes,
                    onDecrement: () => setState(() {
                      if (_dependentes > 0) _dependentes--;
                    }),
                    onIncrement: () => setState(() => _dependentes++),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192E6A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: calcState.isLoading ? null : _onCalculate,
                child: calcState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CALCULAR RESCISÃO',
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
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _onCalculate() async {
    if (_formKey.currentState!.validate()) {
      if (_dataAdmissao == null || _dataDemissao == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecione as datas.')));
        return;
      }
      final input = CalculatorInput(
        salary: _parseSalary(),
        tipoAviso: _tipoAviso,
        feriasVencidas: _feriasVencidasController.text,
        dependentes: _dependentes,
        dataAdmissao: _dataAdmissao!,
        dataDemissao: _dataDemissao!,
        insalubridade: _adicionalInsalubridade,
        horasExtras: int.tryParse(_horasExtrasController.text) ?? 0,
        tipoDesligamento: _tipoDesligamento,
      );
      await ref.read(calculatorViewModelProvider.notifier).calculate(input);
      if (context.mounted) {
        context.push(
          '/calculator/result',
          extra: {'dataAdmissao': _dataAdmissao, 'dataDemissao': _dataDemissao},
        );
      }
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF192E6A)),
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salário Bruto Mensal',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _salaryController,
          keyboardType: TextInputType.number,
          inputFormatters: [_BRLInputFormatter()],
          decoration: InputDecoration(
            prefixText: 'R\$ ',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null
                      ? 'Selecionar'
                      : DateFormat('dd/MM/yy').format(value),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF192E6A),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperField({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrement,
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
            ],
          ),
        ),
      ],
    );
  }
}
