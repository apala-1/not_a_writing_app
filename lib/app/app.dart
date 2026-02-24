import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/login_screen.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_navigation_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/create_from_posts_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/dashboard_screen.dart';
import 'package:not_a_writing_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:not_a_writing_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:not_a_writing_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:not_a_writing_app/theme/theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not A Writing App',
      theme: getApplicationTheme(),
      initialRoute: '/splash', // Start with splash or handle deep link
      // Use onGenerateRoute to handle dynamic routes with query parameters
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.path == '/reset-password') {
        final tokenFromQuery = uri.queryParameters['token'];
        final tokenFromArgs = settings.arguments as String?;
        final token = tokenFromQuery ?? tokenFromArgs ?? '';

        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );
      }


        // Static routes
        switch (uri.path) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashPage());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/bottom_navigation':
            return MaterialPageRoute(builder: (_) => const BottomNavigationScreen());
          case '/forgot_password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case '/edit-profile':
            return MaterialPageRoute(builder: (_) => const EditProfileScreen());
          case '/createFromPosts':
            return MaterialPageRoute(builder: (_) => const CreateFromPostsScreen());
          default:
            // Unknown route fallback
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}
