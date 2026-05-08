import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Política de Privacidade',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Política de Privacidade'),
            _BodyText(
              'Última atualização: maio de 2026\n\n'
              'O SIATRAB — Sistema de Apoio ao Trabalhador para Cálculos e Dúvidas Trabalhistas — é um aplicativo desenvolvido para fins educativos, '
              'no âmbito de Trabalho de Conclusão de Curso (TCC). Esta Política de Privacidade descreve como coletamos, usamos e protegemos suas informações.',
            ),
            _SectionTitle('1. Dados Coletados'),
            _BodyText(
              'Coletamos apenas os dados estritamente necessários para o funcionamento do aplicativo:\n\n'
              '• Nome completo\n'
              '• Endereço de e-mail\n'
              '• Dados inseridos nos cálculos trabalhistas (salário, datas, etc.)\n'
              '• Histórico de cálculos realizados\n\n'
              'Não coletamos dados de localização, contatos, câmera ou qualquer outro dado sensível.',
            ),
            _SectionTitle('2. Uso dos Dados'),
            _BodyText(
              'Os dados coletados são utilizados exclusivamente para:\n\n'
              '• Autenticar o usuário no aplicativo\n'
              '• Personalizar a experiência (exibir nome do usuário)\n'
              '• Armazenar o histórico de cálculos do próprio usuário\n'
              '• Melhorar o funcionamento do sistema\n\n'
              'Seus dados não são vendidos, compartilhados ou utilizados para fins publicitários.',
            ),
            _SectionTitle('3. Armazenamento e Segurança'),
            _BodyText(
              'Os dados são armazenados no Firebase (Google Cloud), plataforma que utiliza criptografia em trânsito (TLS) e em repouso. '
              'O acesso aos dados é restrito exclusivamente ao próprio usuário, por meio de regras de segurança configuradas no Firestore.\n\n'
              'Cada usuário só pode visualizar, editar ou excluir seus próprios dados.',
            ),
            _SectionTitle('4. Compartilhamento de Dados'),
            _BodyText(
              'O SIATRAB não compartilha suas informações pessoais com terceiros, exceto:\n\n'
              '• Firebase/Google: provedor de infraestrutura, sujeito à própria política de privacidade do Google\n\n'
              'Não há integração com redes sociais, plataformas de anúncios ou quaisquer outros serviços externos.',
            ),
            _SectionTitle('5. Direitos do Usuário'),
            _BodyText(
              'Em conformidade com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018), você tem direito a:\n\n'
              '• Acessar seus dados pessoais\n'
              '• Corrigir dados incompletos ou desatualizados\n'
              '• Solicitar a exclusão dos seus dados\n'
              '• Revogar o consentimento a qualquer momento\n\n'
              'Para exercer esses direitos, utilize a opção "Excluir conta" disponível no seu perfil.',
            ),
            _SectionTitle('6. Finalidade Educativa'),
            _BodyText(
              'O SIATRAB foi desenvolvido exclusivamente para fins acadêmicos e educativos. '
              'Os cálculos apresentados são baseados na legislação trabalhista brasileira vigente (CLT), '
              'mas não substituem a orientação de um profissional especializado em Direito do Trabalho.',
            ),
            _SectionTitle('7. Contato'),
            _BodyText(
              'Em caso de dúvidas sobre esta política, entre em contato pelo e-mail institucional do projeto.',
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
