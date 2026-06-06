import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const InsiderGameApp());
}

class InsiderGameApp extends StatelessWidget {
  const InsiderGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'インサイダーゲーム風アプリ',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentStep = 0;

  // 設定用
  int _playerCount = 4;
  String _difficulty = '辛口';
  bool _useCustomNames = false; 

  // テキスト入力を監視するためのコントローラーリスト
  List<TextEditingController> _nameControllers = [];

  // ゲーム状態管理用（警告が出ないようにfinalに修正）
  final List<String> _playerNames = []; 
  List<String> _roles = []; 
  int _currentCheckingPlayer = 0; 
  bool _isRoleRevealed = false; 
  String _currentThemeWord = ''; 
  String _gmPlayerName = ''; 

  // タイマー用
  Timer? _timer;
  int _secondsRemaining = 300;

  final Map<String, List<String>> _wordDatabase = {
    '甘口': ['りんご', '学校', 'いぬ', 'YouTube', 'くるま', 'カレーライス', 'スマートフォン'],
    '辛口': ['紙袋', 'キャンプ場', '確定申告', '自動販売機', '観覧車', 'コインランドリー'],
    '激辛': ['キャッサバ', '資本主義', 'シュレーディンガーの猫', 'パンゲア大陸', 'バタフライエフェクト'],
  };

  @override
  void initState() {
    super.initState();
    _updateControllers(); 
  }

  void _updateControllers() {
    _nameControllers = List.generate(_playerCount, (index) {
      String currentText = (index < _nameControllers.length) ? _nameControllers[index].text : '';
      return TextEditingController(text: currentText);
    });
  }

  void _startGame() {
    _playerNames.clear();
    
    for (int i = 0; i < _playerCount; i++) {
      String name = _useCustomNames ? _nameControllers[i].text.trim() : 'プレイヤー ${i + 1}';
      
      if (_useCustomNames && name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プレイヤー ${i + 1} の名前を入力してください（空欄不可）'), backgroundColor: Colors.redAccent),
        );
        return;
      }
      _playerNames.add(name);
    }

    final words = _wordDatabase[_difficulty] ?? ['りんご'];
    _currentThemeWord = words[Random().nextInt(words.length)];

    _roles = List.generate(_playerCount, (index) => '庶民');
    List<int> indexes = List.generate(_playerCount, (index) => index);
    indexes.shuffle();
    
    int gmIndex = indexes[0];
    int insiderIndex = indexes[1];

    _roles[gmIndex] = 'ゲームマスター(GM)';
    _roles[insiderIndex] = 'インサイダー';
    _gmPlayerName = _playerNames[gmIndex]; 

    setState(() {
      _currentStep = 2; 
      _currentCheckingPlayer = 0;
      _isRoleRevealed = false;
    });
  }

  void _startTimer() {
    _secondsRemaining = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() { _secondsRemaining--; });
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() { _currentStep = 4; });
  }

  String _formatTimeString(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.grey[900],
              alignment: Alignment.center,
              child: const Text('広告バナー（上）', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: _buildCurrentScreen(),
                ),
              ),
            ),
            Container(
              height: 60,
              color: Colors.grey[900],
              alignment: Alignment.center,
              child: const Text('広告バナー（下）', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_currentStep == 0) return _buildTitleScreen();
    if (_currentStep == 1) return _buildSettingScreen();
    if (_currentStep == 2) return _buildRoleCheckScreen();
    if (_currentStep == 3) return _buildDiscussionScreen();
    if (_currentStep == 4) return _buildResultScreen();
    return const Text('準備中...');
  }

  // 💡 ステップ1：タイトル画面
  Widget _buildTitleScreen() {
    return Column(
      children: [
        const Text('インサイダーゲーム風\n(仮称)', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 60),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
          onPressed: () => setState(() => _currentStep = 1),
          child: const Text('あそぶ', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('ルール説明'),
                content: const Text('クイズ正解者の中に紛れ込んだ「インサイダー」を見つけ出すゲームです。スマホ1台をみんなで回して遊びます。'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる'))],
              ),
            );
          },
          child: const Text('ルール確認する', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  // 💡 ステップ2：設定画面（修正箇所）
  Widget _buildSettingScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('ゲーム設定', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('参加人数：', style: TextStyle(fontSize: 18)),
              DropdownButton<int>(
                value: _playerCount,
                items: List.generate(7, (index) => index + 4).map((val) => DropdownMenuItem(value: val, child: Text('$val 人'))).toList(),
                onChanged: (val) {
                  setState(() {
                    _playerCount = val!;
                    _updateControllers(); 
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('難易度：', style: TextStyle(fontSize: 18)),
              DropdownButton<String>(
                value: _difficulty,
                items: ['甘口', '辛口', '激辛'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
              ),
            ],
          ),
          const SizedBox(height: 15),

          CheckboxListTile(
            title: const Text('プレイヤー名を設定する', style: TextStyle(fontSize: 16)),
            value: _useCustomNames,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              setState(() {
                _useCustomNames = value!;
                if (_useCustomNames) _updateControllers();
              });
            },
          ),

          // 入力フォーム部分のバグを修正
          if (_useCustomNames) ...[
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 200), // 正しい最大高さの指定方法に修正
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _playerCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                    child: TextField(
                      controller: _nameControllers[index],
                      maxLength: 8, 
                      decoration: InputDecoration(
                        labelText: 'プレイヤー ${index + 1} の名前',
                        counterText: '', 
                        isDense: true,
                      ),
                    ),
                  );
                }, // カッコの閉じ漏れを修正
              ),
            ),
          ],

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('もどる')),
              ElevatedButton(onPressed: _startGame, child: const Text('ゲーム開始')),
            ],
          ),
        ],
      ),
    );
  }

  // 💡 ステップ3：役職確認画面
  Widget _buildRoleCheckScreen() {
    String currentPlayerName = _playerNames[_currentCheckingPlayer];
    String role = _roles[_currentCheckingPlayer];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(currentPlayerName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 10),
          const Text('以外の人は見ないでください', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
          const SizedBox(height: 40),
          if (!_isRoleRevealed) ...[
            const Text('準備はいいですか？', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _isRoleRevealed = true),
              child: const Text('タップして役職を確認'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: role == '庶民' ? Colors.blue[900] : (role == 'インサイダー' ? Colors.red[900] : Colors.green[900]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('あなたの役職は：$role', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (role == 'ゲームマスター(GM)' || role == 'インサイダー')
                    Text('今回のお題：$_currentThemeWord', style: const TextStyle(fontSize: 24, color: Colors.yellow, fontWeight: FontWeight.bold))
                  else
                    const Text('マスターの質問をよく聞いて、お題を推理してください。', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_currentCheckingPlayer < _playerCount - 1) {
                    _currentCheckingPlayer++;
                    _isRoleRevealed = false;
                  } else {
                    _currentStep = 3; 
                    _startTimer(); 
                  }
                });
              },
              child: Text(_currentCheckingPlayer < _playerCount - 1 ? '確認しました（次の人へ）' : '全員確認完了（ゲーム開始！）'),
            ),
          ],
        ],
      ),
    );
  }

  // 💡 ステップ4：議論・タイマー画面
  Widget _buildDiscussionScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text('GM（親）は $_gmPlayerName です', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 10),
          const Text('GMに「はい／いいえ」で答えられる質問をしてください', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 50),
          Text(
            _formatTimeString(_secondsRemaining),
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: _endGame,
            child: const Text('お題が解けた・議論終了', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 💡 ステップ5：結果・答え合わせ画面
  Widget _buildResultScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('ゲーム終了！', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.yellow)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                const Text('正解のお題', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 5),
                Text(_currentThemeWord, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellow)),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                const Text('各プレイヤーの正体', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                ...List.generate(_playerCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('${_playerNames[index]} : ${_roles[index]}', style: const TextStyle(fontSize: 18)),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text('タイトルに戻る'),
          ),
        ],
      ),
    );
  }
}