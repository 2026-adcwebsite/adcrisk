import 'package:flutter/services.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './services/supabase_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobile keyboard overlap fix for Flutter Web
  _applyMobileKeyboardFix();

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp());
  });
}

/// Injects keyboard overlap fix for mobile browsers (iOS/Android)
/// This runs JavaScript directly from Dart to avoid index.html being reset by Rocket.new
void _applyMobileKeyboardFix() {
  try {
    js.context.callMethod('eval', [
      '''
      (function() {
        if (!window.visualViewport) return;
        window.visualViewport.addEventListener('resize', function() {
          var height = window.visualViewport.height;
          document.body.style.height = height + 'px';
          window.dispatchEvent(new Event('resize'));
        });
        window.visualViewport.addEventListener('scroll', function() {
          window.dispatchEvent(new Event('resize'));
        });
        // Set dynamic viewport height
        document.body.style.height = window.visualViewport.height + 'px';
        
        // Add meta viewport if missing
        if (!document.querySelector('meta[name="viewport"]')) {
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, interactive-widget=resizes-content';
          document.head.appendChild(meta);
        } else {
          document.querySelector('meta[name="viewport"]').content = 
            'width=device-width, initial-scale=1.0, interactive-widget=resizes-content';
        }
      })();
      '''
    ]);
  } catch (e) {
    // Silently fail on non-web platforms
    debugPrint('Keyboard fix skipped (non-web platform): $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'adcrisk',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }
}
