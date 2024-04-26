import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacescape/game/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/widgets.dart';

import '../widgets/overlays/pause_menu.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/game_over_menu.dart';

import '../models/player_data.dart';
import '../models/spaceship_details.dart';

import 'enemy.dart';
import 'health_bar.dart';
import 'player.dart';
import 'bullet.dart';
import 'command.dart';
import 'power_ups.dart';
import 'enemy_manager.dart';
import 'power_up_manager.dart';
import 'audio_player_component.dart';
import 'database.dart';



class SpacescapeGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final World world = World();

  late CameraComponent primaryCamera;

  late Player _player;

  late SpriteSheet spriteSheet;

  late EnemyManager _enemyManager;

  late PowerUpManager _powerUpManager;

  late TextComponent _playerScore;

  
  late TextComponent _playerHighScore;

  late TextComponent _playerHealth;

  late AudioPlayerComponent _audioPlayerComponent;

  late Database db;

  final _commandList = List<Command>.empty(growable: true);

  final _addLaterCommandList = List<Command>.empty(growable: true);

  bool _isAlreadyLoaded = false;


  Vector2 fixedResolution = Vector2(540, 960);



  Future<int> getHighScore() async {
    final Database db = await DatabaseHelper.instance.database;

    // Запрос к базе данных для получения значения high_score
    final List<Map<String, dynamic>> result = await db.query(
      'game_data', // Имя таблицы
      columns: ['high_score'], // Список столбцов, которые нужно вернуть
      limit: 1, // Ограничение количества результатов (в этом случае 1)
    );

    // Если результат не пустой, возвращаем значение high_score
    if (result.isNotEmpty) {
      return result.first['high_score'] as int;
    } else {
      // Если результат пустой, возвращаем 0 (или другое значение по умолчанию)
      return 0;
    }
  }


  @override
  Future<void> onLoad() async {
    try {
      db = await DatabaseHelper.instance.database;
    }
    catch (error) {
      print('An error occurred: $error');
    }



    if (!_isAlreadyLoaded) {

      await images.loadAll([
        'simpleSpace_tilesheet@2.png',
        'freeze.png',
        'icon_plusSmall.png',
        'multi_fire.png',
        'nuke.png',
      ]);

      spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('simpleSpace_tilesheet@2.png'),
        columns: 8,
        rows: 6,
      );


      await add(world);


      final joystick = JoystickComponent(
        anchor: Anchor.bottomLeft,
        position: Vector2(30, fixedResolution.y - 30),
        // size: 100,
        background: CircleComponent(
          radius: 60,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
        ),
        knob: CircleComponent(radius: 30),
      );

      primaryCamera = CameraComponent.withFixedResolution(
        world: world,
        width: fixedResolution.x,
        height: fixedResolution.y,
        hudComponents: [joystick],
      )..viewfinder.position = fixedResolution / 2;
      await add(primaryCamera);

      _audioPlayerComponent = AudioPlayerComponent();
      final staticStars = await ParallaxComponent.load(
        [ParallaxImageData('fon.png')],
        repeat: ImageRepeat.repeat,
        baseVelocity: Vector2.zero(),
        size: fixedResolution,
      );

      final movingStars = await ParallaxComponent.load(
        [ParallaxImageData('stars2.png')],
        repeat: ImageRepeat.repeat,
        baseVelocity: Vector2(0, -50),
        velocityMultiplierDelta: Vector2(0, 1.5),
        size: fixedResolution,
      );




      const spaceshipType = SpaceshipType.canary;
      final spaceship = Spaceship.getSpaceshipByType(spaceshipType);

      _player = Player(
        joystick: joystick,
        spaceshipType: spaceshipType,
        sprite: spriteSheet.getSpriteById(spaceship.spriteId),
        size: Vector2(64, 64),
        position: fixedResolution / 2,
      );

      _player.anchor = Anchor.center;

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      _powerUpManager = PowerUpManager();

      final button = ButtonComponent(
        button: CircleComponent(
          radius: 60,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
        ),
        anchor: Anchor.bottomRight,
        position: Vector2(fixedResolution.x - 30, fixedResolution.y - 30),
        onPressed: _player.joystickAction,
      );

      _playerScore = TextComponent(
        text: 'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );


      _playerHealth = TextComponent(
        text: 'Health: 100%',
        position: Vector2(fixedResolution.x - 10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );


      _playerHealth.anchor = Anchor.topRight;


      final healthBar = HealthBar(
        player: _player,
        position: _playerHealth.positionOfAnchor(Anchor.topLeft),
        priority: -1,
      );


      await world.addAll([
        _audioPlayerComponent,
        staticStars,
        movingStars,
        _player,
        _enemyManager,
        _powerUpManager,
        button,
        _playerScore,
        _playerHealth,
        healthBar,
      ]);

      _isAlreadyLoaded = true;
    }
  }

  @override
  void onAttach() {
    if (buildContext != null) {
      final playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      _player.setSpaceshipType(playerData.spaceshipType);
    }
    _audioPlayerComponent.playBgm('9. Space Invaders.wav');
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }


  @override
  void update(double dt) {
    super.update(dt);

    for (var command in _commandList) {
      for (var component in world.children) {
        command.run(component);
      }
    }

    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();
    final playerData = Provider.of<PlayerData>(buildContext!, listen: false);


    if (_player.isMounted) {
      _playerScore.text = 'Score: ${_player.score}';
      playerData.currentScore = _player.score;
      _playerHealth.text = 'Health: ${_player.health}%';

      /// Display [GameOverMenu] when [Player.health] becomes
      /// zero and camera stops shaking.
      // if (_player.health <= 0 && (!camera.shaking)) {
      if (_player.health <= 0) {
        pauseEngine();
        overlays.remove(PauseButton.id);
        overlays.add(GameOverMenu.id);
      }
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }

    super.lifecycleStateChange(state);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }


  void reset() {
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();


    world.children.whereType<Enemy>().forEach((enemy) {
      enemy.removeFromParent();
    });

    world.children.whereType<Bullet>().forEach((bullet) {
      bullet.removeFromParent();
    });

    world.children.whereType<PowerUp>().forEach((powerUp) {
      powerUp.removeFromParent();
    });
  }
}
