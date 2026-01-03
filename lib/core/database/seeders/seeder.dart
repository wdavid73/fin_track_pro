import 'package:hive/hive.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';

/// Abstract base class for all database seeders
///
/// Provides a contract for seeding data into Hive boxes
/// and helper methods for common seeding operations
abstract class Seeder {
  final LoggerService logger;

  Seeder(this.logger);

  /// The name of this seeder (for logging purposes)
  String get name;

  /// Execute the seeding logic
  ///
  /// This method should be implemented by concrete seeders
  /// to populate their respective data
  Future<void> seed();

  /// Check if a box is empty
  ///
  /// Useful to avoid duplicate seeding
  bool isBoxEmpty(Box box) {
    return box.isEmpty;
  }

  /// Check if a box has data
  bool hasData(Box box) {
    return !isBoxEmpty(box);
  }
}
