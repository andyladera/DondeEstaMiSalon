import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/map_models.dart' as map_models;
import '../data/floor_plan_data.dart';
import '../data/mock_schedule_data.dart';
import '../services/pathfinding_service.dart';

class MapScreen extends StatefulWidget {
  final String? startLocation;
  final String? destinationLabCode;

  const MapScreen({
    super.key,
    this.startLocation,
    this.destinationLabCode,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  final map_models.FloorPlan _floorPlan = FloorPlanData.thirdFloor;
  late final PathfindingService _pathfindingService;
  
  map_models.Route? _currentRoute;
  map_models.MapNode? _startNode;
  map_models.MapNode? _destinationNode;
  
  // Modo de prueba
  bool _isTestMode = false;
  String? _selectedTestLab;
  
  // Animación del recorrido
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _isAnimating = false;
  bool _animationCompleted = false;
  double _animationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pathfindingService = PathfindingService(_floorPlan);
    _initializeRoute();
    
    // Inicializar el AnimationController una sola vez
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    // Configurar zoom inicial para ver todo el mapa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialZoom();
    });
  }
  
  void _setInitialZoom() {
    final screenSize = MediaQuery.of(context).size;
    final scaleX = screenSize.width / _floorPlan.imageWidth;
    final scaleY = (screenSize.height * 0.5) / _floorPlan.imageHeight;
    final scale = (scaleX < scaleY ? scaleX : scaleY) * 0.9;
    
    final matrix = Matrix4.identity()
      ..translate(
        (screenSize.width - _floorPlan.imageWidth * scale) / 2,
        50.0,
      )
      ..scale(scale);
    
    _transformationController.value = matrix;
  }

  void _initializeRoute() {
    // Configurar nodo de destino si se proporcionó
    if (widget.destinationLabCode != null) {
      _destinationNode = FloorPlanData.getNodeByLabCode(widget.destinationLabCode!);
    }

    // Por ahora, usar entrada del bloque P como punto de inicio predeterminado
    _startNode = _floorPlan.findNodeById('starting_point');

    if (_startNode != null && _destinationNode != null) {
      _calculateRoute();
    }
  }

  void _calculateRoute() {
    if (_startNode == null || _destinationNode == null) return;

    setState(() {
      _currentRoute = _pathfindingService.findPath(_startNode!, _destinationNode!);
    });
  }

  void _startAnimation() {
    if (_currentRoute == null || _currentRoute!.nodes.isEmpty) return;

    // Actualizar duración basada en la ruta
    _animationController!.duration = Duration(
      seconds: (_currentRoute!.nodes.length * 2).clamp(5, 20),
    );

    setState(() {
      _isAnimating = true;
      _animationCompleted = false;
      _animationProgress = 0.0;
    });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _animationProgress = _animation!.value;
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
              _animationCompleted = true;
            });
          }
        }
      });

    _animationController!.forward(from: 0.0);
  }

  void _stopAnimation() {
    _animationController?.stop();
    if (mounted) {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  void _resetAnimation() {
    _animationController?.reset();
    if (mounted) {
      setState(() {
        _animationProgress = 0.0;
        _isAnimating = false;
        _animationCompleted = false;
      });
    }
    // Iniciar la animación automáticamente después de resetear
    _startAnimation();
  }

  void _centerRoute() {
    if (_currentRoute == null || _currentRoute!.nodes.isEmpty) return;
    
    // Calcular los límites de la ruta
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    
    for (final node in _currentRoute!.nodes) {
      if (node.x < minX) minX = node.x;
      if (node.x > maxX) maxX = node.x;
      if (node.y < minY) minY = node.y;
      if (node.y > maxY) maxY = node.y;
    }
    
    // Agregar margen
    const margin = 100.0;
    minX -= margin;
    maxX += margin;
    minY -= margin;
    maxY += margin;
    
    final routeWidth = maxX - minX;
    final routeHeight = maxY - minY;
    
    final screenSize = MediaQuery.of(context).size;
    final availableHeight = screenSize.height - 300; // Espacio para controles
    
    final scaleX = screenSize.width / routeWidth;
    final scaleY = availableHeight / routeHeight;
    final scale = (scaleX < scaleY ? scaleX : scaleY) * 0.9;
    
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    
    final matrix = Matrix4.identity()
      ..translate(
        screenSize.width / 2 - centerX * scale,
        availableHeight / 2 - centerY * scale + 100,
      )
      ..scale(scale);
    
    setState(() {
      _transformationController.value = matrix;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.destinationLabCode != null
              ? 'Ruta a ${widget.destinationLabCode}'
              : 'Mapa - Tercer Nivel',
        ),
        actions: [
          if (_currentRoute != null)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _centerRoute,
              tooltip: 'Centrar ruta',
            ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _showLocationPicker,
            tooltip: 'Cambiar ubicación',
          ),
          // Botón para activar modo de prueba
          IconButton(
            icon: Icon(_isTestMode ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () {
              setState(() {
                _isTestMode = !_isTestMode;
                if (!_isTestMode) {
                  _selectedTestLab = null;
                  _destinationNode = widget.destinationLabCode != null
                      ? FloorPlanData.getNodeByLabCode(widget.destinationLabCode!)
                      : null;
                  _calculateRoute();
                }
              });
            },
            tooltip: _isTestMode ? 'Desactivar modo prueba' : 'Activar modo prueba',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de modo de prueba
          if (_isTestMode) _buildTestModePanel(),
          
          // Panel de información
          if (_currentRoute != null) _buildInfoPanel(),
          
          // Mapa interactivo
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.3,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(200),
              constrained: false,
              child: Container(
                width: _floorPlan.imageWidth,
                height: _floorPlan.imageHeight,
                color: Colors.grey.shade100,
                child: CustomPaint(
                  size: Size(
                    _floorPlan.imageWidth,
                    _floorPlan.imageHeight,
                  ),
                  painter: MapPainter(
                    floorPlan: _floorPlan,
                    route: _currentRoute,
                    startNode: _startNode,
                    destinationNode: _destinationNode,
                    animationProgress: _animationProgress,
                    isAnimating: _isAnimating,
                  ),
                ),
              ),
            ),
          ),
          
          // Controles de animación
          if (_currentRoute != null) _buildAnimationControls(),
          
          // Instrucciones
          if (_currentRoute != null && !_isAnimating) _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distancia: ${_currentRoute!.totalDistance.toStringAsFixed(0)} metros',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tiempo estimado: ${_currentRoute!.estimatedTimeMinutes.toStringAsFixed(1)} minutos',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isAnimating && !_animationCompleted) ...[
            ElevatedButton.icon(
              onPressed: _startAnimation,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Recorrido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ] else if (_isAnimating) ...[
            ElevatedButton.icon(
              onPressed: _stopAnimation,
              icon: const Icon(Icons.pause),
              label: const Text('Pausar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _resetAnimation,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reiniciar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ] else if (_animationCompleted) ...[
            ElevatedButton.icon(
              onPressed: _resetAnimation,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Volver a Simular'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _currentRoute!.instructions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentRoute!.instructions[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selecciona tu ubicación actual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ..._floorPlan.nodes
                .where((node) =>
                    node.type == map_models.NodeType.laboratory ||
                    node.type == map_models.NodeType.entrance)
                .map((node) {
              return ListTile(
                leading: Icon(
                  node.type == map_models.NodeType.entrance
                      ? Icons.meeting_room
                      : Icons.room,
                  color: Colors.blue,
                ),
                title: Text(node.name),
                selected: _startNode == node,
                onTap: () {
                  setState(() {
                    _startNode = node;
                    _calculateRoute();
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildTestModePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Modo de Prueba Activado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Selecciona un laboratorio para ver su ubicación:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTestLab,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: const Text('Elige un laboratorio...'),
            items: MockScheduleData.getAllLabCodes().map((labCode) {
              final schedule = MockScheduleData.getScheduleForLab(labCode);
              return DropdownMenuItem<String>(
                value: labCode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (schedule != null)
                      Text(
                        schedule['curso'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTestLab = newValue;
                  _destinationNode = FloorPlanData.getNodeByLabCode(newValue);
                  _calculateRoute();
                  
                  // Auto-centrar la ruta después de un breve delay
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _centerRoute();
                  });
                });
              }
            },
          ),
          if (_selectedTestLab != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mostrando ruta a $_selectedTestLab',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Painter personalizado para dibujar el mapa
class MapPainter extends CustomPainter {
  final map_models.FloorPlan floorPlan;
  final map_models.Route? route;
  final map_models.MapNode? startNode;
  final map_models.MapNode? destinationNode;
  final double animationProgress;
  final bool isAnimating;

  MapPainter({
    required this.floorPlan,
    this.route,
    this.startNode,
    this.destinationNode,
    required this.animationProgress,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo gris claro
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey.shade100,
    );

    // Dibujar imagen del plano (simulada con rectángulos por ahora)
    _drawFloorPlanSimulation(canvas, size);

    // Dibujar ruta si existe
    if (route != null && route!.isNotEmpty) {
      _drawRoute(canvas);
    }

    // Dibujar nodos (laboratorios)
    _drawNodes(canvas);

    // Dibujar marcador animado
    if (isAnimating && route != null && route!.isNotEmpty) {
      _drawAnimatedMarker(canvas);
    }
  }

  void _drawFloorPlanSimulation(Canvas canvas, Size size) {
    // Simular el plano dibujando los contornos de los laboratorios
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final node in floorPlan.nodes) {
      if (node.type == map_models.NodeType.laboratory) {
        final rect = Rect.fromCenter(
          center: Offset(node.x, node.y),
          width: 140,
          height: 90,
        );
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, borderPaint);

        // Dibujar etiqueta del laboratorio con fondo
        final textPainter = TextPainter(
          text: TextSpan(
            text: node.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        
        // Fondo semitransparente para el texto
        final textBgRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(node.x, node.y),
            width: textPainter.width + 8,
            height: textPainter.height + 6,
          ),
          const Radius.circular(4),
        );
        canvas.drawRRect(
          textBgRect,
          Paint()..color = Colors.white.withOpacity(0.9),
        );
        
        textPainter.paint(
          canvas,
          Offset(
            node.x - textPainter.width / 2,
            node.y - textPainter.height / 2,
          ),
        );
      }
    }

    // Dibujar pasillos (comentado por ahora, solo mostramos laboratorios)
    // final hallwayPaint = Paint()
    //   ..color = Colors.grey.shade200
    //   ..style = PaintingStyle.fill;

    for (final edge in floorPlan.edges) {
      canvas.drawLine(
        Offset(edge.from.x, edge.from.y),
        Offset(edge.to.x, edge.to.y),
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 20,
      );
    }
  }

  void _drawRoute(Canvas canvas) {
    if (route == null || route!.nodes.length < 2) return;

    final routePaint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(route!.nodes[0].x, route!.nodes[0].y);

    for (int i = 1; i < route!.nodes.length; i++) {
      path.lineTo(route!.nodes[i].x, route!.nodes[i].y);
    }

    canvas.drawPath(path, routePaint);

    // Dibujar puntos en cada nodo de la ruta
    for (final node in route!.nodes) {
      canvas.drawCircle(
        Offset(node.x, node.y),
        4,
        Paint()..color = Colors.blue.shade700,
      );
    }
  }

  void _drawNodes(Canvas canvas) {
    // Dibujar marcador de inicio
    if (startNode != null) {
      _drawMarker(
        canvas,
        startNode!,
        Colors.green,
        Icons.my_location,
        'Inicio',
      );
    }

    // Dibujar marcador de destino
    if (destinationNode != null) {
      _drawMarker(
        canvas,
        destinationNode!,
        Colors.red,
        Icons.location_on,
        'Destino',
      );
    }
  }

  void _drawMarker(
    Canvas canvas,
    map_models.MapNode node,
    Color color,
    IconData icon,
    String label,
  ) {
    // Círculo de fondo
    canvas.drawCircle(
      Offset(node.x, node.y),
      20,
      Paint()..color = color,
    );

    // Borde blanco
    canvas.drawCircle(
      Offset(node.x, node.y),
      20,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Etiqueta con fondo
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    
    // Fondo oscuro para el texto
    final labelBgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(node.x, node.y - 40),
        width: textPainter.width + 12,
        height: textPainter.height + 8,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      labelBgRect,
      Paint()..color = Colors.black.withOpacity(0.8),
    );
    
    textPainter.paint(
      canvas,
      Offset(
        node.x - textPainter.width / 2,
        node.y - 40 - textPainter.height / 2,
      ),
    );
  }

  void _drawAnimatedMarker(Canvas canvas) {
    if (route == null || route!.nodes.isEmpty) return;

    // Calcular posición actual en la ruta
    final totalNodes = route!.nodes.length - 1;
    final currentProgress = animationProgress * totalNodes;
    final currentIndex = currentProgress.floor();
    final segmentProgress = currentProgress - currentIndex;

    if (currentIndex >= totalNodes) {
      // Final de la animación
      final lastNode = route!.nodes.last;
      _drawAnimatedDot(canvas, Offset(lastNode.x, lastNode.y));
      return;
    }

    // Interpolación entre nodos
    final fromNode = route!.nodes[currentIndex];
    final toNode = route!.nodes[currentIndex + 1];

    final x = fromNode.x + (toNode.x - fromNode.x) * segmentProgress;
    final y = fromNode.y + (toNode.y - fromNode.y) * segmentProgress;

    _drawAnimatedDot(canvas, Offset(x, y));
  }

  void _drawAnimatedDot(Canvas canvas, Offset position) {
    // Pulso externo
    canvas.drawCircle(
      position,
      30,
      Paint()
        ..color = Colors.orange.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );

    // Círculo principal
    canvas.drawCircle(
      position,
      15,
      Paint()..color = Colors.orange,
    );

    // Borde blanco
    canvas.drawCircle(
      position,
      15,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Punto central
    canvas.drawCircle(
      position,
      6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.route != route ||
        oldDelegate.startNode != startNode ||
        oldDelegate.destinationNode != destinationNode ||
        oldDelegate.isAnimating != isAnimating;
  }
}
