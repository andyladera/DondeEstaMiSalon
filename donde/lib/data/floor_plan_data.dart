import '../models/map_models.dart';

/// Datos del plano del tercer nivel - Facultad de Ingeniería (FAIN)
/// Coordenadas basadas en la imagen piso3.jpg
class FloorPlanData {
  /// Ancho de referencia de la imagen del plano
  static const double imageWidth = 2000.0;
  
  /// Alto de referencia de la imagen del plano
  static const double imageHeight = 1200.0;

  /// Obtiene el plano del tercer nivel
  static FloorPlan get thirdFloor => _thirdFloor;

  /// Mapeo de códigos de laboratorio a IDs de nodos
  static const Map<String, String> labCodeToNodeId = {
    'LAB A': 'lab_a',
    'LAB B': 'lab_b',
    'LAB C': 'lab_c',
    'LAB D': 'lab_d',
    'LAB E': 'lab_e',
    'LAB F': 'lab_f',
    'P-301': 'lab_p301',
    'P-306': 'lab_p306',
    'P-307': 'lab_p307',
    'P-310': 'lab_p310',
    'P-312A': 'lab_p312a',
    'P-312B': 'lab_p312b',
    'Q-301A': 'lab_q301a',
    'Q-301B': 'lab_q301b',
    'Q-303': 'lab_q303',
    'Q-307': 'lab_q307',
    'Q-312': 'lab_q312',
    'R-301': 'lab_r301',
    'R-302': 'lab_r302',
    'R-303': 'lab_r303',
    'R-306': 'lab_r306',
    'R-308': 'lab_r308',
  };

  // Nodos del mapa (laboratorios, pasillos, intersecciones)
  static final List<MapNode> _nodes = [
    // ========== LABORATORIOS PRINCIPALES (con etiqueta LAB) ==========
    const MapNode(
      id: 'lab_a',
      name: 'LAB A',
      x: 400,
      y: 800,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_b',
      name: 'LAB B',
      x: 280,
      y: 450,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_c',
      name: 'LAB C',
      x: 500,
      y: 600,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_d',
      name: 'LAB D',
      x: 680,
      y: 620,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_e',
      name: 'LAB E',
      x: 820,
      y: 760,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_f',
      name: 'LAB F',
      x: 1650,
      y: 600,
      type: NodeType.laboratory,
    ),
    
    // ========== BLOQUE P (IZQUIERDA) ==========
    const MapNode(
      id: 'lab_p301',
      name: 'P-301',
      x: 120,
      y: 800,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_p307',
      name: 'P-307',
      x: 220,
      y: 600,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_p312a',
      name: 'P-312A\nSala Profesores',
      x: 380,
      y: 320,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_p312b',
      name: 'P-312B\nDirección EPIS',
      x: 480,
      y: 320,
      type: NodeType.laboratory,
    ),
    
    // ========== BLOQUE Q (CENTRO) ==========
    const MapNode(
      id: 'lab_q301a',
      name: 'Q-301A\nDirección EPIE',
      x: 600,
      y: 300,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_q301b',
      name: 'Q-301B\nSala Profesores',
      x: 720,
      y: 300,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_q303',
      name: 'Q-305\nCerítea',
      x: 850,
      y: 360,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_q307',
      name: 'Q-307',
      x: 920,
      y: 540,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_q312',
      name: 'Q-312',
      x: 1100,
      y: 650,
      type: NodeType.laboratory,
    ),
    
    // ========== BLOQUE R (DERECHA) ==========
    const MapNode(
      id: 'lab_r301',
      name: 'R-301',
      x: 1250,
      y: 650,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_r302',
      name: 'R-302\nBiología y Micro.',
      x: 1600,
      y: 720,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_r303',
      name: 'R-303',
      x: 1400,
      y: 575,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_r306',
      name: 'R-307\nLab Cómputo',
      x: 1650,
      y: 485,
      type: NodeType.laboratory,
    ),
    const MapNode(
      id: 'lab_r308',
      name: 'R-308',
      x: 1400,
      y: 475,
      type: NodeType.laboratory,
    ),


    // ========== PASILLOS E INTERSECCIONES ==========
    
    // Punto de partida (círculo negro en pasillo)
    const MapNode(
      id: 'starting_point',
      name: 'Punto de Partida',
      x: 250,
      y: 900,
      type: NodeType.entrance,
    ),
    
    // Entradas principales
    const MapNode(
      id: 'entrance_p',
      name: 'Entrada Bloque P',
      x: 80,
      y: 700,
      type: NodeType.entrance,
    ),
    const MapNode(
      id: 'entrance_r',
      name: 'Entrada Bloque R',
      x: 1100,
      y: 850,
      type: NodeType.entrance,
    ),
    
    // Ruta desde entrada P
    const MapNode(
      id: 'hall_p_lower',
      name: 'Pasillo P-301',
      x: 250,
      y: 800,
      type: NodeType.hallway,
    ),
    
    // Cruce 1: Desde P-301 hacia LAB A (ruta izquierda inferior)
    const MapNode(
      id: 'cross_p_to_a',
      name: 'Cruce P→A',
      x: 250,
      y: 800,
      type: NodeType.hallway,
    ),
    
    // Cruce 2: Zona LAB A / LAB E (cruce principal inferior)
    const MapNode(
      id: 'cross_center_lower',
      name: 'Cruce LAB A-E',
      x: 1050,
      y: 800,
      type: NodeType.hallway,
    ),
    
    // Cruce 3: Diagonal desde inferior hacia centro (sube hacia LAB C/D)
    const MapNode(
      id: 'cross_diagonal_up',
      name: 'Diagonal Arriba',
      x: 420,
      y: 450,
      type: NodeType.hallway,
    ),
    
    // Cruce 4: Centro (conecta LAB C, LAB D, P-307)
    const MapNode(
      id: 'cross_center',
      name: 'Cruce Central',
      x: 500,
      y: 450,
      type: NodeType.hallway,
    ),
    
    // Cruce 5: Superior izquierda (conecta a LAB B y P-312)
    const MapNode(
      id: 'cross_upper_left',
      name: 'Cruce P-312/LAB B',
      x: 350,
      y: 600,
      type: NodeType.hallway,
    ),
    
    // Cruce 6: Superior centro (hacia Q-301A/B/303)
    const MapNode(
      id: 'cross_upper_center',
      name: 'Cruce Q Superior',
      x: 600,
      y: 400,
      type: NodeType.hallway,
    ),
    
    // Cruce 7: Diagonal derecha (desde centro hacia Q-305/Q-307)
    const MapNode(
      id: 'cross_diagonal_right',
      name: 'Diagonal Derecha',
      x: 680,
      y: 450,
      type: NodeType.hallway,
    ),
    
    // Cruce 8: Q-307 (lado derecho medio)
    const MapNode(
      id: 'cross_q307',
      name: 'Cruce Q-307',
      x: 850,
      y: 650,
      type: NodeType.hallway,
    ),
    
    // Cruce 9: Zona Q-312/Entrada R (esquina inferior derecha)
    const MapNode(
      id: 'cross_q312_entrance',
      name: 'Q-312/Entrada R',
      x: 1050,
      y: 820,
      type: NodeType.hallway,
    ),
    
    // Cruce 10: R-301/R-302 (inferior derecha)
    const MapNode(
      id: 'cross_r_lower',
      name: 'R-301/302',
      x: 1150,
      y: 750,
      type: NodeType.hallway,
    ),
    
    // Cruce 11: R-303/LAB F (medio derecha)
    const MapNode(
      id: 'cross_r_mid',
      name: 'R-303/LAB F',
      x: 1350,
      y: 600,
      type: NodeType.hallway,
    ),
    
    // Cruce 12: R-308 y R-307 (Lab Cómputo)
    const MapNode(
      id: 'cross_r308',
      name: 'Cruce R-308/307',
      x: 1480,
      y: 420,
      type: NodeType.hallway,
    ),
  ];

  // Conexiones entre nodos (grafo)
  static final List<MapEdge> _edges = [
    // ========== PUNTO DE PARTIDA ==========
    MapEdge(
      from: _getNode('starting_point'),
      to: _getNode('hall_p_lower'),
      weight: _getNode('starting_point').distanceTo(_getNode('hall_p_lower')),
    ),
    MapEdge(
      from: _getNode('hall_p_lower'),
      to: _getNode('starting_point'),
      weight: _getNode('hall_p_lower').distanceTo(_getNode('starting_point')),
    ),
    MapEdge(
      from: _getNode('starting_point'),
      to: _getNode('cross_p_to_a'),
      weight: _getNode('starting_point').distanceTo(_getNode('cross_p_to_a')),
    ),
    MapEdge(
      from: _getNode('cross_p_to_a'),
      to: _getNode('starting_point'),
      weight: _getNode('cross_p_to_a').distanceTo(_getNode('starting_point')),
    ),
    
    // ========== ENTRADAS ==========
    
    MapEdge(
      from: _getNode('entrance_r'),
      to: _getNode('cross_q312_entrance'),
      weight: _getNode('entrance_r').distanceTo(_getNode('cross_q312_entrance')),
    ),
    MapEdge(
      from: _getNode('cross_q312_entrance'),
      to: _getNode('entrance_r'),
      weight: _getNode('cross_q312_entrance').distanceTo(_getNode('entrance_r')),
    ),

    // ========== LABORATORIOS PRINCIPALES ==========    
    // LAB C <-> Cruce Centro
    MapEdge(
      from: _getNode('lab_c'),
      to: _getNode('cross_center'),
      weight: _getNode('lab_c').distanceTo(_getNode('cross_center')),
    ),
    MapEdge(
      from: _getNode('cross_center'),
      to: _getNode('lab_c'),
      weight: _getNode('cross_center').distanceTo(_getNode('lab_c')),
    ),
    
    // LAB D <-> Cruce Centro
    MapEdge(
      from: _getNode('lab_d'),
      to: _getNode('cross_diagonal_right'),
      weight: _getNode('lab_d').distanceTo(_getNode('cross_diagonal_right')),
    ),
    MapEdge(
      from: _getNode('cross_diagonal_right'),
      to: _getNode('lab_d'),
      weight: _getNode('cross_diagonal_right').distanceTo(_getNode('lab_d')),
    ),
    
    // LAB F <-> Cruce R-303/LAB F
    MapEdge(
      from: _getNode('lab_f'),
      to: _getNode('cross_r_mid'),
      weight: _getNode('lab_f').distanceTo(_getNode('cross_r_mid')),
    ),
    MapEdge(
      from: _getNode('cross_r_mid'),
      to: _getNode('lab_f'),
      weight: _getNode('cross_r_mid').distanceTo(_getNode('lab_f')),
    ),

    // ========== BLOQUE P ==========
    // P-301 <-> Pasillo P-301
    MapEdge(
      from: _getNode('lab_p301'),
      to: _getNode('hall_p_lower'),
      weight: _getNode('lab_p301').distanceTo(_getNode('hall_p_lower')),
    ),
    MapEdge(
      from: _getNode('hall_p_lower'),
      to: _getNode('lab_p301'),
      weight: _getNode('hall_p_lower').distanceTo(_getNode('lab_p301')),
    ),
    
    // P-312A <-> Cruce Upper Left
    MapEdge(
      from: _getNode('lab_p307'),
      to: _getNode('cross_upper_left'),
      weight: _getNode('lab_p307').distanceTo(_getNode('cross_upper_left')),
    ),
    MapEdge(
      from: _getNode('cross_upper_left'),
      to: _getNode('lab_p307'),
      weight: _getNode('cross_upper_left').distanceTo(_getNode('lab_p307')),
    ),
    
    // P-312B <-> Cruce Upper Left
    MapEdge(
      from: _getNode('lab_p312b'),
      to: _getNode('cross_upper_left'),
      weight: _getNode('lab_p312b').distanceTo(_getNode('cross_upper_left')),
    ),
    MapEdge(
      from: _getNode('cross_upper_left'),
      to: _getNode('lab_p312b'),
      weight: _getNode('cross_upper_left').distanceTo(_getNode('lab_p312b')),
    ),

    // ========== BLOQUE Q ==========
    // Q-301A <-> Cruce Upper Center
    MapEdge(
      from: _getNode('lab_q301a'),
      to: _getNode('cross_upper_center'),
      weight: _getNode('lab_q301a').distanceTo(_getNode('cross_upper_center')),
    ),
    MapEdge(
      from: _getNode('cross_upper_center'),
      to: _getNode('lab_q301a'),
      weight: _getNode('cross_upper_center').distanceTo(_getNode('lab_q301a')),
    ),
    
    // Q-301B <-> Cruce Upper Center
    MapEdge(
      from: _getNode('lab_q301b'),
      to: _getNode('cross_upper_center'),
      weight: _getNode('lab_q301b').distanceTo(_getNode('cross_upper_center')),
    ),
    MapEdge(
      from: _getNode('cross_upper_center'),
      to: _getNode('lab_q301b'),
      weight: _getNode('cross_upper_center').distanceTo(_getNode('lab_q301b')),
    ),
    
    // Q-303 <-> Cruce Upper Center
    MapEdge(
      from: _getNode('lab_q303'),
      to: _getNode('cross_upper_center'),
      weight: _getNode('lab_q303').distanceTo(_getNode('cross_upper_center')),
    ),
    MapEdge(
      from: _getNode('cross_upper_center'),
      to: _getNode('lab_q303'),
      weight: _getNode('cross_upper_center').distanceTo(_getNode('lab_q303')),
    ),
    
    // Q-307 <-> Cruce Q-307
    MapEdge(
      from: _getNode('lab_q307'),
      to: _getNode('cross_q307'),
      weight: _getNode('lab_q307').distanceTo(_getNode('cross_q307')),
    ),
    MapEdge(
      from: _getNode('cross_q307'),
      to: _getNode('lab_q307'),
      weight: _getNode('cross_q307').distanceTo(_getNode('lab_q307')),
    ),
    
    // Q-312 <-> Cruce Q-312/Entrada R
    MapEdge(
      from: _getNode('cross_q307'),
      to: _getNode('lab_e'),
      weight: _getNode('cross_q307').distanceTo(_getNode('lab_e')),
    ),
    MapEdge(
      from: _getNode('lab_e'),
      to: _getNode('cross_q307'),
      weight: _getNode('lab_e').distanceTo(_getNode('cross_q307')),
    ),

    // ========== BLOQUE R ==========
    // R-301 <-> Cruce R-301/302
    MapEdge(
      from: _getNode('lab_r301'),
      to: _getNode('cross_r_lower'),
      weight: _getNode('lab_r301').distanceTo(_getNode('cross_r_lower')),
    ),
    MapEdge(
      from: _getNode('cross_r_lower'),
      to: _getNode('lab_r301'),
      weight: _getNode('cross_r_lower').distanceTo(_getNode('lab_r301')),
    ),
    
    // R-302 <-> Cruce R-301/302
    MapEdge(
      from: _getNode('lab_r302'),
      to: _getNode('cross_r_lower'),
      weight: _getNode('lab_r302').distanceTo(_getNode('cross_r_lower')),
    ),
    MapEdge(
      from: _getNode('cross_r_lower'),
      to: _getNode('lab_r302'),
      weight: _getNode('cross_r_lower').distanceTo(_getNode('lab_r302')),
    ),
    
    // R-303 <-> Cruce R-303/LAB F
    MapEdge(
      from: _getNode('lab_r303'),
      to: _getNode('cross_r_mid'),
      weight: _getNode('lab_r303').distanceTo(_getNode('cross_r_mid')),
    ),
    MapEdge(
      from: _getNode('cross_r_mid'),
      to: _getNode('lab_r303'),
      weight: _getNode('cross_r_mid').distanceTo(_getNode('lab_r303')),
    ),
    
    // R-306 <-> Cruce R-308
    MapEdge(
      from: _getNode('lab_r306'),
      to: _getNode('cross_r308'),
      weight: _getNode('lab_r306').distanceTo(_getNode('cross_r308')),
    ),
    MapEdge(
      from: _getNode('cross_r308'),
      to: _getNode('lab_r306'),
      weight: _getNode('cross_r308').distanceTo(_getNode('lab_r306')),
    ),
    
    // R-308 <-> Cruce R-308
    MapEdge(
      from: _getNode('lab_r308'),
      to: _getNode('cross_r308'),
      weight: _getNode('lab_r308').distanceTo(_getNode('cross_r308')),
    ),
    MapEdge(
      from: _getNode('cross_r308'),
      to: _getNode('lab_r308'),
      weight: _getNode('cross_r308').distanceTo(_getNode('lab_r308')),
    ),

    // ========== RED DE RUTAS (siguiendo líneas negras del plano) ==========
    
    // RUTA 1: Entrada P → P-301 → Cruce P→A
    MapEdge(
      from: _getNode('hall_p_lower'),
      to: _getNode('cross_p_to_a'),
      weight: _getNode('hall_p_lower').distanceTo(_getNode('cross_p_to_a')),
    ),
    MapEdge(
      from: _getNode('cross_p_to_a'),
      to: _getNode('hall_p_lower'),
      weight: _getNode('cross_p_to_a').distanceTo(_getNode('hall_p_lower')),
    ),
    
    // RUTA 2: Cruce P→A → Cruce LAB A-E (horizontal inferior)
    MapEdge(
      from: _getNode('cross_p_to_a'),
      to: _getNode('lab_a'),
      weight: _getNode('cross_p_to_a').distanceTo(_getNode('lab_a')),
    ),
    MapEdge(
      from: _getNode('lab_a'),
      to: _getNode('cross_p_to_a'),
      weight: _getNode('lab_a').distanceTo(_getNode('cross_p_to_a')),
    ),
    
    // RUTA 3: Cruce P→A → Diagonal Up (sube hacia centro)
    MapEdge(
      from: _getNode('cross_p_to_a'),
      to: _getNode('cross_upper_left'),
      weight: _getNode('cross_p_to_a').distanceTo(_getNode('cross_upper_left')),
    ),
    MapEdge(
      from: _getNode('cross_upper_left'),
      to: _getNode('cross_p_to_a'),
      weight: _getNode('cross_upper_left').distanceTo(_getNode('cross_p_to_a')),
    ),
    
    // RUTA 4: Diagonal Up → Cruce Centro
    MapEdge(
      from: _getNode('cross_diagonal_up'),
      to: _getNode('cross_center'),
      weight: _getNode('cross_diagonal_up').distanceTo(_getNode('cross_center')),
    ),
    MapEdge(
      from: _getNode('cross_center'),
      to: _getNode('cross_diagonal_up'),
      weight: _getNode('cross_center').distanceTo(_getNode('cross_diagonal_up')),
    ),
    
    // RUTA 5: Diagonal Up → Cruce Upper Left (hacia P-312/LAB B)
    MapEdge(
      from: _getNode('cross_diagonal_up'),
      to: _getNode('lab_b'),
      weight: _getNode('cross_diagonal_up').distanceTo(_getNode('lab_b')),
    ),
    MapEdge(
      from: _getNode('lab_b'),
      to: _getNode('cross_diagonal_up'),
      weight: _getNode('lab_b').distanceTo(_getNode('cross_diagonal_up')),
    ),
    
    // RUTA 6: Cruce Centro → Cruce Upper Center (hacia Q superior)
    MapEdge(
      from: _getNode('cross_center'),
      to: _getNode('cross_upper_center'),
      weight: _getNode('cross_center').distanceTo(_getNode('cross_upper_center')),
    ),
    MapEdge(
      from: _getNode('cross_upper_center'),
      to: _getNode('cross_center'),
      weight: _getNode('cross_upper_center').distanceTo(_getNode('cross_center')),
    ),
    
    // RUTA 7: Cruce Upper Left → Cruce Upper Center (horizontal superior)
    MapEdge(
      from: _getNode('cross_upper_left'),
      to: _getNode('cross_diagonal_up'),
      weight: _getNode('cross_upper_left').distanceTo(_getNode('cross_diagonal_up')),
    ),
    MapEdge(
      from: _getNode('cross_diagonal_up'),
      to: _getNode('cross_upper_left'),
      weight: _getNode('cross_diagonal_up').distanceTo(_getNode('cross_upper_left')),
    ),
    
    // RUTA 8: Cruce Centro → Diagonal Right (hacia Q-307)
    MapEdge(
      from: _getNode('cross_center'),
      to: _getNode('cross_diagonal_right'),
      weight: _getNode('cross_center').distanceTo(_getNode('cross_diagonal_right')),
    ),
    MapEdge(
      from: _getNode('cross_diagonal_right'),
      to: _getNode('cross_center'),
      weight: _getNode('cross_diagonal_right').distanceTo(_getNode('cross_center')),
    ),
    
    // RUTA 9: Cruce Upper Center → Diagonal Right (baja hacia Q-307)
    MapEdge(
      from: _getNode('cross_upper_center'),
      to: _getNode('cross_diagonal_right'),
      weight: _getNode('cross_upper_center').distanceTo(_getNode('cross_diagonal_right')),
    ),
    MapEdge(
      from: _getNode('cross_diagonal_right'),
      to: _getNode('cross_upper_center'),
      weight: _getNode('cross_diagonal_right').distanceTo(_getNode('cross_upper_center')),
    ),
    
    // RUTA 10: Diagonal Right → Cruce Q-307
    MapEdge(
      from: _getNode('cross_diagonal_right'),
      to: _getNode('cross_q307'),
      weight: _getNode('cross_diagonal_right').distanceTo(_getNode('cross_q307')),
    ),
    MapEdge(
      from: _getNode('cross_q307'),
      to: _getNode('cross_diagonal_right'),
      weight: _getNode('cross_q307').distanceTo(_getNode('cross_diagonal_right')),
    ),
    
    // RUTA 11: Cruce Q-307 → Cruce Q-312/Entrada R
    MapEdge(
      from: _getNode('cross_q307'),
      to: _getNode('cross_q312_entrance'),
      weight: _getNode('cross_q307').distanceTo(_getNode('cross_q312_entrance')),
    ),
    MapEdge(
      from: _getNode('cross_q312_entrance'),
      to: _getNode('cross_q307'),
      weight: _getNode('cross_q312_entrance').distanceTo(_getNode('cross_q307')),
    ),
    
    // RUTA 12: Cruce Q-312/Entrada R → Cruce R-301/302
    MapEdge(
      from: _getNode('cross_q312_entrance'),
      to: _getNode('cross_r_lower'),
      weight: _getNode('cross_q312_entrance').distanceTo(_getNode('cross_r_lower')),
    ),
    MapEdge(
      from: _getNode('cross_r_lower'),
      to: _getNode('cross_q312_entrance'),
      weight: _getNode('cross_r_lower').distanceTo(_getNode('cross_q312_entrance')),
    ),
    
    // RUTA 13: Cruce R-301/302 → Cruce R-303/LAB F
    MapEdge(
      from: _getNode('cross_r_lower'),
      to: _getNode('cross_r_mid'),
      weight: _getNode('cross_r_lower').distanceTo(_getNode('cross_r_mid')),
    ),
    MapEdge(
      from: _getNode('cross_r_mid'),
      to: _getNode('cross_r_lower'),
      weight: _getNode('cross_r_mid').distanceTo(_getNode('cross_r_lower')),
    ),
    
    // RUTA 14: Cruce R-303/LAB F → Cruce R-308
    MapEdge(
      from: _getNode('cross_r_mid'),
      to: _getNode('cross_r308'),
      weight: _getNode('cross_r_mid').distanceTo(_getNode('cross_r308')),
    ),
    MapEdge(
      from: _getNode('cross_r308'),
      to: _getNode('cross_r_mid'),
      weight: _getNode('cross_r_lower').distanceTo(_getNode('cross_r_mid')),
    ),
  ];

  static final FloorPlan _thirdFloor = FloorPlan(
    id: 'floor_3',
    name: 'Tercer Nivel - FAIN',
    level: 3,
    imagePath: 'assets/piso3.jpg',
    imageWidth: imageWidth,
    imageHeight: imageHeight,
    nodes: _nodes,
    edges: _edges,
  );

  // Helper para obtener nodo por ID
  static MapNode _getNode(String id) {
    return _nodes.firstWhere((node) => node.id == id);
  }

  /// Encuentra el nodo correspondiente a un código de laboratorio
  static MapNode? getNodeByLabCode(String labCode) {
    final nodeId = labCodeToNodeId[labCode.toUpperCase()];
    if (nodeId == null) return null;
    return _thirdFloor.findNodeById(nodeId);
  }
}
