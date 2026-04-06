import 'package:fashion_studio/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen(
      {super.key, required this.authService, required this.onSignupSuccess});

  final AuthService authService;
  final VoidCallback onSignupSuccess;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _atelierController = TextEditingController(text: 'Fashion Studio');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _atelierController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    final result = await widget.authService.signup(
      _nomController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _atelierController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !')),
      );
      widget.onSignupSuccess();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(result.message ?? 'Impossible de créer le compte')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFEBEE),
              Color(0xFFFFF1F2),
              Color(0xFFFCE7F3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 18,
                  shadowColor: const Color(0xFFDC2626).withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: const Color(0xFFDC2626).withOpacity(0.10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                            ),
                          ),
                          child: const Icon(Icons.content_cut,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (rect) => const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                          ).createShader(rect),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'Créer un compte',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Commencez à gérer votre atelier de couture',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Nom complet',
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nomController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.9)),
                                  hintText: 'Votre nom',
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: const Color(0xFFDC2626)
                                            .withOpacity(0.10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.primary.withOpacity(0.5),
                                        width: 1.5),
                                  ),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Nom obligatoire';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Nom de l'atelier",
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _atelierController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.storefront_outlined,
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.9)),
                                  hintText: 'Fashion Studio',
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: const Color(0xFFDC2626)
                                            .withOpacity(0.10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.primary.withOpacity(0.5),
                                        width: 1.5),
                                  ),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty)
                                    return "Nom de l'atelier obligatoire";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Email',
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.mail_outline,
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.9)),
                                  hintText: 'votre@email.com',
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: const Color(0xFFDC2626)
                                            .withOpacity(0.10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.primary.withOpacity(0.5),
                                        width: 1.5),
                                  ),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Email obligatoire';
                                  final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                      .hasMatch(value);
                                  if (!ok) return 'Email invalide';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Mot de passe',
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.9)),
                                  hintText: '••••••••',
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: const Color(0xFFDC2626)
                                            .withOpacity(0.10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.primary.withOpacity(0.5),
                                        width: 1.5),
                                  ),
                                ),
                                validator: (v) {
                                  final value = (v ?? '');
                                  if (value.isEmpty)
                                    return 'Mot de passe obligatoire';
                                  if (value.length < 6)
                                    return 'Minimum 6 caractères';
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFDC2626),
                                        Color(0xFFEF4444)
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDC2626)
                                            .withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    child: Text(
                                      _isLoading
                                          ? 'Création...'
                                          : 'Créer mon compte',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Déjà un compte ? ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey.shade700),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushReplacementNamed('/login'),
                                    child: const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
