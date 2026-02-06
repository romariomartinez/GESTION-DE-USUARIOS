import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/core/utils/date_utils.dart';

void main() {
  group('calculateAge', () {
    test('retorna 0 para fecha de nacimiento hoy', () {
      final today = DateTime.now();
      expect(calculateAge(today), 0);
    });

    test('retorna 1 para nacido hace más de 1 año', () {
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 400));
      expect(calculateAge(oneYearAgo), 1);
    });

    test('retorna 0 para nacido hace menos de 1 año', () {
      final almostOneYear = DateTime.now().subtract(const Duration(days: 300));
      expect(calculateAge(almostOneYear), 0);
    });

    test('cumpleaños exactos - no resta si es hoy', () {
      final now = DateTime.now();
      final bornToday = DateTime(now.year - 25, now.month, now.day);
      expect(calculateAge(bornToday), 25);
    });
  });
}
