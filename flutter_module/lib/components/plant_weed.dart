import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/animation_state_types/character_bar_colors.dart';
import 'package:flutter_module/animation_state_types/insect_animation_state_type.dart';
import 'package:flutter_module/animation_state_types/plant_animation_state_type.dart';
import 'package:flutter_module/animation_state_types/player_action_type.dart';
import 'package:flutter_module/animation_state_types/player_animation_state_type.dart';
import 'package:flutter_module/animation_state_types/player_direction.dart';
import 'package:flutter_module/components/character_bar.dart';
import 'package:flutter_module/components/collision_block.dart';
import 'package:flutter_module/components/end_game_block.dart';
import 'package:flutter_module/components/insects_types.dart';
import 'package:flutter_module/components/plant.dart';
import 'package:flutter_module/components/plant_defender_type.dart';
import 'package:flutter_module/components/plant_weed_type.dart';
import 'package:flutter_module/components/sprite_frame.dart';
import 'package:flutter_module/components/utils.dart';
import 'package:flutter_module/plants_vs_invaders.dart';

class PlantWeed extends Plant with HasGameRef<PlantsVsInvaders>, CollisionCallbacks {
  final Function(PlantWeed plantWeed, int rowOnBoard, int columnOnBoard) wasKilled;

  PlantWeed({
    required this.plantWeedType,
    required this.rowOnBoard,
    required this.columnOnBoard,
    required this.wasKilled,
    required position,
    required size,
  }) : super(
          isDefender: false,
          position: position,
          size: size,
        );

  late final RectangleHitbox hitbox;

  final PlantWeedType plantWeedType;
  final double animationStepTime = 0.1;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation hitAnimation;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  bool gotHit = false;
  final int totalHealth = 100;
  int health = 100;
  late CharacterBar characterBar;

  final int rowOnBoard;
  final int columnOnBoard;

  @override
  FutureOr<void> onLoad() async {
    await _loadAllAnimations();
    _addHitBox();
    _addCharacterBar();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit) {
        _updateMovement(fixedDeltaTime);
        _updateAnimationStateType();
      }

      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  Future<void> _loadAllAnimations() async {
    switch (plantWeedType) {
      case PlantWeedType.bindweed:
        idleAnimation = await _spriteAnimation(PlantWeedType.bindweed, 'idle', 10);
        hitAnimation = await _spriteAnimation(PlantWeedType.bindweed, 'hit', 1);
        break;
      case PlantWeedType.dandelion:
        idleAnimation = await _spriteAnimation(PlantWeedType.dandelion, 'idle', 1);
        hitAnimation = await _spriteAnimation(PlantWeedType.dandelion, 'hit', 1);
        break;
      case PlantWeedType.hogweed:
        idleAnimation = await _spriteAnimation(PlantWeedType.hogweed, 'idle', 1);
        hitAnimation = await _spriteAnimation(PlantWeedType.hogweed, 'hit', 1);
        break;
      case PlantWeedType.shepherds_purse:
        idleAnimation = await _spriteAnimation(PlantWeedType.shepherds_purse, 'idle', 10);
        hitAnimation = await _spriteAnimation(PlantWeedType.shepherds_purse, 'hit', 1);
        break;
      case PlantWeedType.wheatgrass:
        idleAnimation = await _spriteAnimation(PlantWeedType.wheatgrass, 'idle', 6);
        hitAnimation = await _spriteAnimation(PlantWeedType.wheatgrass, 'hit', 1);
        break;
    }

    animations = {
      PlantAnimationStateType.idle: idleAnimation,
      PlantAnimationStateType.hit: hitAnimation,
    };

    current = PlantAnimationStateType.idle;
  }

  void _addHitBox() {
    switch (plantWeedType) {
      case PlantWeedType.bindweed:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case PlantWeedType.dandelion:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case PlantWeedType.hogweed:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case PlantWeedType.shepherds_purse:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case PlantWeedType.wheatgrass:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
    }

    add(hitbox);
  }

  Future<SpriteAnimation> _spriteAnimation(PlantWeedType plantWeedType, String action, int amount) async {
    final image =
        await Flame.images.load("levels/plants/weeds/${plantWeedType.name}/${plantWeedType.name}_$action.png");
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
    current = PlantAnimationStateType.idle;
  }

  void _updateMovement(double dt) {
    // velocity.x = horizontalMovement * moveSpeed;
    // position.x += velocity.x * dt;
  }

  void _addCharacterBar() {
    characterBar = CharacterBar(
      color: CharacterBarColors.greenFront,
      backgroundColor: CharacterBarColors.greenBack,
      position: Vector2(hitbox.position.x, hitbox.position.y),
      size: Vector2(hitbox.size.x, 5),
      progress: health / totalHealth,
    );
    add(characterBar);
  }

  void _updateCharacterBar() {
    characterBar.removeFromParent();
    characterBar = CharacterBar(
      color: CharacterBarColors.greenFront,
      backgroundColor: CharacterBarColors.greenBack,
      position: Vector2(hitbox.position.x, hitbox.position.y),
      size: Vector2(hitbox.size.x, 5),
      progress: health / totalHealth,
    );
    add(characterBar);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {}
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionBlock) {}
    super.onCollisionEnd(other);
  }

  void hit(int damage) {
    const hitDuration = Duration(milliseconds: 150);
    const canMoveDuration = Duration(milliseconds: 200);
    gotHit = true;
    current = PlantAnimationStateType.hit;
    health -= damage;
    if (health <= 0) {
      gotHit = false;
      position = Vector2(-3000, -3000);
      hitbox.collisionType = CollisionType.inactive;
      removeFromParent();
      wasKilled(this, rowOnBoard, columnOnBoard);
    }
    _updateCharacterBar();

    Future.delayed(hitDuration, () {
      _updateAnimationStateType();
      Future.delayed(canMoveDuration, () => gotHit = false);
    });
  }
}
