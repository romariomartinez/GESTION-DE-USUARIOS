import 'package:uuid/uuid.dart';

abstract class IdGenerator {
  static const _uuid = Uuid();

  static String generate() {
    return _uuid.v4();
  }
}
