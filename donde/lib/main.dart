import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donde',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoginScreen(),
    );
  }
}

const baseHost = 'http://161.132.67.57';

class ApiClient {
  final String base;
  List<dynamic> lastSchedule = const [];
  ApiClient(this.base);
  Future<bool> loginFast(String codigo, String password) async {
    final url = Uri.parse('$base:3000/');
    final r = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'codigo': codigo, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));
    return r.statusCode == 200;
  }

  Future<List<dynamic>> fetchSchedule(String codigo, String password) async {
    final url = Uri.parse('$base:3000/');
    final r = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'codigo': codigo, 'password': password}),
        )
        .timeout(const Duration(seconds: 65));
    if (r.statusCode != 200) return [];
    final body = r.body.trim();
    try {
      final j = jsonDecode(body);
      if (j is List) {
        lastSchedule = j;
        return j;
      }
      if (j is Map<String, dynamic>) {
        final data = j['data'] ?? j['horarios'] ?? j['schedule'];
        if (data is List) {
          lastSchedule = data;
          return data;
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> labsByCodigo(
    String codigo, {
    String? jsonPath,
    String? dirPath,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$base:3001/map');
      final payload = {'codigo': codigo};
      final r = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));
      if (r.statusCode != 200) return [];
      final j = jsonDecode(r.body);
      final d = j is Map<String, dynamic> ? j['data'] : j;
      return d is List ? d : [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, Map<String, String>>> labsMap(String codigo) async {
    try {
      final url = Uri.parse('$base:3001/map');
      final r = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'codigo': codigo}),
          )
          .timeout(const Duration(seconds: 60));
      if (r.statusCode != 200) return {};
      final j = jsonDecode(r.body);
      final list = j is Map<String, dynamic> ? j['data'] : j;
      final out = <String, Map<String, String>>{};
      if (list is List) {
        for (final it in list) {
          if (it is Map<String, dynamic>) {
            final code = (it['codigo'] ?? it['code'] ?? '').toString().trim();
            final labs = it['labs'];
            if (code.isNotEmpty && labs is Map) {
              final m = <String, String>{};
              labs.forEach((k, v) {
                final kk = k.toString().toLowerCase();
                final vv = v?.toString() ?? '';
                if (vv.isNotEmpty) m[kk] = vv;
              });
              out[code] = m;
            }
          }
        }
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<List<dynamic>> labsOrderedDays(
    String codigo,
    List<dynamic> horarios, {
    String? password,
  }) async {
    Future<List<dynamic>> parse(http.Response r) async {
      if (r.statusCode != 200) return [];
      final j = jsonDecode(r.body);
      final d = j is Map<String, dynamic> ? j['data'] : j;
      return d is List ? d : [];
    }

    final payloadFull = {
      'codigo': codigo,
      'horarios': horarios,
      if (password != null) 'password': password,
    };
    final payloadCodeOnly = {
      'codigo': codigo,
      if (password != null) 'password': password,
    };
    try {
      var url = Uri.parse('$base:3001/map-json-ordered');
      var r = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payloadFull),
          )
          .timeout(const Duration(seconds: 60));
      var out = await parse(r);
      if (out.isNotEmpty) return out;
      if (r.statusCode == 400 || r.statusCode == 405) {
        r = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payloadCodeOnly),
            )
            .timeout(const Duration(seconds: 60));
        out = await parse(r);
        if (out.isNotEmpty) return out;
      }
      url = Uri.parse('$base:3001/map');
      r = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payloadFull),
          )
          .timeout(const Duration(seconds: 60));
      out = await parse(r);
      if (out.isNotEmpty) return out;
      r = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payloadCodeOnly),
          )
          .timeout(const Duration(seconds: 60));
      out = await parse(r);
      if (out.isNotEmpty) return out;
      return [];
    } catch (_) {
      return [];
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final codigoCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  bool loading = false;
  String? error;
  bool _obscurePassword = true;

  void submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final api = ApiClient(baseHost);
    bool ok = false;
    try {
      ok = await api.loginFast(codigoCtl.text.trim(), passwordCtl.text.trim());
    } catch (e) {
      ok = true;
    }
    setState(() {
      loading = false;
    });
    if (!ok) {
      setState(() {
        error = 'Credenciales inválidas';
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          api: api,
          codigo: codigoCtl.text.trim(),
          password: passwordCtl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1), // Azul oscuro profesional
              const Color(0xFF1976D2), // Azul medio
              const Color(0xFF2196F3), // Azul claro
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 48,
                vertical: 32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo EPIS
                  Container(
                    width: isSmallScreen ? 180 : 220,
                    height: isSmallScreen ? 180 : 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/logoEPIS.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  const Text(
                    'Donde',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtítulo
                  Text(
                    'Sistema de Localización de Laboratorios',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Tarjeta de Login
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: isSmallScreen ? double.infinity : 450,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Campo Código
                          TextField(
                            controller: codigoCtl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Código',
                              hintText: 'Ingresa tu código',
                              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1976D2)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo Contraseña
                          TextField(
                            controller: passwordCtl,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Ingresa tu contraseña',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1976D2)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Botón Ingresar
                          ElevatedButton(
                            onPressed: loading ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Ingresar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),

                          // Mensaje de error
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        error!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    'Escuela Profesional de Ingeniería de Sistemas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Universidad Privada de Tacna',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LabsScreen extends StatefulWidget {
  final ApiClient api;
  final String codigo;
  const LabsScreen({super.key, required this.api, required this.codigo});
  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  List<dynamic> data = [];
  bool loading = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final res = await widget.api.labsByCodigo(widget.codigo);
    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Labs ${widget.codigo}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final item = data[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(
                    '${item['codigo'] ?? ''} ${item['curso'] ?? item['asignatura'] ?? ''}',
                  ),
                  subtitle: Text(
                    'Lunes: ${item['lunes'] ?? ''}\nMartes: ${item['martes'] ?? ''}\nMiércoles: ${item['miércoles'] ?? item['miercoles'] ?? ''}\nJueves: ${item['jueves'] ?? ''}\nViernes: ${item['viernes'] ?? ''}\nSábado: ${item['sábado'] ?? item['sabado'] ?? ''}\nDomingo: ${item['domingo'] ?? ''}',
                  ),
                );
              },
            ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  final ApiClient api;
  final String codigo;
  final String password;
  const ScheduleScreen({
    super.key,
    required this.api,
    required this.codigo,
    required this.password,
  });
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<dynamic> horarios = const [];
  Map<String, Map<String, String>> labs = {};
  bool computing = false;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await widget.api.fetchSchedule(
        widget.codigo,
        widget.password,
      );
      setState(() {
        horarios = res;
      });
    } catch (e) {
      setState(() {
        error = 'Tiempo de espera o red. Reintenta';
      });
    }
    setState(() {
      loading = false;
    });
  }

  void computeLabs() async {
    setState(() {
      computing = true;
    });
    final ordered = await widget.api.labsOrderedDays(
      widget.codigo,
      horarios,
      password: widget.password,
    );
    if (ordered.isNotEmpty) {
      setState(() {
        computing = false;
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LabsOrderedScreen(days: ordered)),
      );
      return;
    }
    Map<String, Map<String, String>> res = await widget.api.labsMap(
      widget.codigo,
    );
    if (res.isEmpty) {
      res = _computeLabs(horarios);
    }
    setState(() {
      labs = res;
      computing = false;
    });
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LabsResultScreen(labs: labs)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mi Horario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              widget.codigo,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (!loading && horarios.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: !computing ? () => computeLabs() : null,
                icon: computing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.place, size: 18),
                label: const Text('Laboratorios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1976D2),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando horario...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : (error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _ScheduleView(horarios: horarios)),
    );
  }
}

class LabsResultScreen extends StatelessWidget {
  final Map<String, Map<String, String>> labs;
  const LabsResultScreen({super.key, required this.labs});
  @override
  Widget build(BuildContext context) {
    final entries = labs.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratorios')),
      body: entries.isEmpty
          ? const Center(child: Text('Sin laboratorios para mostrar'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final code = entries[i].key;
                final byDay = entries[i].value;
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...byDay.entries
                                .map(
                                  (e) => Chip(
                                    label: Text(
                                      '${_capitalize(e.key)}: ${e.value}',
                                    ),
                                  ),
                                )
                                .toList(),
                            // Botón para ver en el mapa
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MapScreen(
                                      destinationLabCode: code,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text('Ver en mapa'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class LabsOrderedScreen extends StatelessWidget {
  final List<dynamic> days;
  const LabsOrderedScreen({super.key, required this.days});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: const Text(
          'Laboratorios (Ordenado)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i] as Map<String, dynamic>;
          final dayName = (d['dia'] ?? '').toString();
          final items = (d['items'] ?? []) as List<dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...items.map((it) {
                    final m = (it as Map<String, dynamic>);
                    final code = (m['codigo'] ?? '').toString();
                    final course = (m['curso'] ?? '').toString();
                    final teacher = (m['docente'] ?? '').toString();
                    final hour = (m['hora'] ?? '').toString();
                    String labText = '';
                    final lugares = m['lugares'];
                    if (lugares is List) {
                      final parts = lugares
                          .map((e) => e?.toString() ?? '')
                          .where((s) => s.isNotEmpty)
                          .toList();
                      final labLike = parts.firstWhere(
                        (s) =>
                            RegExp(r'^LAB\s+[A-Z]$').hasMatch(s) ||
                            RegExp(r'^P-\d+$').hasMatch(s),
                        orElse: () => '',
                      );
                      labText = labLike.isNotEmpty
                          ? labLike
                          : (parts.isNotEmpty ? parts.join(' ') : '');
                    } else {
                      labText =
                          (m['lab'] ??
                                  m['aula'] ??
                                  m['lugar'] ??
                                  m['lugares'] ??
                                  '')
                              .toString();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.green.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      hour,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  teacher,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (labText.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.place, size: 16, color: Colors.orange.shade700),
                                        const SizedBox(width: 6),
                                        Text(
                                          labText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MapScreen(
                                          destinationLabCode: labText,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text('Mapa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  final List<dynamic> horarios;
  const _ScheduleView({required this.horarios});
  @override
  Widget build(BuildContext context) {
    if (horarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay cursos registrados',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: horarios.length,
      itemBuilder: (context, i) {
        final h = horarios[i] as Map<String, dynamic>;
        final code = (h['codigo'] ?? '').toString();
        final course = (h['curso'] ?? h['asignatura'] ?? '').toString();
        final days = [
          'lunes',
          'martes',
          'miércoles',
          'miercoles',
          'jueves',
          'viernes',
          'sábado',
          'sabado',
          'domingo',
        ];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  course,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: days.map((d) {
                      final v = (h[d] ?? '').toString();
                      if (v.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _capitalize(d),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                v,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Map<String, Map<String, String>> _computeLabs(List<dynamic> horarios) {
  final out = <String, Map<String, String>>{};
  for (final item in horarios) {
    final h = (item as Map<String, dynamic>);
    final code = (h['codigo'] ?? '').toString().trim();
    if (code.isEmpty) continue;
    final labs = <String, String>{};
    if (h.containsKey('dia') && (h['aula'] != null || h['lugar'] != null)) {
      final dname = (h['dia'] ?? '').toString().toLowerCase();
      final val = (h['aula'] ?? h['lugar'] ?? '').toString();
      if (val.isNotEmpty && dname.isNotEmpty) labs[dname] = val;
    } else {
      for (final dia in [
        'lunes',
        'martes',
        'miércoles',
        'miercoles',
        'jueves',
        'viernes',
        'sábado',
        'sabado',
        'domingo',
      ]) {
        final txt = (h[dia] ?? '').toString();
        if (txt.isEmpty) continue;
        final labReg = RegExp(r'\bLAB\s+[A-Z]\b');
        final pReg = RegExp(r'\bP-\d+\b');
        final a = labReg.allMatches(txt).map((m) => m.group(0)!).toList();
        final b = a.isEmpty
            ? pReg.allMatches(txt).map((m) => m.group(0)!).toList()
            : a;
        if (b.isNotEmpty) labs[dia] = b.join(' - ');
      }
    }
    if (labs.isNotEmpty) {
      final cur = out[code] ?? <String, String>{};
      cur.addAll(labs);
      out[code] = cur;
    }
  }
  return out;
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  final l = s[0].toUpperCase();
  return l + s.substring(1);
}
