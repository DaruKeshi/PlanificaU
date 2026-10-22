import 'package:flutter_test/flutter_test.dart';
import 'package:planificau/app/planificau_app.dart';
import 'package:planificau/data/agenda_memoria.dart';

void main() {
  testWidgets('Muestra la pantalla principal de PlanificaU', (tester) async {
    await tester.pumpWidget(PlanificaUApp(agenda: AgendaMemoria()));

    expect(find.text('PlanificaU'), findsWidgets);
    expect(find.text('Registrar tarea'), findsOneWidget);
    expect(find.text('Ver agenda y resultados'), findsOneWidget);
  });
}
