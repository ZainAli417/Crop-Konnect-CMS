import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // ← Add this
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Constant/Forget Password Provider.dart';
import 'Screens/Job_Seeker/Signup_Provider.dart';
import 'Screens/Job_Seeker/login_provider.dart';
import 'Top_Nav_Provider.dart';
import 'Web_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ─── Remove the “#/” from web URLs ───
  setUrlStrategy(PathUrlStrategy());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Precache a dummy inter text so it’s ready immediately
    TextPainter(
      text: TextSpan(text: " ", style: GoogleFonts.inter()),
      textDirection: TextDirection.ltr,
    ).layout();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => TopNavProvider()),
      ],
      child: const JobPortalApp(),
    ),
  );
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Crop Konnect‑Farm CMS',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        // 1. Pale off‑white background everywhere
        scaffoldBackgroundColor: const Color(0xFFF9F6F1),

        // 2. Forest‑green primary
        primaryColor: const Color(0xFF4C6B3C),

        // 4. Keep inter (or swap to Inter if you prefer)
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),

        // 5. Inputs & buttons will pick up from the new colourScheme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          buttonColor: const Color(0xFF4C6B3C),
          hoverColor: const Color(0xFF5A691A),
          textTheme: ButtonTextTheme.primary,
        ), colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF4C6B3C),
          onPrimary: Colors.white,
          secondary: const Color(0xFF5A691A),   // your earthy accent
          onSecondary: Colors.white,
          background: const Color(0xFFF9F6F1),
          onBackground: const Color(0xFF333333),
          surface: Colors.white,
          onSurface: const Color(0xFF333333),
          error: Colors.red,
          onError: Colors.white,
        ).copyWith(background: const Color(0xFFF9F6F1)),
      ),
    );
  }
}
