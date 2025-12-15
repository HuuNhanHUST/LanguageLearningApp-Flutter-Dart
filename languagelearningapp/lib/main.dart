import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/man_hinh_chinh.dart';
import 'features/home/screens/profile_edit_screen.dart';
import 'features/words/providers/word_provider.dart';
import 'features/words/screens/vocabulary_list_screen.dart';
import 'screens/audio_recorder_screen.dart';
import 'screens/text_scan_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => WordProvider(),
        ),
      ],
      child: provider.Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return StreamBuilder<AuthStatus>(
            stream: authProvider.authStatusStream,
            initialData: authProvider.currentStatus,
            builder: (context, snapshot) {
              final authStatus = snapshot.data ?? authProvider.currentStatus;

              return MaterialApp.router(
                title: 'Language Learning App',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                  ),
                  useMaterial3: true,
                  // Smooth page transitions
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: ZoomPageTransitionsBuilder(),
                      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    },
                  ),
                ),
                routerConfig: _createRouter(authStatus),
              );
            },
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthStatus authStatus) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isAuthRoute = location == '/login' || location == '/register';
        final isSplash = location == '/splash';

        // Show splash only during initial loading
        if (authStatus.state == AuthState.initial ||
            authStatus.state == AuthState.loading) {
          return isSplash ? null : '/splash';
        }

        // User is not authenticated - redirect to login
        if (!authStatus.isAuthenticated) {
          return isAuthRoute ? null : '/login';
        }

        // User is authenticated - redirect away from auth routes and splash
        if (authStatus.isAuthenticated &&
            (isSplash || isAuthRoute || location == '/')) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(path: '/', redirect: (context, state) => '/home'),
        GoRoute(
          path: '/home',
          builder: (context, state) => const ManHinhChinh(),
        ),
        GoRoute(
          path: '/old-home',
          builder: (context, state) =>
              const MyHomePage(title: 'Language Learning Home'),
        ),
        GoRoute(
          path: '/details',
          builder: (context, state) => const DetailsPage(),
        ),
        GoRoute(
          path: '/audio-recorder',
          builder: (context, state) => const AudioRecorderScreen(),
        ),
        GoRoute(
          path: '/text-scan',
          builder: (context, state) => const TextScanScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: '/vocabulary',
          builder: (context, state) => const VocabularyListScreen(),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${user.fullName}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '@${user.username}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Level',
                            user.level.toString(),
                            Icons.star,
                          ),
                          _buildStatItem('XP', user.xp.toString(), Icons.bolt),
                          _buildStatItem(
                            'Streak',
                            '${user.streak} days',
                            Icons.local_fire_department,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/details');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Details'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/audio-recorder');
              },
              icon: const Icon(Icons.mic),
              label: const Text('Audio Recorder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is the details page'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
