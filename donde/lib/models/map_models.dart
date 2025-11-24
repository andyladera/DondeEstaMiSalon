import 'dart:math';

/// Representa un nodo en el mapa (laboratorio, pasillo, intersección)
class MapNode {
  final String id;
  final String name;
  final double x;
  final double y;
  final NodeType type;
  
  const MapNode({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.type,
  });

  /// Calcula la distancia euclidiana hasta otro nodo
  double distanceTo(MapNode other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MapNode($id: $name)';
}

enum NodeType {
  laboratory,    // Laboratorio
  hallway,       // Pasillo
  intersection,  // Intersección de pasillos
  stairs,        // Escaleras
  entrance,      // Entrada
}

/// Representa una conexión entre dos nodos
class MapEdge {
  final MapNode from;
  final MapNode to;
  final double weight; // Distancia o costo
  
  const MapEdge({
    required this.from,
    required this.to,
    required this.weight,
  });

  @override
  String toString() => 'Edge(${from.id} -> ${to.id}, weight: $weight)';
}

/// Representa el plano de un piso
class FloorPlan {
  final String id;
  final String name;
  final int level;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final List<MapNode> nodes;
  final List<MapEdge> edges;
  
  const FloorPlan({
    required this.id,
    required this.name,
    required this.level,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.nodes,
    required this.edges,
  });

  /// Encuentra un nodo por su ID
  MapNode? findNodeById(String id) {
    try {
      return nodes.firstWhere((node) => node.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Encuentra un nodo por nombre (búsqueda parcial)
  MapNode? findNodeByName(String name) {
    try {
      return nodes.firstWhere(
        (node) => node.name.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  /// Obtiene todos los vecinos de un nodo
  List<MapNode> getNeighbors(MapNode node) {
    return edges
        .where((edge) => edge.from == node)
        .map((edge) => edge.to)
        .toList();
  }

  /// Obtiene el peso de la arista entre dos nodos
  double? getEdgeWeight(MapNode from, MapNode to) {
    try {
      final edge = edges
          .firstWhere((edge) => edge.from == from && edge.to == to);
      return edge.weight;
    } catch (_) {
      return null;
    }
  }
}

/// Representa una ruta calculada
class Route {
  final List<MapNode> nodes;
  final double totalDistance;
  final List<String> instructions;
  
  const Route({
    required this.nodes,
    required this.totalDistance,
    required this.instructions,
  });

  bool get isEmpty => nodes.isEmpty;
  bool get isNotEmpty => nodes.isNotEmpty;
  
  int get length => nodes.length;

  /// Tiempo estimado en minutos (asumiendo velocidad de caminata promedio)
  double get estimatedTimeMinutes {
    // Velocidad promedio: ~80 metros/minuto (4.8 km/h)
    // Como trabajamos con coordenadas de píxeles, asumimos 1 unidad = 1 metro
    return totalDistance / 80.0;
  }

  @override
  String toString() => 
      'Route(${nodes.length} nodes, ${totalDistance.toStringAsFixed(1)}m)';
}
