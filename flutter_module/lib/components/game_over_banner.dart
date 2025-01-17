import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter_module/components/game_over_type.dart';
import 'package:flutter_module/plants_vs_invaders.dart';

class GameOverBanner extends PositionComponent with HasGameRef<PlantsVsInvaders> {
  final GameOverType gameOverType;
  VoidCallback completed;

  GameOverBanner({
    required this.gameOverType,
    required this.completed,
    required position,
    required size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = 10000;
    _addText();
    return super.onLoad();
  }

  void _addText() {
    String text = '';
    switch (gameOverType) {
      case GameOverType.victory:
        text = 'Победа!';
        break;
      case GameOverType.defeat:
        text = 'Поражение';
        break;
    }

    final regular = TextPaint(
        style: const TextStyle(
      fontFamily: 'RubikBubbles',
      fontSize: 120,
      color: Color(0xFFFF5726),
    ));

    final textComponent = TextComponent(
      text: text,
      textRenderer: regular,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );

    add(textComponent);

    Future.delayed(const Duration(seconds: 5), () => completed.call());
  }
}
