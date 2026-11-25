import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../widgets/curvas.dart';
import '../widgets/marca_planificau.dart';

/// Ingreso con correo y contraseña, con identidad visual propia.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _cargando = false;
  bool _verContrasena = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _correo.text.trim(),
        password: _contrasena.text,
      );
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mensajeError(e.code));
    } catch (_) {
      setState(() => _error = 'No se pudo iniciar sesión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String codigo) => switch (codigo) {
        'invalid-email' => 'Escribe un correo electrónico válido.',
        'user-not-found' => 'No existe una cuenta con ese correo.',
        'wrong-password' || 'invalid-credential' =>
          'Correo o contraseña incorrectos.',
        'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
        'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
        'too-many-requests' => 'Demasiados intentos. Espera un momento.',
        'network-request-failed' => 'Sin conexión. Revisa tu internet.',
        _ => 'Error de autenticación: $codigo',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: PlanificaUTheme.fondo),
          ),
          Positioned(
            top: -70,
            right: -60,
            child: CustomPaint(
              size: const Size(320, 300),
              painter: BlobCurvoPainter(
                color: PlanificaUTheme.acentoSuave,
                invertido: false,
                gradiente: const LinearGradient(
                  colors: [
                    PlanificaUTheme.acentoSuave,
                    Color(0xFFFDF5F1),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: CustomPaint(
              size: const Size(340, 320),
              painter: BlobCurvoPainter(
                color: PlanificaUTheme.primarioSuave,
                invertido: true,
                gradiente: const LinearGradient(
                  colors: [
                    PlanificaUTheme.primarioSuave,
                    PlanificaUTheme.fondo,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              children: [
                const MarcaPlanificau(tamano: 82),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: PlanificaUTheme.papel,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: PlanificaUTheme.borde),
                    boxShadow: [
                      BoxShadow(
                        color: PlanificaUTheme.tinta.withValues(alpha: 0.07),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bienvenido de nuevo',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ingresa con tu correo para seguir con tus entregas.',
                          style: TextStyle(
                            color: PlanificaUTheme.tinta,
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final texto = value?.trim() ?? '';
                            if (texto.isEmpty) return 'Ingresa tu correo.';
                            if (!texto.contains('@') || !texto.contains('.')) {
                              return 'Correo no válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contrasena,
                          obscureText: !_verContrasena,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verContrasena
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                              onPressed: () => setState(
                                () => _verContrasena = !_verContrasena,
                              ),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Ingresa tu contraseña.'
                              : null,
                          onFieldSubmitted: (_) => _ingresar(),
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: PlanificaUTheme.prioridadAlta,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: _cargando ? null : _ingresar,
                          icon: _cargando
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            _cargando ? 'Ingresando...' : 'Ingresar',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Rutas.registroUsuario,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: '¿No tienes cuenta? ',
                      style: TextStyle(color: PlanificaUTheme.tintaSuave),
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: PlanificaUTheme.acento,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
