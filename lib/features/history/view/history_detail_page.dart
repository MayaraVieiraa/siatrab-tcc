import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/pdf_service.dart';
import '../../history/repository/history_repository.dart';

class HistoryDetailPage extends ConsumerWidget {
  final Map<String, dynamic> data;
  final String? docId;

  const HistoryDetailPage({super.key, required this.data, this.docId});

  double _d(String key) => (data[key] as num?)?.toDouble() ?? 0.0;

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalidade = data['modalidade'] as String? ?? 'Rescisão';
    final tipoDesligamento =
        data['tipoDesligamento'] as String? ?? 'Sem justa causa';
    final createdAt = data['createdAt'];

    String dataFormatada = '—';
    if (createdAt != null) {
      try {
        if (createdAt is String) {
          final dt = DateTime.parse(createdAt);
          dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dt);
        } else {
          final dt = (createdAt as dynamic).toDate() as DateTime;
          dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dt);
        }
      } catch (_) {}
    }

    String admissao = '—';
    String demissao = '—';
    try {
      if (data['dataAdmissao'] != null) {
        admissao = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(data['dataAdmissao'] as String));
      }
      if (data['dataDemissao'] != null) {
        demissao = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(data['dataDemissao'] as String));
      }
    } catch (_) {}

    // Compatibilidade com diferentes chaves
    final double totalBruto = _d('totalBruto') > 0
        ? _d('totalBruto')
        : _d('salario');
    final double inss = _d('inss');
    final double irrf = _d('irrf');
    final double totalDescontos = _d('totalDescontos') > 0
        ? _d('totalDescontos')
        : (inss + irrf);
    final double saldoFgtsConta = _d('fgtsDeposito') > 0
        ? _d('fgtsDeposito')
        : _d('saldoFgts');

    // Compatibilidade para valores do 13º
    final double decimoTerceiro = _d('decimoTerceiroProporcional') > 0
        ? _d('decimoTerceiroProporcional')
        : _d('decimoTerceiro');

    // Compatibilidade para horas extras
    final double horasExtras = _d('horasExtrasValor') > 0
        ? _d('horasExtrasValor')
        : _d('horasExtras');

    // Compatibilidade para saque do FGTS
    final double saqueDisponivel = _d('saqueDisponivel') > 0
        ? _d('saqueDisponivel')
        : _d('fgtsSaqueDisponivel');

    final String labelMulta = tipoDesligamento == 'Acordo mútuo'
        ? 'Multa de 20% s/ FGTS:'
        : 'Multa de 40% s/ FGTS:';

    final String labelSaque;
    final String valorSaque;
    if (tipoDesligamento == 'Sem justa causa') {
      labelSaque = 'Saque do FGTS disponível (100%):';
      valorSaque = _formatCurrency(saqueDisponivel);
    } else if (tipoDesligamento == 'Acordo mútuo') {
      labelSaque = 'Saque do FGTS disponível (80%):';
      valorSaque = _formatCurrency(saqueDisponivel);
    } else {
      labelSaque = 'Saque do FGTS:';
      valorSaque = 'Não disponível';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DiagonalPainter())),
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          'Extrato — $modalidade',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildMenuTabs(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Resumo rápido'),
                              const SizedBox(height: 12),
                              _infoRow('Modalidade:', modalidade),
                              if (modalidade == 'Rescisão' ||
                                  modalidade == 'FGTS')
                                _infoRow(
                                  'Tipo de desligamento:',
                                  tipoDesligamento,
                                ),
                              _infoRow('Data do cálculo:', dataFormatada),
                              if (admissao != '—')
                                _infoRow('Data de Admissão:', admissao),
                              if (demissao != '—')
                                _infoRow('Data de Demissão:', demissao),
                              if (data['mesesTrabalhados'] != null)
                                _infoRow(
                                  'Meses Trabalhados:',
                                  '${data['mesesTrabalhados']} meses',
                                ),
                              const Divider(height: 28),

                              _sectionTitle('Valores chave'),
                              const SizedBox(height: 12),
                              _valueRow(
                                'Valor Base / Bruto:',
                                totalBruto,
                                bold: true,
                                highlight: true,
                              ),
                              if (totalDescontos > 0)
                                _valueRow(
                                  'Total de Descontos:',
                                  totalDescontos,
                                  isNegative: true,
                                ),
                              _valueRow(
                                modalidade == 'FGTS'
                                    ? 'Total Liberado para Saque:'
                                    : 'Valor Líquido a Receber:',
                                _d('totalLiquido'),
                                bold: true,
                                highlight: true,
                              ),
                              const Divider(height: 28),

                              _sectionTitle('Detalhamento'),
                              const SizedBox(height: 12),

                              if (modalidade == 'Rescisão') ...[
                                if (_d('saldoSalario') > 0)
                                  _valueRow(
                                    'Saldo de Salário:',
                                    _d('saldoSalario'),
                                  ),
                                if (_d('avisoPrevio') > 0)
                                  _valueRow(
                                    'Aviso Prévio Indenizado:',
                                    _d('avisoPrevio'),
                                  ),
                                if (decimoTerceiro > 0)
                                  _valueRow(
                                    '13º Salário Proporcional:',
                                    decimoTerceiro,
                                  ),
                                if ((_d('feriasProporcional') +
                                        _d('tercoFerias')) >
                                    0)
                                  _valueRow(
                                    'Férias Proporcionais + 1/3:',
                                    _d('feriasProporcional') +
                                        _d('tercoFerias'),
                                  ),
                                if (_d('feriasVencidas') > 0)
                                  _valueRow(
                                    'Férias Vencidas:',
                                    _d('feriasVencidas'),
                                  ),
                                if (_d('insalubridade') > 0)
                                  _valueRow(
                                    'Adicional de Insalubridade:',
                                    _d('insalubridade'),
                                  ),
                                if (horasExtras > 0)
                                  _valueRow('Horas Extras:', horasExtras),
                              ],

                              if (modalidade == 'Férias') ...[
                                if (_d('feriasProporcional') > 0)
                                  _valueRow(
                                    'Férias Proporcionais:',
                                    _d('feriasProporcional'),
                                  ),
                                if (_d('tercoFerias') > 0)
                                  _valueRow(
                                    'Adicional 1/3 Constitucional:',
                                    _d('tercoFerias'),
                                  ),
                              ],

                              if (_d('multaFgts') > 0)
                                _valueRow(labelMulta, _d('multaFgts')),
                              const Divider(height: 28),

                              if (inss > 0 || irrf > 0) ...[
                                _sectionTitle('Descontos detalhados'),
                                const SizedBox(height: 12),
                                if (inss > 0)
                                  _valueRow('INSS:', inss, isNegative: true),
                                if (irrf > 0)
                                  _valueRow('IRRF:', irrf, isNegative: true),
                                const Divider(height: 28),
                              ],

                              if (modalidade == 'Rescisão' ||
                                  modalidade == 'FGTS') ...[
                                _sectionTitle('FGTS'),
                                const SizedBox(height: 12),
                                if (saldoFgtsConta > 0)
                                  _valueRow(
                                    'Saldo estimado na conta:',
                                    saldoFgtsConta,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          labelSaque,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        valorSaque,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: saqueDisponivel > 0
                                              ? const Color(0xFF192E6A)
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (tipoDesligamento == 'Sem justa causa')
                                  _buildInfoChip(
                                    Icons.check_circle_outline,
                                    'Direito ao Seguro-Desemprego (verifique carência)',
                                    Colors.green,
                                  ),
                                if (tipoDesligamento == 'Acordo mútuo')
                                  _buildInfoChip(
                                    Icons.info_outline,
                                    'Acordo mútuo não dá direito ao Seguro-Desemprego',
                                    Colors.orange,
                                  ),
                                if (tipoDesligamento == 'Pedido de demissão' ||
                                    tipoDesligamento == 'Com justa causa')
                                  _buildInfoChip(
                                    Icons.cancel_outlined,
                                    'Não há direito ao Seguro-Desemprego nem saque do FGTS',
                                    Colors.red,
                                  ),
                                const Divider(height: 28),
                              ],

                              _sectionTitle('Informações adicionais'),
                              const SizedBox(height: 12),
                              if (modalidade == 'Rescisão')
                                _infoRow(
                                  'Prazo para pagamento:',
                                  '10 dias úteis (Art. 477 CLT)',
                                ),
                              _infoRow(
                                'Referência legislativa:',
                                'Lei nº 14.848/2024 · Port. MPS/MF nº 02/2026',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildActionButton(
                          label: 'EXPORTAR PDF',
                          icon: Icons.picture_as_pdf_outlined,
                          onTap: () => PdfService.generateAndShare(data),
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          label: 'COMPARTILHAR',
                          icon: Icons.share_outlined,
                          onTap: () => PdfService.shareAsText(data),
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          label: 'REFAZER CÁLCULO',
                          icon: Icons.refresh,
                          onTap: () {
                            String route = '/calculator';
                            if (modalidade == 'Férias') route = '/ferias';
                            if (modalidade == 'FGTS') route = '/fgts';
                            if (modalidade == 'INSS') route = '/inss';
                            context.go(route, extra: data);
                          },
                        ),
                        const SizedBox(height: 10),

                        if (docId != null)
                          _buildActionButton(
                            label: 'EXCLUIR CÁLCULO',
                            icon: Icons.delete_outline,
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir cálculo'),
                                  content: const Text(
                                    'Tem certeza que deseja excluir este cálculo permanentemente?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('CANCELAR'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('EXCLUIR'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && docId != null) {
                                try {
                                  await historyRepository.deleteCalculation(
                                    docId!,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Cálculo excluído com sucesso!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    context.pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao excluir: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            isDestructive: true,
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMenuTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('RESUMO RÁPIDO', true),
            _buildTab('VALORES CHAVE', false),
            _buildTab('DETALHAMENTO', false),
            _buildTab('DESCONTOS', false),
            _buildTab('INFORMAÇÕES', false),
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
          color: selected ? const Color(0xFF192E6A) : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : const Color(0xFF5C78FF),
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

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFF192E6A),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          textAlign: TextAlign.right,
        ),
      ],
    ),
  );

  Widget _valueRow(
    String label,
    double value, {
    bool bold = false,
    bool highlight = false,
    bool isNegative = false,
  }) {
    final color = highlight
        ? const Color(0xFF192E6A)
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
            '${isNegative && value > 0 ? '- ' : ''}${_formatCurrency(value)}',
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
        currentIndex: 3,
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

class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.30, size.height)
      ..lineTo(0, size.height)
      ..close();
    paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E3A8A), Color(0xFF192E6A), Color(0xFF0F172A)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
