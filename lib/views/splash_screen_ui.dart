import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/run_widgets.dart';
import 'show_all_run_ui.dart';

// หน้าแรก: โลโก้ RUN TRACKER 3 วินาที แล้วไปหน้าแสดงข้อมูลทั้งหมด
class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShowAllRunUi()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final footerStyle = GoogleFonts.prompt(
      fontSize: 14,
      color: Colors.grey[700],
    );

    return Scaffold(
      backgroundColor: AppStyle.navy,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppStyle.logo, width: 200, height: 200),
                Text(
                  'RUN TRACKER',
                  style: GoogleFonts.prompt(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                CircularProgressIndicator(color: Colors.indigoAccent[100]),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('© 2026 RUN TRACKER', style: footerStyle),
                  Text('Created by NinniN SAU TEAM', style: footerStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
