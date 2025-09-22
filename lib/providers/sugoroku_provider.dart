import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// 双六の状態クラス
class SugorokuState {
  final int playerPosition;
  final int diceResult;
  final bool isDiceRolling;
  final bool showDiceResult;
  final bool isGoalReached;
  final bool showGoalCelebration;
  final int totalSquares;

  const SugorokuState({
    this.playerPosition = 0,
    this.diceResult = 1,
    this.isDiceRolling = false,
    this.showDiceResult = false,
    this.isGoalReached = false,
    this.showGoalCelebration = false,
    this.totalSquares = 20,
  });

  SugorokuState copyWith({
    int? playerPosition,
    int? diceResult,
    bool? isDiceRolling,
    bool? showDiceResult,
    bool? isGoalReached,
    bool? showGoalCelebration,
    int? totalSquares,
  }) {
    return SugorokuState(
      playerPosition: playerPosition ?? this.playerPosition,
      diceResult: diceResult ?? this.diceResult,
      isDiceRolling: isDiceRolling ?? this.isDiceRolling,
      showDiceResult: showDiceResult ?? this.showDiceResult,
      isGoalReached: isGoalReached ?? this.isGoalReached,
      showGoalCelebration: showGoalCelebration ?? this.showGoalCelebration,
      totalSquares: totalSquares ?? this.totalSquares,
    );
  }
}

// 双六のNotifier
class SugorokuNotifier extends StateNotifier<SugorokuState> {
  SugorokuNotifier() : super(const SugorokuState());
  
  final Random _random = Random();

  // サイコロを振る
  Future<void> rollDice() async {
    if (state.isDiceRolling || state.isGoalReached) return;

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
    }
  }

  // ゲームをリセット
  void resetGame() {
    state = const SugorokuState();
  }

  // プレイヤーの位置を直接設定（デバッグ用）
  void setPlayerPosition(int position) {
    if (position >= 0 && position < state.totalSquares) {
      state = state.copyWith(playerPosition: position);
    }
  }
}

// Provider
final sugorokuProvider = StateNotifierProvider<SugorokuNotifier, SugorokuState>((ref) {
  return SugorokuNotifier();
});
