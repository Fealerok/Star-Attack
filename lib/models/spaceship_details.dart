
import 'package:hive/hive.dart';

part 'spaceship_details.g.dart';

class Spaceship {
  final String name;

  final int cost;

  final double speed;
  final int spriteId;

  final String assetPath;

  final int level;

  const Spaceship({
    required this.name,
    required this.cost,
    required this.speed,
    required this.spriteId,
    required this.assetPath,
    required this.level,
  });

  static Spaceship getSpaceshipByType(SpaceshipType spaceshipType) {
    return spaceships[spaceshipType] ?? spaceships.entries.first.value;
  }

  static const Map<SpaceshipType, Spaceship> spaceships = {
    SpaceshipType.canary: Spaceship(
      name: 'Canary',
      cost: 0,
      speed: 250,
      spriteId: 0,
      assetPath: 'assets/images/ship_A.png',
      level: 1,
    ),
    SpaceshipType.dusky: Spaceship(
      name: 'Dusky',
      cost: 100,
      speed: 400,
      spriteId: 1,
      assetPath: 'assets/images/ship_B.png',
      level: 2,
    ),
    SpaceshipType.condor: Spaceship(
      name: 'Condor',
      cost: 200,
      speed: 300,
      spriteId: 2,
      assetPath: 'assets/images/ship_C.png',
      level: 2,
    ),
  };
}

@HiveType(typeId: 1)
enum SpaceshipType {
  @HiveField(0)
  canary,

  @HiveField(1)
  dusky,

  @HiveField(2)
  condor,

  @HiveField(3)
  cXC,

  @HiveField(4)
  raptor,

  @HiveField(5)
  raptorX,

  @HiveField(6)
  albatross,

  @HiveField(7)
  dK809,
}
