import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

import 'features/auth/view/login_page.dart';
import 'features/auth/view/register_page.dart';
import 'features/auth/view/splash_page.dart';
import 'features/auth/view/forgot_password_page.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/home/view/home_page.dart';
import 'features/calculator/view/calculator_page.dart';
import 'features/calculator/view/calculator_result_page.dart';
import 'features/chat/view/chat_page.dart';
import 'features/profile/view/profile_page.dart';
import 'features/profile/view/privacy_policy_page.dart';
import 'features/profile/view/terms_of_use_page.dart';
import 'features/history/view/history_page.dart';
import 'features/history/view/history_detail_page.dart';
import 'features/profile/view/about_page.dart';
import 'features/calculator/view/inss_page.dart';
import 'features/calculator/view/fgts_page.dart';
import 'features/calculator/view/ferias_page.dart';

const _publicRoutes = [
  '/splash',
  '/login',
  '/register',
  '/forgot-password',
  '/terms-of-use',
  '/privacy-policy',
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SIATRABApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = ref.read(authViewModelProvider).isAuthenticated;
      final path = state.uri.path;
      final isPublic = _publicRoutes.contains(path);

      if (!isAuthenticated && !isPublic) return '/login';
      if (isAuthenticated &&
          (path == '/login' || path == '/register' || path == '/splash')) {
        return '/home';
      }
      return null;
    },
    routes: [
      // Rotas públicas
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/terms-of-use',
        name: 'terms-of-use',
        builder: (context, state) => const TermsOfUsePage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),

      // Rotas principais (autenticadas)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // History com rota aninhada
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'history-detail',
            builder: (context, state) {
              final extra = state.extra;

              // Verificação segura do tipo
              if (extra is Map<String, dynamic>) {
                if (extra.containsKey('data') &&
                    extra['data'] is Map<String, dynamic>) {
                  return HistoryDetailPage(
                    data: extra['data'] as Map<String, dynamic>,
                    docId: extra['docId'] as String?,
                  );
                }
                return HistoryDetailPage(
                  data: extra,
                  docId: extra['docId'] as String?,
                );
              }

              // Fallback seguro
              return const Scaffold(
                body: Center(
                  child: Text('Erro ao carregar dados do histórico'),
                ),
              );
            },
          ),
        ],
      ),

      // Calculator com rota aninhada
      GoRoute(
        path: '/calculator',
        name: 'calculator',
        builder: (context, state) => const CalculatorPage(),
        routes: [
          GoRoute(
            path: 'result',
            name: 'calculator-result',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is Map<String, dynamic>) {
                return CalculatorResultPage(data: extra);
              }
              return const Scaffold(
                body: Center(
                  child: Text('Erro ao carregar resultado do cálculo'),
                ),
              );
            },
          ),
        ],
      ),

      // Rotas de ferramentas
      GoRoute(
        path: '/inss',
        name: 'inss',
        builder: (context, state) => const InssPage(),
      ),
      GoRoute(
        path: '/fgts',
        name: 'fgts',
        builder: (context, state) => const FgtsPage(),
      ),
      GoRoute(
        path: '/ferias',
        name: 'ferias',
        builder: (context, state) => const FeriasPage(),
      ),

      // Chat e Perfil
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),

      // Redirecionamento padrão
      GoRoute(path: '/', redirect: (context, state) => '/home'),
    ],
  );
});

class SIATRABApp extends ConsumerWidget {
  const SIATRABApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SIATRAB - Cálculos Trabalhistas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF101D42)),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
