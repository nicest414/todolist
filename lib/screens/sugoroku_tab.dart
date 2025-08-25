import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sugoroku_provider.dart';

class SugorokuTab extends ConsumerStatefulWidget {
  const SugorokuTab({super.key});

  @override
  ConsumerState<SugorokuTab> createState() => _SugorokuTabState();
}

class _SugorokuTabState extends ConsumerState<SugorokuTab>
    with TickerProviderStateMixin {
  // アニメーション関連の定数
  static const Duration _diceAnimationDuration = Duration(milliseconds: 1500);
  static const Duration _goalAnimationDuration = Duration(milliseconds: 1000);
  static const double _diceSize = 80.0;
  static const double _dotSize = 12.0;
  static const double _playerIconSize = 30.0;
  
  // アニメーションコントローラー
  late AnimationController _diceAnimationController;
  late AnimationController _goalAnimationController;
  
  // アニメーション
  late Animation<double> _diceRotationAnimation;
  late Animation<double> _goalScaleAnimation;
  late Animation<double> _goalOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _diceAnimationController = AnimationController(
      duration: _diceAnimationDuration,
      vsync: this,
    );
    
    _goalAnimationController = AnimationController(
      duration: _goalAnimationDuration,
      vsync: this,
    );
    
    _diceRotationAnimation = Tween<double>(
      begin: 0,
      end: 8 * 3.14159, // 4回転
    ).animate(CurvedAnimation(
      parent: _diceAnimationController,
      curve: Curves.easeOut,
    ));
    
    _goalScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _goalAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _goalOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _goalAnimationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _diceAnimationController.dispose();
    _goalAnimationController.dispose();
    super.dispose();
  }

  // サイコロ関連のメソッド
  void _rollDice() async {
    final sugorokuNotifier = ref.read(sugorokuProvider.notifier);
    
    _diceAnimationController.forward();
    await sugorokuNotifier.rollDice();
    _diceAnimationController.reset();
  }

  Widget _buildDiceDisplay() {
    final sugorokuState = ref.watch(sugorokuProvider);
    
    return sugorokuState.showDiceResult
        ? _buildStaticDice(sugorokuState.diceResult)
        : _buildAnimatedDice();
  }

  Widget _buildAnimatedDice() {
    return AnimatedBuilder(
      animation: _diceRotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _diceRotationAnimation.value,
          child: _buildDiceContainer(
            child: const Text(
              '?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaticDice(int diceResult) {
    return _buildDiceContainer(
      child: _buildDiceFace(diceResult),
    );
  }

  Widget _buildDiceContainer({required Widget child}) {
    return Container(
      width: _diceSize,
      height: _diceSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildDiceFace(int number) {
    final dotPositions = _getDotPositions(number);
    
    return Stack(
      children: dotPositions.map((position) => 
        Positioned(
          top: position.dy,
          left: position.dx,
          child: _buildDot(),
        )
      ).toList(),
    );
  }

  List<Offset> _getDotPositions(int number) {
    const double margin = 15.0;
    const double center = 30.0;
    
    switch (number) {
      case 1:
        return [const Offset(center, center)];
      case 2:
        return [
          const Offset(margin, margin),
          const Offset(_diceSize - margin - _dotSize, _diceSize - margin - _dotSize),
        ];
      case 3:
        return [
          const Offset(margin, margin),
          const Offset(center, center),
          const Offset(_diceSize - margin - _dotSize, _diceSize - margin - _dotSize),
        ];
      case 4:
        return [
          const Offset(margin, margin),
          const Offset(_diceSize - margin - _dotSize, margin),
          const Offset(margin, _diceSize - margin - _dotSize),
          const Offset(_diceSize - margin - _dotSize, _diceSize - margin - _dotSize),
        ];
      case 5:
        return [
          const Offset(margin, margin),
          const Offset(_diceSize - margin - _dotSize, margin),
          const Offset(center, center),
          const Offset(margin, _diceSize - margin - _dotSize),
          const Offset(_diceSize - margin - _dotSize, _diceSize - margin - _dotSize),
        ];
      case 6:
        return [
          const Offset(margin, margin),
          const Offset(_diceSize - margin - _dotSize, margin),
          const Offset(margin, center),
          const Offset(_diceSize - margin - _dotSize, center),
          const Offset(margin, _diceSize - margin - _dotSize),
          const Offset(_diceSize - margin - _dotSize, _diceSize - margin - _dotSize),
        ];
      default:
        return [];
    }
  }

  Widget _buildDot() {
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildGoalCelebration() {
    return AnimatedBuilder(
      animation: _goalAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _goalOpacityAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
            child: Center(
              child: Transform.scale(
                scale: _goalScaleAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '🎉 ゴール！🎉',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'おめでとうございます！',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 24),
                          Icon(Icons.star, color: Colors.amber, size: 24),
                          Icon(Icons.star, color: Colors.amber, size: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // すごろくボード関連のメソッド
  Widget _buildSugorokuBoard() {
    final sugorokuState = ref.watch(sugorokuProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemCount: sugorokuState.totalSquares,
        itemBuilder: (context, index) => _buildSquare(index, sugorokuState),
      ),
    );
  }

  Widget _buildSquare(int index, SugorokuState state) {
    final isPlayerHere = index == state.playerPosition;
    final isStart = index == 0;
    final isGoal = index == state.totalSquares - 1;
    
    return Container(
      decoration: BoxDecoration(
        color: _getSquareColor(isStart, isGoal),
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(child: _buildSquareLabel(index, isStart, isGoal)),
          if (isPlayerHere) _buildPlayerIcon(),
        ],
      ),
    );
  }

  Color _getSquareColor(bool isStart, bool isGoal) {
    if (isStart) return Colors.green[300]!;
    if (isGoal) return Colors.red[300]!;
    return Colors.blue[100]!;
  }

  Widget _buildSquareLabel(int index, bool isStart, bool isGoal) {
    final text = isStart 
        ? 'スタート'
        : isGoal 
            ? 'ゴール'
            : '${index + 1}';
    
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: isStart || isGoal ? 10 : 12,
      ),
    );
  }

  Widget _buildPlayerIcon() {
    return Center(
      child: Container(
        width: _playerIconSize,
        height: _playerIconSize,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // メインビルドメソッド
  @override
  Widget build(BuildContext context) {
    final sugorokuState = ref.watch(sugorokuProvider);
    
    _setupGoalAnimationListener();
    
    return Stack(
      children: [
        _buildMainContent(sugorokuState),
        if (sugorokuState.showGoalCelebration) _buildGoalCelebration(),
      ],
    );
  }

  void _setupGoalAnimationListener() {
    ref.listen<SugorokuState>(sugorokuProvider, (previous, current) {
      if (current.showGoalCelebration && !_goalAnimationController.isAnimating) {
        _goalAnimationController.forward();
      }
      if (!current.showGoalCelebration && _goalAnimationController.isAnimating) {
        _goalAnimationController.stop();
        _goalAnimationController.reset();
      }
    });
  }

  Widget _buildMainContent(SugorokuState state) {
    return Column(
      children: [
        _buildGameInfoCard(state),
        Expanded(child: _buildSugorokuBoard()),
        _buildDiceArea(),
        _buildDiceButton(state),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGameInfoCard(SugorokuState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn('現在位置', '${state.playerPosition + 1}マス目'),
              if (state.showDiceResult)
                _buildInfoColumn('サイコロの目', '${state.diceResult}', Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, [Color? valueColor]) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildDiceArea() {
    return Container(
      height: 120,
      child: Center(child: _buildDiceDisplay()),
    );
  }

  Widget _buildDiceButton(SugorokuState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: (state.isDiceRolling || state.isGoalReached) ? null : _rollDice,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[500],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(_getButtonText(state)),
      ),
    );
  }

  String _getButtonText(SugorokuState state) {
    if (state.isDiceRolling) return 'サイコロを振っています...';
    if (state.isGoalReached) return 'ゲーム終了';
    return 'サイコロを振る';
  }
}
