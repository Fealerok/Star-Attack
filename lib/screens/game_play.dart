import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:spacescape/widgets/overlays/game_over_menu.dart';

import '../game/game.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/pause_menu.dart';


SpacescapeGame _spacescapeGame = SpacescapeGame();


class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: GameWidget(
          game: _spacescapeGame,
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, SpacescapeGame game) =>
                PauseButton(
                  game: game,
                ),
            PauseMenu.id: (BuildContext context, SpacescapeGame game) =>
                PauseMenu(
                  game: game,
                ),
            GameOverMenu.id: (BuildContext context, SpacescapeGame game) =>
                GameOverMenu(
                  game: game,
                ),
          },
        ),
      ),
    );
  }
}
