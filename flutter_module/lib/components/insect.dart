import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/animation_state_types/character_bar_colors.dart';
import 'package:flutter_module/animation_state_types/insect_animation_state_type.dart';
import 'package:flutter_module/animation_state_types/player_action_type.dart';
import 'package:flutter_module/animation_state_types/player_animation_state_type.dart';
import 'package:flutter_module/animation_state_types/player_direction.dart';
import 'package:flutter_module/animation_state_types/spell_type.dart';
import 'package:flutter_module/components/character_bar.dart';
import 'package:flutter_module/components/collision_block.dart';
import 'package:flutter_module/components/end_game_block.dart';
import 'package:flutter_module/components/insects_types.dart';
import 'package:flutter_module/components/plane_cloud.dart';
import 'package:flutter_module/components/plant_defender.dart';
import 'package:flutter_module/components/potion.dart';
import 'package:flutter_module/components/sprite_frame.dart';
import 'package:flutter_module/components/utils.dart';
import 'package:flutter_module/plants_vs_invaders.dart';

class Insect extends SpriteAnimationGroupComponent with HasGameRef<PlantsVsInvaders>, CollisionCallbacks {
  VoidCallback? endGameCallback;

  Insect({
    required this.insectsType,
    required position,
    required size,
    this.endGameCallback,
  }) : super(
          key: ComponentKey.unique(),
          position: position,
          size: size,
        );

  late final RectangleHitbox hitbox;

  final int damage = 20;
  bool gotHit = false;
  bool attackPlant = false;
  double totalHealth = 100;
  double health = 100;
  late CharacterBar characterBar;

  final InsectsTypes insectsType;
  final double animationStepTime = 0.1;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hitAnimation;

  double horizontalMovement = -1;
  double moveSpeed = 30;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  late TimerComponent attackTimer;

  bool isInCloud = false;

  @override
  FutureOr<void> onLoad() async {
    await _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
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
    switch (insectsType) {
      case InsectsTypes.colorado_beetle:
        idleAnimation = await _spriteAnimation(InsectsTypes.colorado_beetle, 'idle', 1);
        runAnimation = await _spriteAnimation(InsectsTypes.colorado_beetle, 'run', 10);
        attackAnimation = await _spriteAnimation(InsectsTypes.colorado_beetle, 'attack', 10);
        hitAnimation = await _spriteAnimation(InsectsTypes.colorado_beetle, 'hit', 1);
        break;
      case InsectsTypes.mole:
        idleAnimation = await _spriteAnimation(InsectsTypes.mole, 'idle', 1);
        runAnimation = await _spriteAnimation(InsectsTypes.mole, 'run', 10);
        attackAnimation = await _spriteAnimation(InsectsTypes.mole, 'attack', 10);
        hitAnimation = await _spriteAnimation(InsectsTypes.mole, 'hit', 1);
        break;
      case InsectsTypes.mole_cricket:
        idleAnimation = await _spriteAnimation(InsectsTypes.mole_cricket, 'idle', 1);
        runAnimation = await _spriteAnimation(InsectsTypes.mole_cricket, 'run', 1);
        attackAnimation = await _spriteAnimation(InsectsTypes.mole_cricket, 'attack', 1);
        hitAnimation = await _spriteAnimation(InsectsTypes.mole_cricket, 'hit', 1);
        break;
      case InsectsTypes.slug:
        idleAnimation = await _spriteAnimation(InsectsTypes.slug, 'idle', 1);
        runAnimation = await _spriteAnimation(InsectsTypes.slug, 'run', 10);
        attackAnimation = await _spriteAnimation(InsectsTypes.slug, 'attack', 10);
        hitAnimation = await _spriteAnimation(InsectsTypes.slug, 'hit', 1);
        break;
    }

    animations = {
      InsectAnimationStateType.idle: idleAnimation,
      InsectAnimationStateType.run: runAnimation,
      InsectAnimationStateType.attack: attackAnimation,
      InsectAnimationStateType.hit: hitAnimation,
    };

    current = InsectAnimationStateType.idle;
  }

  void _addHitBox() {
    switch (insectsType) {
      case InsectsTypes.colorado_beetle:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case InsectsTypes.mole:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case InsectsTypes.mole_cricket:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
      case InsectsTypes.slug:
        hitbox = RectangleHitbox(
          position: Vector2(70, 0),
          size: Vector2(125, 130),
        );
        break;
    }

    add(hitbox);
  }

  Future<SpriteAnimation> _spriteAnimation(InsectsTypes insectsType, String action, int amount) async {
    final image = await Flame.images.load("levels/insects/${insectsType.name}/${insectsType.name}_$action.png");
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
    if (attackPlant) {
      current = InsectAnimationStateType.attack;
    } else {
      current = InsectAnimationStateType.run;
    }
  }

  void _updateMovement(double dt) {
    if (!attackPlant) {
      velocity.x = horizontalMovement * moveSpeed;
      position.x += velocity.x * dt;
    }
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
    if (other is EndGameBlock) {
      endGameCallback?.call();
    }
    if (other is PlantDefender) {
      if (!attackPlant) {
        attackPlant = true;
        attackTimer = TimerComponent(
            period: 2,
            repeat: true,
            autoStart: true,
            onTick: () {
              other.hit(damage);
            });
        add(attackTimer);
      }
    }
    if (other is PlaneCloud) {
      if (!isInCloud) {
        isInCloud = true;
        switch (other.spellType) {
          case SpellType.circleBluePotion:
            applyCircleBluePotion(other.spellType);
            break;
          case SpellType.circleYellowPotion:
            applyCircleYellowPotion(other.spellType);
            break;
          case SpellType.circleRedPotion:
            applyCircleRedPotion(other.spellType);
            break;
          default:
            break;
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionBlock) {}
    if (other is PlantDefender) {
      attackPlant = false;
      attackTimer.removeFromParent();
    }
    if (other is PlaneCloud) {
      isInCloud = false;
    }
    super.onCollisionEnd(other);
  }

  void hit(int damage) {
    const hitDuration = Duration(milliseconds: 150);
    const canMoveDuration = Duration(milliseconds: 200);
    gotHit = true;
    current = InsectAnimationStateType.hit;
    health -= damage;
    if (health <= 0) {
      gotHit = false;
      position = Vector2(-2000, -2000);
      hitbox.collisionType = CollisionType.inactive;
      removeFromParent();
    }
    _updateCharacterBar();

    Future.delayed(hitDuration, () {
      velocity = Vector2.zero();
      _updateAnimationStateType();
      Future.delayed(canMoveDuration, () => gotHit = false);
    });
  }

  void applyCircleBluePotion(SpellType spellType) {
    final resultMoveSpeed = moveSpeed - moveSpeed * 0.3;
    if (resultMoveSpeed > 0) {
      moveSpeed = resultMoveSpeed;
    }
    _addPotionIcon(spellType);
  }

  void applyCircleYellowPotion(SpellType spellType) {
    totalHealth -= totalHealth * 0.2;
    health -= health * 0.2;
    _updateCharacterBar();
    _addPotionIcon(spellType);
  }

  void applyCircleRedPotion(SpellType spellType) {
    _addPotionIcon(spellType);
    removeFromParent();
  }

  void _addPotionIcon(SpellType spellType) {
    add(Potion(
      spellType: spellType,
      position: Vector2(130, -15),
      size: Vector2.all(70),
    ));
  }
}
