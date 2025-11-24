# Instrucciones para completar la configuración

## 📁 Imagen del plano

Para que la funcionalidad del mapa funcione correctamente, debes colocar la imagen del plano en:

```
donde/assets/piso3.jpg
```

**Pasos:**
1. Toma una foto clara del plano del tercer nivel (como la que compartiste)
2. Guarda la imagen como `piso3.jpg`
3. Colócala en la carpeta `donde/assets/`

## 🚀 Ejecutar la aplicación

Después de colocar la imagen, ejecuta:

```bash
cd donde
flutter pub get
flutter run
```

## ✨ Funcionalidades implementadas

### 1. **Modelos de datos**
- `MapNode`: Representa laboratorios, pasillos, intersecciones
- `MapEdge`: Conexiones entre nodos con distancias
- `FloorPlan`: Plano completo con todos los nodos y conexiones
- `Route`: Ruta calculada con distancia total e instrucciones

### 2. **Datos del mapa** (`lib/data/floor_plan_data.dart`)
- Coordenadas de todos los laboratorios del 3er nivel:
  - Bloque P: P-301, P-307, P-310
  - Bloque Q: Q-307, Q-309, Q-312 (LAB A)
  - Bloque R: R-301 (LAB D), R-303 (LAB E), R-308, R-315 (LAB C), R-317 (LAB B), R-31A
- Grafo de navegación con pasillos e intersecciones
- Mapeo de códigos LAB A/B/C/D/E a ubicaciones físicas

### 3. **Algoritmo de pathfinding** (`lib/services/pathfinding_service.dart`)
- Implementación del algoritmo A*
- Calcula la ruta más corta entre dos puntos
- Genera instrucciones paso a paso:
  - "Comienza en [ubicación]"
  - "Avanza X metros por [pasillo]"
  - "Gira a la izquierda/derecha"
  - "Usa las escaleras"
  - "Has llegado a [laboratorio]"
- Estima tiempo de llegada

### 4. **Pantalla de mapa** (`lib/screens/map_screen.dart`)
- Visualización interactiva del plano con zoom y pan
- Marcadores de inicio (verde) y destino (rojo)
- Ruta trazada en azul entre ubicaciones
- **Animación de recorrido simulado:**
  - Marcador animado que se mueve por la ruta
  - Controles de play, pause y reiniciar
  - Velocidad ajustable según número de nodos
- Panel de información con distancia y tiempo estimado
- Lista de instrucciones paso a paso
- Selector de ubicación actual

### 5. **Integración con horarios** (modificaciones en `main.dart`)
- Botón "Ver en mapa" 🗺️ en cada laboratorio
- Funciona en ambas vistas:
  - `LabsOrderedScreen`: Lista organizada por día
  - `LabsResultScreen`: Vista de laboratorios por curso
- Al presionar el botón, abre el mapa con la ruta calculada

## 🎯 Flujo de uso

1. Usuario inicia sesión con credenciales UPT
2. Ve su horario de clases
3. Presiona botón "Laboratorio" para ver ubicaciones
4. Aparecen los laboratorios con botón "Ver en mapa" 🗺️
5. Al presionar, se abre el mapa mostrando:
   - Ubicación actual (seleccionable)
   - Destino (laboratorio de la clase)
   - Ruta óptima trazada
6. Puede iniciar animación del recorrido para ver cómo llegar
7. Instrucciones paso a paso lo guían

## 🔧 Ajustes opcionales

### Mejorar coordenadas
Las coordenadas en `floor_plan_data.dart` son estimadas. Puedes ajustarlas midiendo en la imagen real del plano para mayor precisión.

### Agregar más pisos
Para expandir a otros niveles:
1. Crea nuevas definiciones de nodos y edges
2. Agrega nuevas imágenes de planos
3. Modifica `FloorPlanData` para incluir múltiples pisos

### Localización automática
Futuras mejoras pueden incluir:
- Beacons Bluetooth
- Triangulación WiFi
- Códigos QR en ubicaciones estratégicas

## 📝 Notas técnicas

- **Algoritmo A***: Garantiza la ruta más corta
- **Grafo bidireccional**: Permite navegación en ambas direcciones
- **Animación suave**: Interpolación entre nodos
- **Responsive**: Funciona en diferentes tamaños de pantalla
- **Sin dependencias externas pesadas**: Solo usa Flutter material y http

## 🐛 Solución de problemas

Si la app no compila:
1. Verifica que `piso3.jpg` esté en `assets/`
2. Ejecuta `flutter clean` y luego `flutter pub get`
3. Revisa que no haya errores de importación

Si el mapa no se ve bien:
1. Ajusta las coordenadas en `floor_plan_data.dart`
2. Verifica que la imagen del plano sea clara
3. Prueba diferentes niveles de zoom
