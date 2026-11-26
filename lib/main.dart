import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/supabase_config.dart';
import 'views/splash_screen_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // เชื่อมต่อ Supabase ก่อนเปิดแอป
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const FlutterRunTrackerApp());
}

class FlutterRunTrackerApp extends StatelessWidget {
  const FlutterRunTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ฟอนต์หลักของแอป: Prompt (ตามที่ใช้ใน Figma)
        textTheme: GoogleFonts.promptTextTheme(),
        // ระยะห่างแบบกระชับตาม Figma (ช่องกรอกสูง 48)
        visualDensity: VisualDensity.compact,
      ),
      // หน้าแรกของแอป
      home: const SplashScreenUi(),
    );
  }
}
