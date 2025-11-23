import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/main.dart' as common;

Future<void> main() async {
  await common.mainCommon(Flavor.prod, '.env.prod');
}
