import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'todo_provider.dart';
import '../models/todo_item.dart';

// 双六の状態クラス
class SugorokuState {
  final int playerPosition;
  final int diceResult;
  final bool isDiceRolling;
  final bool showDiceResult;
  final bool isGoalReached;
  final bool showGoalCelebration;
  final int totalSquares;
  final int remainingRolls; // 残り振れる回数

  const SugorokuState({
    this.playerPosition = 0,
    this.diceResult = 1,
    this.isDiceRolling = false,
    this.showDiceResult = false,
    this.isGoalReached = false,
    this.showGoalCelebration = false,
    this.totalSquares = 20,
    this.remainingRolls = 0,
  });

  SugorokuState copyWith({
    int? playerPosition,
    int? diceResult,
    bool? isDiceRolling,
    bool? showDiceResult,
    bool? isGoalReached,
    bool? showGoalCelebration,
    int? totalSquares,
    int? remainingRolls,
  }) {
    return SugorokuState(
      playerPosition: playerPosition ?? this.playerPosition,
      diceResult: diceResult ?? this.diceResult,
      isDiceRolling: isDiceRolling ?? this.isDiceRolling,
      showDiceResult: showDiceResult ?? this.showDiceResult,
      isGoalReached: isGoalReached ?? this.isGoalReached,
      showGoalCelebration: showGoalCelebration ?? this.showGoalCelebration,
      totalSquares: totalSquares ?? this.totalSquares,
      remainingRolls: remainingRolls ?? this.remainingRolls,
    );
  }
}

// 双六のNotifier
class SugorokuNotifier extends StateNotifier<SugorokuState> {
  final Ref ref;
  SugorokuNotifier(this.ref) : super(const SugorokuState()) {
    // 初期化時に残りロール数を更新
    _updateRemainingRolls();
    // 継続/単発TODOの変更を監視して残りロール数を即時更新
    ref.listen<List<TodoItem>>(continuousTodoProvider, (previous, next) {
      _updateRemainingRolls();
    });
    ref.listen<List<TodoItem>>(singleTodoProvider, (previous, next) {
      _updateRemainingRolls();
    });
  }

  final Random _random = Random();
  int _consumedRolls = 0; // セッション中に既に使った回数

  // サイコロを振る
  Future<void> rollDice() async {
    if (state.isDiceRolling || state.isGoalReached) return;

    // 残りロール数を再計算
    _updateRemainingRolls();
    final allowed = state.remainingRolls;
    if (allowed <= 0) return; // 振れる回数が無ければ何もしない

    // 消費を先に記録して、多重押下を防ぐ
    _consumedRolls += 1;
    _updateRemainingRolls();

    // サイコロ回転開始
    state = state.copyWith(
      isDiceRolling: true,
      showDiceResult: false,
    );

    // サイコロの結果を決定（アニメーション時間を考慮）
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final diceResult = _random.nextInt(6) + 1;
    state = state.copyWith(
      diceResult: diceResult,
      showDiceResult: true,
    );

    // 少し待ってからプレイヤーを移動
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newPosition = state.playerPosition + diceResult;
    final goalPosition = state.totalSquares - 1;
    
    // ゴールに到達またはオーバーした場合
    if (newPosition >= goalPosition) {
      state = state.copyWith(
        playerPosition: goalPosition, // ゴールマスで止める
        isDiceRolling: false,
        isGoalReached: true,
        showGoalCelebration: true,
      );
      
      // 3秒間ゴール演出を表示してからリセット
      await Future.delayed(const Duration(seconds: 3));
      resetGame();
    } else {
      state = state.copyWith(
        playerPosition: newPosition,
        isDiceRolling: false,
      );
        // 移動後に残りロール数を反映
        _updateRemainingRolls();
    }
  }

  // ゲームをリセット
  void resetGame() {
    state = const SugorokuState();
    _consumedRolls = 0;
    _updateRemainingRolls();
  }

  // プレイヤーの位置を直接設定（デバッグ用）
  void setPlayerPosition(int position) {
    if (position >= 0 && position < state.totalSquares) {
      state = state.copyWith(playerPosition: position);
    }
  }

  void _updateRemainingRolls() {
    try {
      final cont = ref.read(continuousTodoProvider);
      final single = ref.read(singleTodoProvider);
      final completed = cont.where((t) => t.isCompleted).length + single.where((t) => t.isCompleted).length;
      final remaining = (completed - _consumedRolls) > 0 ? (completed - _consumedRolls) : 0;
      state = state.copyWith(remainingRolls: remaining);
    } catch (e) {
      // 参照失敗時は変更しない
    }
  }
}

// Provider
final sugorokuProvider = StateNotifierProvider<SugorokuNotifier, SugorokuState>((ref) {
  return SugorokuNotifier(ref);
});
