import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../screens/consulta_resultados_screen.dart';
import '../screens/inicio_screen.dart';
import '../screens/notas_screen.dart';
import '../widgets/curvas.dart';
import 'rutas.dart';

/// Estructura principal: pestañas inferiores + botón flotante contextual.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indice = 0;

  late final List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
    _paginas = [
      InicioScreen(
        onIrAAgenda: () => setState(() => _indice = 1),
        onIrANotas: () => setState(() => _indice = 2),
      ),
      const ConsultaResultadosScreen(),
      const NotasScreen(),
    ];
  }

  void _crear() {
    Navigator.pushNamed(
      context,
      _indice == 2 ? Rutas.registroMateria : Rutas.registro,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esNotas = _indice == 2;

    return Scaffold(
      body: IndexedStack(index: _indice, children: _paginas),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: PlanificaUTheme.acento,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: _crear,
        child: Icon(
          esNotas ? Icons.school_outlined : Icons.add_rounded,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: PlanificaUTheme.papel,
        surfaceTintColor: Colors.transparent,
        shape: const BezierNotch(),
        notchMargin: 10,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              Expanded(
                child: _item(0, Icons.grid_view_rounded, 'Inicio'),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: _item(1, Icons.calendar_month_rounded, 'Agenda'),
              ),
              Expanded(
                child: _item(2, Icons.school_outlined, 'Notas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int indice, IconData icono, String etiqueta) {
    final activo = _indice == indice;
    final color = activo ? PlanificaUTheme.primario : PlanificaUTheme.tintaSuave;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _indice = indice),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
