import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:fashion_studio/screens/login_screen.dart';
import 'package:fashion_studio/screens/signup_screen.dart';
import 'package:fashion_studio/screens/app_layout.dart';
import 'package:fashion_studio/services/api_client.dart';
import 'package:fashion_studio/services/auth_service.dart';
import 'package:fashion_studio/services/data_service.dart';
import 'package:fashion_studio/services/token_storage.dart';

void main() {
  runApp(const MyApp());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  int _progress = 0;
  Timer? _timer;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeOut;

  late final AnimationController _bgController;
  late final Animation<double> _rotateSlow;
  late final Animation<double> _rotateFast;

  late final AnimationController _iconController;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotate;

  late final AnimationController _lettersController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeOut =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    _rotateSlow =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_bgController);
    _rotateFast = Tween<double>(begin: 0, end: -2 * math.pi).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.linear),
    );

    _iconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _iconScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _lettersController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _iconController.forward();
    _lettersController.forward();

    _timer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + 2).clamp(0, 100);
      });
      if (_progress >= 100) {
        t.cancel();
      }
    });

    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      await _fadeController.forward();
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _bgController.dispose();
    _iconController.dispose();
    _lettersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _fadeOut,
      builder: (context, child) {
        final opacity = 1.0 - _fadeOut.value;
        final scale = 1.0 + 0.1 * _fadeOut.value;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background shapes
            Positioned(
              top: -160,
              left: -160,
              child: _GradientBlob(
                size: 320,
                colors: const [Color(0x1AEF4444), Color(0x0DFC87F7)],
                rotation: math.pi / 4,
              ),
            ),
            Positioned(
              bottom: -180,
              right: -180,
              child: _GradientBlob(
                size: 380,
                colors: const [Color(0x1ADC2626), Color(0x0FF87171)],
                rotation: -math.pi / 4,
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _rotateSlow.value,
                        child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x1ADC2626)),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: _rotateFast.value * (15 / 20),
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x1AEF4444)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _iconController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _iconScale.value,
                            child: Transform.rotate(
                              angle: _iconRotate.value,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFDC2626),
                                      Color(0xFFEF4444)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDC2626)
                                          .withOpacity(0.25),
                                      blurRadius: 30,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.content_cut,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      _BrandName(lettersController: _lettersController),
                      const SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: _lettersController,
                        builder: (context, _) {
                          final t = CurvedAnimation(
                              parent: _lettersController,
                              curve: const Interval(0.75, 1,
                                  curve: Curves.easeOut));
                          return Opacity(
                            opacity: t.value,
                            child: Text(
                              'PREMIUM MANAGEMENT',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                    letterSpacing: 4.8,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 42),
                      SizedBox(
                        width: 260,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: 6,
                                color: Colors.grey.shade100,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 260 * (_progress / 100),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFDC2626),
                                          Color(0xFFEF4444),
                                          Color(0xFFF87171)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_progress%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom subtle overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x33FEE2E2), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandName extends StatelessWidget {
  const _BrandName({required this.lettersController});

  final AnimationController lettersController;

  @override
  Widget build(BuildContext context) {
    final fashion = 'Fashion'.split('');
    final studio = 'Studio'.split('');

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 1,
      children: [
        ...List.generate(fashion.length, (i) {
          return _AnimatedLetter(
            controller: lettersController,
            letter: fashion[i],
            delay: 0.28 + i * 0.04,
          );
        }),
        const SizedBox(width: 10),
        ...List.generate(studio.length, (i) {
          return _AnimatedLetter(
            controller: lettersController,
            letter: studio[i],
            delay: 0.56 + i * 0.04,
          );
        }),
      ],
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter(
      {required this.controller, required this.letter, required this.delay});

  final AnimationController controller;
  final String letter;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve:
          Interval(delay, (delay + 0.2).clamp(0.0, 1.0), curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final opacity = anim.value;
        final dy = 20 * (1 - anim.value);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                letter,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob(
      {required this.size, required this.colors, required this.rotation});

  final double size;
  final List<Color> colors;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(64),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Studio',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFDC2626),
          onPrimary: Color(0xFFFFFFFF),
          secondary: Color(0xFFFEE2E2),
          onSecondary: Color(0xFF991B1B),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1A1A1A),
          error: Color(0xFFB91C1C),
          onError: Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEF4444),
          onPrimary: Color(0xFF0B0B0B),
          secondary: Color(0xFF262626),
          onSecondary: Color(0xFFFFFFFF),
          surface: Color(0xFF171717),
          onSurface: Color(0xFFFFFFFF),
          error: Color(0xFFB91C1C),
          onError: Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routes: {
        '/login': (context) {
          const baseUrl = String.fromEnvironment('API_BASE_URL',
              defaultValue: 'http://localhost:8080');
          final tokenStorage = TokenStorage();
          final apiClient =
              ApiClient(baseUrl: baseUrl, tokenStorage: tokenStorage);
          final authService =
              AuthService(apiClient: apiClient, tokenStorage: tokenStorage);
          return LoginScreen(
            authService: authService,
            onLoginSuccess: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/app', (r) => false),
          );
        },
        '/signup': (context) {
          const baseUrl = String.fromEnvironment('API_BASE_URL',
              defaultValue: 'http://localhost:8080');
          final tokenStorage = TokenStorage();
          final apiClient =
              ApiClient(baseUrl: baseUrl, tokenStorage: tokenStorage);
          final authService =
              AuthService(apiClient: apiClient, tokenStorage: tokenStorage);
          return SignupScreen(
            authService: authService,
            onSignupSuccess: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/app', (r) => false),
          );
        },
        '/app': (context) {
          const baseUrl = String.fromEnvironment('API_BASE_URL',
              defaultValue: 'http://localhost:8080');
          final tokenStorage = TokenStorage();
          final apiClient =
              ApiClient(baseUrl: baseUrl, tokenStorage: tokenStorage);
          final authService =
              AuthService(apiClient: apiClient, tokenStorage: tokenStorage);
          final dataService = DataService(apiClient: apiClient);
          return AppLayout(
            apiClient: apiClient,
            authService: authService,
            dataService: dataService,
          );
        },
      },
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  Future<void> _onComplete() async {
    if (!mounted) return;
    final token = await TokenStorage().getToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      (token != null && token.isNotEmpty) ? '/app' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onComplete: _onComplete);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
