import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

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
          'Termos de Uso',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Termos de Uso'),
            _BodyText(
              'Última atualização: maio de 2026\n\n'
              'Ao utilizar o SIATRAB, você concorda com os termos descritos abaixo. '
              'Leia com atenção antes de usar o aplicativo.',
            ),
            _SectionTitle('1. Sobre o Aplicativo'),
            _BodyText(
              'O SIATRAB é um sistema educativo de apoio ao trabalhador, desenvolvido como '
              'Trabalho de Conclusão de Curso (TCC). Seu objetivo é auxiliar na compreensão '
              'de cálculos trabalhistas e dúvidas relacionadas à legislação brasileira (CLT).',
            ),
            _SectionTitle('2. Uso Permitido'),
            _BodyText(
              'O aplicativo pode ser utilizado para:\n\n'
              '• Consultar informações sobre direitos trabalhistas\n'
              '• Realizar simulações de cálculos rescisórios\n'
              '• Tirar dúvidas sobre a CLT por meio do chatbot educativo\n\n'
              'É proibido utilizar o aplicativo para fins ilegais, fraudulentos ou que violem direitos de terceiros.',
            ),
            _SectionTitle('3. Limitação de Responsabilidade'),
            _BodyText(
              'Os cálculos e informações apresentados pelo SIATRAB têm caráter exclusivamente educativo e orientativo. '
              'Eles não substituem a consulta a um advogado trabalhista ou profissional habilitado.\n\n'
              'O SIATRAB não se responsabiliza por decisões tomadas com base nas informações fornecidas pelo aplicativo.',
            ),
            _SectionTitle('4. Propriedade Intelectual'),
            _BodyText(
              'Todo o conteúdo do aplicativo — incluindo código-fonte, design, textos e base de conhecimento — '
              'é de propriedade dos desenvolvedores do projeto e protegido pela legislação de direitos autorais.\n\n'
              'É proibida a reprodução, distribuição ou modificação sem autorização prévia.',
            ),
            _SectionTitle('5. Conta do Usuário'),
            _BodyText(
              'Você é responsável por manter a confidencialidade das suas credenciais de acesso. '
              'Em caso de uso não autorizado da sua conta, notifique imediatamente os responsáveis pelo projeto.\n\n'
              'O SIATRAB reserva-se o direito de suspender contas que violem estes termos.',
            ),
            _SectionTitle('6. Alterações nos Termos'),
            _BodyText(
              'Estes termos podem ser atualizados a qualquer momento. '
              'O uso continuado do aplicativo após alterações implica na aceitação dos novos termos.',
            ),
            _SectionTitle('7. Legislação Aplicável'),
            _BodyText(
              'Estes Termos de Uso são regidos pela legislação brasileira. '
              'Eventuais disputas serão resolvidas no foro da comarca competente.',
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF192E6A),
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
    );
  }
}
