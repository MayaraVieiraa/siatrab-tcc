import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsividade controlada
    final screenWidth = MediaQuery.of(context).size.width.clamp(300.0, 600.0);
    final responsiveFontSize = screenWidth * 0.045;

    return Scaffold(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),
                  Text(
                    'SIATRAB',
                    style: TextStyle(
                      fontSize: (responsiveFontSize * 2.2).clamp(24.0, 40.0),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sistema de Apoio ao\ntrabalhador para cálculos e\ndúvidas trabalhistas!',
                    style: TextStyle(
                      fontSize: (responsiveFontSize * 0.9).clamp(12.0, 16.0),
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
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
