# PlanificaU

Gestor académico para estudiantes: organiza entregas y lleva el acumulado de
notas por materia. Persistencia real en **Cloud Firestore** con autenticación
de **Firebase Auth** (correo y contraseña).

## Pantallas

1. **Inicio**: bienvenida, nombre editable, resumen de carga y accesos rápidos.
2. **Agenda**: listado de tareas con filtro visual por plazo y prioridad.
3. **Notas**: resumen de materias aprobadas/en curso y acumulado por corte.
4. **Registro**: formularios de tarea y de materia (nueva pestaña).
5. **Detalle**: información completa de la tarea o materia seleccionada.
6. **Edición**: modificación de tareas, materias, notas y ponderaciones.

La eliminación siempre pide confirmación antes de borrar en Firestore.

## Estructura de datos

```text
usuarios/{uid}                      -> { nombre }
usuarios/{uid}/tareas/{id}          -> titulo, materia, descripcion,
                                       fechaEntrega, prioridad, completada,
                                       creadoEn
usuarios/{uid}/materias/{id}        -> nombre, escalaMaxima, notaAprobacion,
                                       cortes[{id, numero, nombre, nota, peso}],
                                       promedio, acumulado, cortesEvaluados,
                                       aprobada, actualizadoEn
```

- Escala configurable (por defecto 0–5.0) y nota mínima de aprobación editable.
- De 2 a 10 cortes por materia (por defecto 3), cada uno con su peso.
- `promedio` es ponderado solo por los cortes que ya tienen nota;
  `acumulado` es la suma de `nota × peso`. Una materia se marca **aprobada**
  cuando todos sus cortes están evaluados y el promedio alcanza la mínima.

## Seguridad

`firestore.rules` permite leer/escribir únicamente los documentos cuya ruta
empiece por `usuarios/{uid}` y cuyo `uid` sea el del usuario autenticado. Un
usuario sin sesión recibe `permission-denied`.

Si tienes Firebase CLI, publica las reglas con:

```powershell
firebase deploy --only firestore:rules
```

También puedes pegar el contenido de `firestore.rules` en
*Firebase Console → Firestore Database → Reglas* y publicar.

## Comandos

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

Para usar la aplicación, crea tu propia cuenta desde la pantalla de registro
con un correo electrónico y una contraseña.

Verificación final registrada: `flutter analyze` sin issues, `flutter test`
7/7 y `flutter build apk --debug` correcto.
