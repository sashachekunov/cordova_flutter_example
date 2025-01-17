import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_module/animation_state_types/plane_animation_state_type.dart';
import 'package:flutter_module/plants_vs_invaders.dart';

class PlaneAirForce extends SpriteAnimationGroupComponent with HasGameRef<PlantsVsInvaders> {
  PlaneAirForce({
    required position,
    // required size,
  }) : super(
          position: Vector2(position.x, position.y - 400),
          size: Vector2(1200, 680),
          priority: 1000,
        );

  final double animationStepTime = 0.1;

  late final SpriteAnimation idleAnimation;

  double horizontalMovement = 1;
  double moveSpeed = 500;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() async {
    await _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      _updateMovement(fixedDeltaTime);
      _updateAnimationStateType();

      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  Future<void> _loadAllAnimations() async {
    idleAnimation = await _spriteAnimation('plane', 11);

    animations = {
      PlaneAnimationStateType.idle: idleAnimation,
    };

    current = PlaneAnimationStateType.idle;
  }

  Future<SpriteAnimation> _spriteAnimation(String name, int amount) async {
    final image = await Flame.images.load("levels/plane/$name.png");
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: animationStepTime,
        textureSize: Vector2(960, 540),
      ),
    );
  }

  void _updateAnimationStateType() {
    current = PlaneAnimationStateType.idle;
  }

  void _updateMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    if (position.x > game.gameWidth) {
      removeFromParent();
    }
  }
}
