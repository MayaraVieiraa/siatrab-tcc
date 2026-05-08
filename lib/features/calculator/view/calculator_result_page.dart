import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/calculator_viewmodel.dart';

class CalculatorResultPage extends ConsumerWidget {
  final Map<String, dynamic> data;

  const CalculatorResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorViewModelProvider);
    final result = calcState.result;

    if (result == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF101D42),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final admissao = data['dataAdmissao'] as DateTime;
    final demissao = data['dataDemissao'] as DateTime;

    return Scaffold(
      backgroundColor: const Color(0xFF101D42),
      body: Column(
        children: [
          _buildHeader(context),
          _buildMenuTabs(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBody(result, admissao, demissao),
                  _buildActionButtons(context, ref),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
      color: const Color(0xFF101D42),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/calculator'),
          ),
          const Text(
            'Resultado da Rescisão',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTabs() {
    return Container(
      color: const Color(0xFF101D42),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('RESUMO RÁPIDO', true),
            _buildTab('VALORES CHAVE', false),
            _buildTab('DESCONTOS DETALHADOS', false),
            _buildTab('INFORMAÇÕES ADICIONAIS', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF101D42) : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(
      CalculatorResult result, DateTime admissao, DateTime demissao) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Resumo rápido'),
          const SizedBox(height: 12),
          _buildInfoRow('Nº Identificação:', '#0001'),
          _buildInfoRow('Data de Admissão:', _formatDate(admissao)),
          _buildInfoRow('Data de Desligamento:', _formatDate(demissao)),
          _buildInfoRow(
              'Meses Trabalhados:', '${result.mesesTrabalhados} meses'),
          const Divider(height: 28),
          _buildSectionTitle('Verbas Chave'),
          const SizedBox(height: 12),
          _buildValueRow('Valor Bruto da Rescisão:', result.totalBruto,
              bold: true, highlight: true),
          _buildValueRow('Valor dos Descontos:', result.totalDescontos,
              isNegative: true),
          _buildValueRow('Valor Líquido a Receber:', result.totalLiquido,
              bold: true, highlight: true),
          const Divider(height: 28),
          _buildSectionTitle('Verbas rescisórias - detalhamento'),
          const SizedBox(height: 12),
          _buildValueRow('Saldo de Salário:', result.saldoSalario),
          _buildValueRow('Aviso Prévio Indenizado:', result.avisoPrevio),
          _buildValueRow(
              '13º Salário Proporcional:', result.decimoTerceiroProporcional),
          _buildValueRow('Férias Proporcionais + 1/3:',
              result.feriasProporcional + result.tercoFerias),
          _buildValueRow('Férias Vencidas:', result.feriasVencidas),
          _buildValueRow('Multa de 40% s/ FGTS:', result.multaFgts),
          _buildValueRow('FGTS Depósito:', result.fgtsDeposito),
          if (result.insalubridade > 0)
            _buildValueRow('Adicional de Insalubridade:', result.insalubridade),
          if (result.horasExtrasValor > 0)
            _buildValueRow('Horas Extras:', result.horasExtrasValor),
          const Divider(height: 28),
          _buildSectionTitle('Descontos Detalhados'),
          const SizedBox(height: 12),
          _buildValueRow('INSS:', result.inss, isNegative: true),
          _buildValueRow('Outros Descontos:', 0, isNegative: true),
          const Divider(height: 28),
          _buildSectionTitle('Informações Adicionais'),
          const SizedBox(height: 12),
          _buildInfoRow('Liberação do FGTS:', 'Mediante homologação'),
          _buildInfoRow('Prazo para pagamento:', '10 dias úteis'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF101D42),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildValueRow(
    String label,
    double value, {
    bool bold = false,
    bool highlight = false,
    bool isNegative = false,
  }) {
    final color = highlight
        ? const Color(0xFF101D42)
        : isNegative
            ? Colors.red
            : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${isNegative && value > 0 ? '-' : ''}R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionButton(
            label: 'SALVAR CÁLCULO',
            icon: Icons.save_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cálculo salvo com sucesso!'),
                    backgroundColor: Colors.green),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'EXPORTAR PDF',
            icon: Icons.picture_as_pdf_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'COMPARTILHAR',
            icon: Icons.share_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'REFAZER CÁLCULO',
            icon: Icons.refresh,
            onTap: () {
              ref.read(calculatorViewModelProvider.notifier).clear();
              context.go('/calculator');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C78FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} de ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    return months[month - 1];
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF101D42),
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
            case 0: context.go('/home'); break;
            case 1: context.go('/calculator'); break;
            case 2: context.go('/chat'); break;
            case 3: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}