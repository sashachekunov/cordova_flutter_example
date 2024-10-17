import 'package:flutter_module/components/plant_defender_type.dart';

class BulletDamage {
  static int damage(PlantDefenderType plantDefenderType) {
    switch (plantDefenderType) {
      case PlantDefenderType.peas:
        return 8;
      case PlantDefenderType.oats:
        return 12;
      case PlantDefenderType.buckwheat:
        return 20;
      case PlantDefenderType.clover:
        return 20;
    }
  }
}
