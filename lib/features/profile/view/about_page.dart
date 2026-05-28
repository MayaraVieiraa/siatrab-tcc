import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Sobre o Aplicativo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Logo / ícone central
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF192E6A)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF192E6A).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.balance, color: Colors.white, size: 48),
            ),

            const SizedBox(height: 20),
            const Text(
              'SIATRAB',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192E6A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Versão 1.0.0',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sistema de Apoio ao Trabalhador para\nCálculos e Dúvidas Trabalhistas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Sobre o projeto
            const _InfoSection(
              icon: Icons.school_outlined,
              title: 'Projeto Acadêmico',
              content:
                  'O SIATRAB é um Trabalho de Conclusão de Curso (TCC) '
                  'desenvolvido como requisito parcial para obtenção do título '
                  'de graduação em Tecnologia em Sistemas para Internet.',
            ),

            const _InfoSection(
              icon: Icons.lightbulb_outline,
              title: 'Objetivo',
              content:
                  'Apoiar trabalhadores brasileiros na compreensão de seus direitos '
                  'trabalhistas, oferecendo uma ferramenta educativa para simulação '
                  'de cálculos rescisórios e consulta à legislação vigente (CLT).',
            ),

            const _InfoSection(
              icon: Icons.code_outlined,
              title: 'Tecnologias Utilizadas',
              content:
                  '• Flutter & Dart — desenvolvimento mobile\n'
                  '• Firebase Auth — autenticação de usuários\n'
                  '• Cloud Firestore — banco de dados\n'
                  '• Riverpod — gerenciamento de estado\n'
                  '• GoRouter — navegação\n'
                  '• Arquitetura MVVM',
            ),

            const _InfoSection(
              icon: Icons.gavel_outlined,
              title: 'Base Legal',
              content:
                  'Os cálculos e informações apresentados são baseados na '
                  'Consolidação das Leis do Trabalho (CLT) e legislação '
                  'trabalhista brasileira vigente.',
            ),

            const _InfoSection(
              icon: Icons.warning_amber_outlined,
              title: 'Aviso Importante',
              content:
                  'Este aplicativo tem finalidade exclusivamente educativa. '
                  'Os cálculos apresentados são simulações e não substituem '
                  'a orientação de um advogado trabalhista ou profissional habilitado.',
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Rodapé
            const Text(
              '© 2026 SIATRAB',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Desenvolvido para fins acadêmicos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF192E6A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF192E6A), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192E6A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
