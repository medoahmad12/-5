import 'package:flutter/material.dart';
import '../data/models.dart';
import '../games/balloons_game.dart';
import '../games/bubbles_game.dart';
import '../games/collect_stars_game.dart';
import '../games/count_feed_game.dart';
import '../games/drag_match_game.dart';
import '../games/find_scene_game.dart';
import '../games/listen_choose_game.dart';
import '../games/match_case_game.dart';
import '../games/memory_game.dart';
import '../games/odd_one_game.dart';
import '../games/pattern_game.dart';
import '../games/train_order_game.dart';

/// Routes a lesson to the right game engine and adapts difficulty:
/// later lessons and repeated plays use slightly larger option counts.
class GameHost extends StatelessWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final GameType type;
  final List<UnitDef>? reviewPool;
  final ValueChanged<GameResult> onDone;

  const GameHost({
    super.key,
    required this.subject,
    required this.unit,
    required this.type,
    this.reviewPool,
    required this.onDone,
  });

  int get _difficulty => 1;

  @override
  Widget build(BuildContext context) {
    final base = (
      subject: subject,
      unit: unit,
      onDone: onDone,
      difficulty: _difficulty,
    );

    switch (type) {
      case GameType.listenChoose:
        return ListenChooseGame(
          subject: base.subject,
          unit: base.unit,
          pool: reviewPool ?? subject.units,
          difficulty: base.difficulty,
          onDone: base.onDone,
        );
      case GameType.dragMatch:
        return DragMatchGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
      case GameType.matchCase:
        return MatchCaseGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
      case GameType.memory:
        return MemoryGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          pairs: 3,
          onDone: base.onDone,
        );
      case GameType.countFeed:
        return CountFeedGame(
          subject: base.subject,
          unit: base.unit,
          onDone: base.onDone,
        );
      case GameType.balloons:
        return BalloonsGame(
          subject: base.subject,
          unit: base.unit,
          onDone: base.onDone,
        );
      case GameType.bubblesV:
        return BubblesGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
      case GameType.collectStars:
        return CollectStarsGame(
          subject: base.subject,
          unit: base.unit,
          onDone: base.onDone,
        );
      case GameType.trainOrder:
        return TrainOrderGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
      case GameType.oddOne:
        return OddOneGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
      case GameType.findScene:
        return FindSceneGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
      case GameType.pattern:
        return PatternGame(
          subject: base.subject,
          unit: base.unit,
          pool: subject.units,
          onDone: base.onDone,
        );
    }
  }
}
