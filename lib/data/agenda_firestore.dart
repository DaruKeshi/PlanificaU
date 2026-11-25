import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../models/materia.dart';
import '../models/tarea.dart';

/// Agenda y notas persistidas en Firestore, aisladas por usuario.
///
/// Estructura:
///   usuarios/{uid}                    -> { nombre: String }
///   usuarios/{uid}/tareas/{id}        -> campos de [Tarea]
///   usuarios/{uid}/materias/{id}      -> campos de [Materia] (con sus cortes)
class AgendaFirestore extends ChangeNotifier {
  AgendaFirestore({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_alCambiarAuth, onError: _fallo);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tareasSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _materiasSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _perfilSub;
  Timer? _nombreTimer;

  List<Tarea> _tareas = [];
  List<Materia> _materias = [];
  String? _uid;
  String _nombre = '';
  bool _cargando = true;
  String? _error;

  List<Tarea> get tareas => List.unmodifiable(_tareas);
  List<Materia> get materias => List.unmodifiable(_materias);
  String get nombreEstudiante => _nombre;
  bool get cargando => _cargando;
  String? get error => _error;

  CollectionReference<Map<String, dynamic>> get _tareasRef =>
      _firestore.collection('usuarios').doc(_uid).collection('tareas');

  CollectionReference<Map<String, dynamic>> get _materiasRef =>
      _firestore.collection('usuarios').doc(_uid).collection('materias');

  DocumentReference<Map<String, dynamic>> get _perfilRef =>
      _firestore.collection('usuarios').doc(_uid);

  void _alCambiarAuth(User? usuario) {
    _tareasSub?.cancel();
    _materiasSub?.cancel();
    _perfilSub?.cancel();
    _nombreTimer?.cancel();

    // Si el usuario escribió su nombre justo antes de salir, no lo perdemos.
    final uidAnterior = _uid;
    if (uidAnterior != null && _nombre.isNotEmpty) {
      unawaited(_escribirNombre(uidAnterior, _nombre.trim()));
    }

    _tareas = [];
    _materias = [];
    _uid = usuario?.uid;
    _nombre = '';

    if (usuario == null) {
      _cargando = false;
      _error = null;
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    _tareasSub = _tareasRef.orderBy('fechaEntrega').snapshots().listen(
      (snapshot) {
        _tareas = snapshot.docs.map(Tarea.desdeFirestore).toList();
        _cargando = false;
        _error = null;
        notifyListeners();
      },
      onError: _fallo,
    );

    _materiasSub = _materiasRef.orderBy('nombre').snapshots().listen(
      (snapshot) {
        _materias = snapshot.docs.map(Materia.desdeFirestore).toList();
        _cargando = false;
        _error = null;
        notifyListeners();
      },
      onError: _fallo,
    );

    _perfilSub = _perfilRef.snapshots().listen(
      (snapshot) {
        final nombre = snapshot.data()?['nombre'] as String?;
        if (nombre != null && _nombre.isEmpty) {
          _nombre = nombre;
          notifyListeners();
        }
      },
      onError: _fallo,
    );
  }

  void _fallo(Object error) {
    _cargando = false;
    _error = error is FirebaseException
        ? 'Firestore (${error.code}). Revisa que la base esté activada y sus reglas.'
        : 'No se pudo sincronizar con Firebase.';
    notifyListeners();
  }

  Future<void> _operar(Future<void> Function() escritura) async {
    await escritura().timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException('Firestore no respondió'),
    );
  }

  // ---------------------------------------------------------------- Tareas

  Future<void> agregar(Tarea tarea) async {
    final uid = _uid;
    if (uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(
      () => _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('tareas')
          .doc(tarea.id)
          .set(tarea.paraFirestore()),
    );
  }

  Future<void> actualizarTarea(Tarea tarea) async {
    if (_uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(() => _tareasRef.doc(tarea.id).update(tarea.paraActualizacion()));
  }

  Future<void> eliminarTarea(String id) async {
    if (_uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(() => _tareasRef.doc(id).delete());
  }

  Future<void> marcarCompletada(String id, bool value) async {
    if (_uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(() => _tareasRef.doc(id).update({'completada': value}));
  }

  // -------------------------------------------------------------- Materias

  Future<void> agregarMateria(Materia materia) async {
    final uid = _uid;
    if (uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(
      () => _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('materias')
          .doc(materia.id)
          .set(materia.paraFirestore()),
    );
  }

  Future<void> actualizarMateria(Materia materia) async {
    if (_uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(
      () => _materiasRef.doc(materia.id).set(materia.paraFirestore(), SetOptions(merge: true)),
    );
  }

  Future<void> eliminarMateria(String id) async {
    if (_uid == null) throw StateError('No hay usuario autenticado.');
    await _operar(() => _materiasRef.doc(id).delete());
  }

  // ---------------------------------------------------------------- Perfil

  /// Actualiza la vista de inmediato y agrupa varias pulsaciones en una escritura.
  void actualizarNombre(String nombre) {
    if (nombre == _nombre) return;
    _nombre = nombre;
    notifyListeners();

    final uid = _uid;
    if (uid == null) return;
    _nombreTimer?.cancel();
    _nombreTimer = Timer(
      const Duration(milliseconds: 600),
      () => unawaited(_escribirNombre(uid, nombre.trim())),
    );
  }

  Future<void> _escribirNombre(String uid, String nombre) async {
    try {
      await _firestore.collection('usuarios').doc(uid).set(
            {'nombre': nombre},
            SetOptions(merge: true),
          );
    } catch (_) {
      // El nombre se vuelve a intentar en el próximo cambio.
    }
  }

  /// Vuelve a abrir los streams después de un error de red o de reglas.
  void reintentar() => _alCambiarAuth(_auth.currentUser);

  /// Mensaje listo para mostrar en SnackBars.
  static String mensaje(Object error) => error is FirebaseException
      ? switch (error.code) {
          'permission-denied' => 'Firestore rechazó la escritura. Revisa las reglas.',
          'unavailable' => 'Sin conexión con Firestore. Intenta de nuevo.',
          'failed-precondition' => 'Activa Cloud Firestore en la consola de Firebase.',
          _ => 'Error de Firestore (${error.code}).',
        }
      : error is TimeoutException
          ? 'Firestore no responde. Activa la base y revisa tu conexión.'
          : 'No se pudo guardar. Intenta de nuevo.';

  @override
  void dispose() {
    _authSub?.cancel();
    _tareasSub?.cancel();
    _materiasSub?.cancel();
    _perfilSub?.cancel();
    _nombreTimer?.cancel();
    super.dispose();
  }
}

/// Expone [AgendaFirestore] a las pantallas sin paquetes extra.
class AgendaScope extends InheritedNotifier<AgendaFirestore> {
  const AgendaScope({
    super.key,
    required AgendaFirestore agenda,
    required super.child,
  }) : super(notifier: agenda);

  static AgendaFirestore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AgendaScope>();
    assert(scope != null, 'AgendaScope no encontrado');
    return scope!.notifier!;
  }
}
