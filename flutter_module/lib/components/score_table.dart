import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/text.dart';
import 'package:flutter_module/plants_vs_invaders.dart';

class ScoreTable extends SpriteComponent with HasGameRef<PlantsVsInvaders> {
  final int sunResources;
  final int energyResources;

  ScoreTable({
    required this.sunResources,
    required this.energyResources,
    required position,
    required size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() async {
    final image = await Flame.images.load("levels/score_table/score_table.png");
    sprite = Sprite(image);
    _addResources(sun: 200, energy: 100);
    return super.onLoad();
  }

  void _addResources({required int sun, required int energy}) {
    final sunTextStyle = TextPaint(
        style: const TextStyle(
      fontFamily: 'RubikBubbles',
      fontSize: 34,
      color: Color(0xFFAC590D),
    ));

    final energyTextStyle = TextPaint(
        style: const TextStyle(
      fontFamily: 'RubikBubbles',
      fontSize: 34,
      color: Color(0xFF726C60),
    ));

    final sunTextComponent = TextComponent(
      text: sunResources.toString(),
      textRenderer: sunTextStyle,
      anchor: Anchor.topLeft,
      position: Vector2(250, 110),
    );

    final energyTextComponent = TextComponent(
      text: energyResources.toString(),
      textRenderer: energyTextStyle,
      anchor: Anchor.topLeft,
      position: Vector2(250, 165),
    );

    add(sunTextComponent);
    add(energyTextComponent);
  }
}
