import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _primaryColor = Color(0xFF192E6A);
  static const _cardRadius = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final userName =
        authState.userName ??
        authState.userEmail?.split('@').first ??
        'Usuário';

    final mainItems = [
      _MenuItem(
        'Calcule: rescisão completa!',
        Icons.extension_rounded,
        '/calculator',
      ),
      _MenuItem('Chatbot educativo', Icons.menu_book_rounded, '/chat'),
    ];

    final quickItems = [
      _MenuItem('INSS', Icons.calendar_today_rounded, '/calculator'),
      _MenuItem('FGTS', Icons.assignment_rounded, '/calculator'),
      _MenuItem('Férias', Icons.event_available_rounded, '/calculator'),
      _MenuItem('Meus cálculos', Icons.description_rounded, '/history'),
    ];

    return Scaffold(
      backgroundColor: Colors.white, // 👈 fundo geral branco
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, userName),
              _buildMainSection(context, mainItems),
              _buildQuickAccess(context, quickItems),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Olá, $userName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSection(BuildContext context, List<_MenuItem> items) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD0D3DC), // 👈 só essa seção é cinza
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          const Text(
            'Confira seus cálculos e tire suas dúvidas!',
            style: TextStyle(color: Colors.black45, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Divider(
            indent: 50,
            endIndent: 50,
            thickness: 0.6,
            color: Colors.black26,
          ),
          const SizedBox(height: 14),
          Row(
            children: items.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildMenuCard(context, item),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context, List<_MenuItem> items) {
    return Container(
      color: Colors.white, // 👈 acesso rápido é branco
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          const Text(
            'Acesso rápido',
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Divider(
            indent: 70,
            endIndent: 70,
            thickness: 0.6,
            color: Colors.black26,
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMenuCard(context, items[0])),
                  const SizedBox(width: 14),
                  Expanded(child: _buildMenuCard(context, items[1])),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildMenuCard(context, items[2])),
                  const SizedBox(width: 14),
                  Expanded(child: _buildMenuCard(context, items[3])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(_cardRadius),
      onTap: () => context.push(item.route),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 22, color: _primaryColor),
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
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
        currentIndex: 0,
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

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;

  const _MenuItem(this.title, this.icon, this.route);
}
