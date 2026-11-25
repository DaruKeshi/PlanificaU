import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/curvas.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/marca_planificau.dart';

/// Registro de cuenta con correo y contraseña.
class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      setState(() => _error = 'No se pudo crear la cuenta. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String codigo) => switch (codigo) {
        'invalid-email' => 'Escribe un correo electrónico válido.',
        'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
        'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
        'network-request-failed' => 'Sin conexión. Revisa tu internet.',
        _ => 'Error de registro: $codigo',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Crear cuenta', mostrarAtras: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        children: [
          // Figura rellena con Bézier detrás del logo; el texto va debajo.
          Center(
            child: SizedBox(
              width: 250,
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(250, 210),
                    painter: const BlobCurvoPainter(
                      color: PlanificaUTheme.acentoSuave,
                      invertido: false,
                    ),
                  ),
                  const MarcaPlanificau(tamano: 86),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Empieza con calma.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Tu agenda académica, en un solo lugar.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
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
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
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
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña (mínimo 6 caracteres)',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'Debe tener al menos 6 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmacion,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (value) => value != _contrasena.text
                        ? 'Las contraseñas no coinciden.'
                        : null,
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
                    onPressed: _cargando ? null : _registrar,
                    icon: _cargando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(_cargando ? 'Creando cuenta...' : 'Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ya tengo cuenta, volver al ingreso'),
          ),
        ],
      ),
    );
  }
}
