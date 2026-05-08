import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/calculator_viewmodel.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  final _salaryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _tipoAviso = 'Indenizado';
  String _feriasvencidas = '30 dias';
  int _dependentes = 0;
  DateTime? _dataAdmissao;
  DateTime? _dataDemissao;
  String _adicionalInsalubridade = 'Não';
  int _horasExtras = 0;
  String _tipoDesligamento = 'Sem justa causa';

  final List<String> _tiposAviso = ['Indenizado', 'Trabalhado'];
  final List<String> _feriasoptions = ['0 dias', '15 dias', '30 dias'];
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
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isAdmissao) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF192E6A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isAdmissao) {
          _dataAdmissao = picked;
        } else {
          _dataDemissao = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Selecionar';
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} de ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        flexibleSpace: Container(
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
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
        title: const Row(
          children: [
            Icon(Icons.calculate, size: 24),
            SizedBox(width: 10),
            Text(
              'Calculadora rescisão',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: 'Salário Bruto Mensal:',
                controller: _salaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o salário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Tipo de Aviso',
                      value: _tipoAviso,
                      items: _tiposAviso,
                      onChanged: (v) => setState(() => _tipoAviso = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Férias vencidas:',
                      value: _feriasvencidas,
                      items: _feriasoptions,
                      onChanged: (v) => setState(() => _feriasvencidas = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStepperField(
                label: 'Possui dependentes?',
                value: _dependentes,
                onDecrement: () {
                  if (_dependentes > 0) setState(() => _dependentes--);
                },
                onIncrement: () => setState(() => _dependentes++),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Data de admissão',
                      value: _formatDate(_dataAdmissao),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'Data de demissão',
                      value: _formatDate(_dataDemissao),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Adicional de insalubridade?',
                      value: _adicionalInsalubridade,
                      items: _insalubridades,
                      onChanged: (v) =>
                          setState(() => _adicionalInsalubridade = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStepperField(
                      label: 'Horas extras acumuladas?',
                      value: _horasExtras,
                      onDecrement: () {
                        if (_horasExtras > 0) setState(() => _horasExtras--);
                      },
                      onIncrement: () => setState(() => _horasExtras++),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Tipo de desligamento:',
                value: _tipoDesligamento,
                items: _tiposDesligamento,
                onChanged: (v) => setState(() => _tipoDesligamento = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C78FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: calcState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_dataAdmissao == null ||
                                _dataDemissao == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Informe as datas de admissão e demissão',
                                  ),
                                ),
                              );
                              return;
                            }

                            final input = CalculatorInput(
                              salary: double.parse(_salaryController.text),
                              tipoAviso: _tipoAviso,
                              feriasVencidas: _feriasvencidas,
                              dependentes: _dependentes,
                              dataAdmissao: _dataAdmissao!,
                              dataDemissao: _dataDemissao!,
                              insalubridade: _adicionalInsalubridade,
                              horasExtras: _horasExtras,
                              tipoDesligamento: _tipoDesligamento,
                            );

                            await ref
                                .read(calculatorViewModelProvider.notifier)
                                .calculate(input);

                            if (context.mounted) {
                              context.push(
                                '/calculator/result',
                                extra: {
                                  'dataAdmissao': _dataAdmissao,
                                  'dataDemissao': _dataDemissao,
                                },
                              );
                            }
                          }
                        },
                  child: calcState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CALCULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
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
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF192E6A),
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
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
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: onDecrement,
                color: const Color(0xFF192E6A),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: onIncrement,
                color: const Color(0xFF192E6A),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
