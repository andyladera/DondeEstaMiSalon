/// Datos de horario simulados para testing
/// Permite probar la navegación a todos los laboratorios sin necesidad de credenciales reales
class MockScheduleData {
  /// Genera un horario mock completo con clases en todos los laboratorios
  static List<Map<String, dynamic>> getMockSchedule() {
    return [
      // LAB A
      {
        'codigo': 'MOCK101',
        'curso': 'Física I - Mock',
        'dia': 'Lunes',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'LAB A',
      },
      
      // LAB B
      {
        'codigo': 'MOCK102',
        'curso': 'Química General - Mock',
        'dia': 'Martes',
        'horaInicio': '10:00',
        'horaFin': '12:00',
        'laboratorio': 'LAB B',
      },
      
      // LAB C
      {
        'codigo': 'MOCK103',
        'curso': 'Circuitos Eléctricos - Mock',
        'dia': 'Miércoles',
        'horaInicio': '14:00',
        'horaFin': '16:00',
        'laboratorio': 'LAB C',
      },
      
      // LAB D
      {
        'codigo': 'MOCK104',
        'curso': 'Electrónica Digital - Mock',
        'dia': 'Jueves',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'LAB D',
      },
      
      // LAB E
      {
        'codigo': 'MOCK105',
        'curso': 'Telecomunicaciones - Mock',
        'dia': 'Viernes',
        'horaInicio': '10:00',
        'horaFin': '12:00',
        'laboratorio': 'LAB E',
      },
      
      // LAB F
      {
        'codigo': 'MOCK106',
        'curso': 'Sistemas de Control - Mock',
        'dia': 'Lunes',
        'horaInicio': '14:00',
        'horaFin': '16:00',
        'laboratorio': 'LAB F',
      },
      
      // P-301
      {
        'codigo': 'MOCK201',
        'curso': 'Programación I - Mock',
        'dia': 'Martes',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'P-301',
      },
      
      // P-306
      {
        'codigo': 'MOCK202',
        'curso': 'Base de Datos - Mock',
        'dia': 'Miércoles',
        'horaInicio': '10:00',
        'horaFin': '12:00',
        'laboratorio': 'P-306',
      },
      
      // P-307
      {
        'codigo': 'MOCK203',
        'curso': 'Algoritmos - Mock',
        'dia': 'Jueves',
        'horaInicio': '14:00',
        'horaFin': '16:00',
        'laboratorio': 'P-307',
      },
      
      // P-310
      {
        'codigo': 'MOCK204',
        'curso': 'Estructuras de Datos - Mock',
        'dia': 'Viernes',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'P-310',
      },
      
      // P-312A
      {
        'codigo': 'MOCK205',
        'curso': 'Tutoría EPIS - Mock',
        'dia': 'Lunes',
        'horaInicio': '16:00',
        'horaFin': '18:00',
        'laboratorio': 'P-312A',
      },
      
      // P-312B
      {
        'codigo': 'MOCK206',
        'curso': 'Asesoría Dirección - Mock',
        'dia': 'Martes',
        'horaInicio': '14:00',
        'horaFin': '16:00',
        'laboratorio': 'P-312B',
      },
      
      // Q-301A
      {
        'codigo': 'MOCK301',
        'curso': 'Tutoría EPIE - Mock',
        'dia': 'Miércoles',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'Q-301A',
      },
      
      // Q-301B
      {
        'codigo': 'MOCK302',
        'curso': 'Asesoría Profesores - Mock',
        'dia': 'Jueves',
        'horaInicio': '10:00',
        'horaFin': '12:00',
        'laboratorio': 'Q-301B',
      },
      
      // Q-303
      {
        'codigo': 'MOCK303',
        'curso': 'Investigación Cerítea - Mock',
        'dia': 'Viernes',
        'horaInicio': '14:00',
        'horaFin': '16:00',
        'laboratorio': 'Q-303',
      },
      
      // Q-307
      {
        'codigo': 'MOCK304',
        'curso': 'Robótica - Mock',
        'dia': 'Lunes',
        'horaInicio': '10:00',
        'horaFin': '12:00',
        'laboratorio': 'Q-307',
      },
      
      // Q-312
      {
        'codigo': 'MOCK305',
        'curso': 'Inteligencia Artificial - Mock',
        'dia': 'Martes',
        'horaInicio': '16:00',
        'horaFin': '18:00',
        'laboratorio': 'Q-312',
      },
      
      // R-301
      {
        'codigo': 'MOCK401',
        'curso': 'Redes de Computadoras - Mock',
        'dia': 'Miércoles',
        'horaInicio': '16:00',
        'horaFin': '18:00',
        'laboratorio': 'R-301',
      },
      
      // R-302
      {
        'codigo': 'MOCK402',
        'curso': 'Biología Molecular - Mock',
        'dia': 'Jueves',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'R-302',
      },
      
      // R-303
      {
        'codigo': 'MOCK403',
        'curso': 'Química Orgánica - Mock',
        'dia': 'Viernes',
        'horaInicio': '16:00',
        'horaFin': '18:00',
        'laboratorio': 'R-303',
      },
      
      // R-306
      {
        'codigo': 'MOCK404',
        'curso': 'Desarrollo de Software - Mock',
        'dia': 'Lunes',
        'horaInicio': '08:00',
        'horaFin': '10:00',
        'laboratorio': 'R-306',
      },
      
      // R-308
      {
        'codigo': 'MOCK405',
        'curso': 'Arquitectura de Computadoras - Mock',
        'dia': 'Martes',
        'horaInicio': '10:00',
        'horaFin': '12:00',
        'laboratorio': 'R-308',
      },
    ];
  }

  /// Obtiene una lista de todos los códigos de laboratorio disponibles
  static List<String> getAllLabCodes() {
    return [
      'LAB A',
      'LAB B',
      'LAB C',
      'LAB D',
      'LAB E',
      'LAB F',
      'P-301',
      'P-306',
      'P-307',
      'P-310',
      'P-312A',
      'P-312B',
      'Q-301A',
      'Q-301B',
      'Q-303',
      'Q-307',
      'Q-312',
      'R-301',
      'R-302',
      'R-303',
      'R-306',
      'R-308',
    ];
  }

  /// Obtiene un horario mock para un laboratorio específico
  static Map<String, dynamic>? getScheduleForLab(String labCode) {
    final schedule = getMockSchedule();
    try {
      return schedule.firstWhere(
        (item) => item['laboratorio'] == labCode,
      );
    } catch (e) {
      return null;
    }
  }
}
