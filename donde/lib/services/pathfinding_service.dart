import 'dart:math';
import '../models/map_models.dart';

/// Clase auxiliar para A* que asocia un nodo con sus scores
class _NodeScore {
  final MapNode node;
  final double gScore;
  final double fScore;

  _NodeScore(this.node, this.gScore, this.fScore);
}

/// Cola de prioridad simple para A*
class PriorityQueue<T> {
  final List<T> _items = [];
  final Comparator<T> _comparator;

  PriorityQueue(this._comparator);

  void add(T item) {
    _items.add(item);
    _items.sort(_comparator);
  }

  T removeFirst() => _items.removeAt(0);

  bool get isNotEmpty => _items.isNotEmpty;
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;

  bool any(bool Function(T) test) => _items.any(test);
}

/// Servicio para calcular rutas óptimas usando el algoritmo A*
class PathfindingService {
  final FloorPlan floorPlan;

  PathfindingService(this.floorPlan);

  /// Calcula la ruta más corta entre dos nodos usando A*
  Route? findPath(MapNode start, MapNode goal) {
    if (start == goal) {
      return Route(
        nodes: [start],
        totalDistance: 0,
        instructions: ['Ya estás en tu destino'],
      );
    }

    // Conjunto de nodos a evaluar
    final openSet = PriorityQueue<_NodeScore>((a, b) => a.fScore.compareTo(b.fScore));
    openSet.add(_NodeScore(start, 0, _heuristic(start, goal)));

    // Conjunto de nodos ya evaluados
    final closedSet = <MapNode>{};

    // Mapa para reconstruir el camino
    final cameFrom = <MapNode, MapNode>{};

    // Costos conocidos desde el inicio
    final gScore = <MapNode, double>{start: 0};

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      final currentNode = current.node;

      // Si llegamos al destino, reconstruir y retornar el camino
      if (currentNode == goal) {
        return _reconstructPath(cameFrom, currentNode, gScore[goal]!);
      }

      closedSet.add(currentNode);

      // Evaluar vecinos
      for (final neighbor in floorPlan.getNeighbors(currentNode)) {
        if (closedSet.contains(neighbor)) continue;

        final edgeWeight = floorPlan.getEdgeWeight(currentNode, neighbor) ?? double.infinity;
        final tentativeGScore = gScore[currentNode]! + edgeWeight;

        if (!gScore.containsKey(neighbor) || tentativeGScore < gScore[neighbor]!) {
          // Este camino al vecino es mejor que cualquier anterior
          cameFrom[neighbor] = currentNode;
          gScore[neighbor] = tentativeGScore;
          final fScore = tentativeGScore + _heuristic(neighbor, goal);

          // Agregar a openSet si no está ya
          if (!openSet.any((ns) => ns.node == neighbor)) {
            openSet.add(_NodeScore(neighbor, tentativeGScore, fScore));
          }
        }
      }
    }

    // No se encontró camino
    return null;
  }

  /// Heurística: distancia euclidiana (optimista para A*)
  double _heuristic(MapNode a, MapNode b) {
    return a.distanceTo(b);
  }

  /// Reconstruye el camino desde el nodo final
  Route _reconstructPath(
    Map<MapNode, MapNode> cameFrom,
    MapNode current,
    double totalDistance,
  ) {
    final path = <MapNode>[current];
    var node = current;

    while (cameFrom.containsKey(node)) {
      node = cameFrom[node]!;
      path.insert(0, node);
    }

    final instructions = _generateInstructions(path);

    return Route(
      nodes: path,
      totalDistance: totalDistance,
      instructions: instructions,
    );
  }

  /// Genera instrucciones paso a paso para la ruta
  List<String> _generateInstructions(List<MapNode> path) {
    if (path.isEmpty) return [];
    if (path.length == 1) return ['Ya estás en tu destino'];

    final instructions = <String>[];
    
    instructions.add('Comienza en ${path.first.name}');

    for (int i = 1; i < path.length; i++) {
      final previous = path[i - 1];
      final current = path[i];
      final distance = previous.distanceTo(current);
      
      String instruction;
      
      if (current.type == NodeType.laboratory) {
        instruction = '🎯 Has llegado a ${current.name}';
      } else if (current.type == NodeType.stairs) {
        instruction = '🪜 Usa las ${current.name}';
      } else if (current.type == NodeType.intersection) {
        // Determinar dirección
        final direction = _getDirection(previous, current, path.length > i + 1 ? path[i + 1] : null);
        instruction = '$direction hacia ${current.name}';
      } else {
        instruction = '➡️ Avanza ${distance.toStringAsFixed(0)}m por ${current.name}';
      }
      
      instructions.add(instruction);
    }

    return instructions;
  }

  /// Determina la dirección del giro
  String _getDirection(MapNode from, MapNode current, MapNode? next) {
    if (next == null) return '➡️ Continúa';

    // Calcular ángulos
    final angle1 = atan2(current.y - from.y, current.x - from.x);
    final angle2 = atan2(next.y - current.y, next.x - current.x);
    var angleDiff = angle2 - angle1;

    // Normalizar ángulo entre -π y π
    while (angleDiff > pi) angleDiff -= 2 * pi;
    while (angleDiff < -pi) angleDiff += 2 * pi;

    if (angleDiff.abs() < pi / 6) return '➡️ Continúa recto';
    if (angleDiff > 0) return '⬅️ Gira a la izquierda';
    return '➡️ Gira a la derecha';
  }
}
