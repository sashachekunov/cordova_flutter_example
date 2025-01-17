import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_module/animation_state_types/spell_type.dart';
import 'package:flutter_module/plants_vs_invaders.dart';

class Potion extends SpriteComponent with HasGameRef<PlantsVsInvaders> {
  final SpellType spellType;

  late final Timer hideTimer;
  late final double hideTimerSeconds = 7;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  Potion({
    required this.spellType,
    required position,
    required size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() async {
    sprite = await _sprite(spellType, 32);
    hideTimer = Timer(hideTimerSeconds);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      hideTimer.update(fixedDeltaTime);
      if (hideTimer.finished) {
        switch (spellType) {
          case SpellType.circleYellowPotion:
          case SpellType.circleRedPotion:
          case SpellType.rectYellowPotion:
          case SpellType.rectRedPotion:
            removeFromParent();
            break;
          case SpellType.circleBluePotion:
          case SpellType.rectBluePotion:
          default:
            break;
        }
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  Future<Sprite> _sprite(SpellType spellType, int size) async {
    switch (spellType) {
      case SpellType.circleBluePotion:
        final image = await Flame.images.load("levels/potions/circle/circle_blue_potion_$size.png");
        return Sprite(image);
      case SpellType.circleYellowPotion:
        final image = await Flame.images.load("levels/potions/circle/circle_yellow_potion_$size.png");
        return Sprite(image);
      case SpellType.circleRedPotion:
        final image = await Flame.images.load("levels/potions/circle/circle_red_potion_$size.png");
        return Sprite(image);
      case SpellType.rectBluePotion:
        final image = await Flame.images.load("levels/potions/rect/rect_blue_potion_$size.png");
        return Sprite(image);
      case SpellType.rectYellowPotion:
        final image = await Flame.images.load("levels/potions/rect/rect_yellow_potion_$size.png");
        return Sprite(image);
      case SpellType.rectRedPotion:
        final image = await Flame.images.load("levels/potions/rect/rect_red_potion_$size.png");
        return Sprite(image);
    }
  }
}
