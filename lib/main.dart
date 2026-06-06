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
      title: 'インサイダークイズゲーム',
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

  // ゲーム状態管理用
  final List<String> _playerNames = []; 
  List<String> _roles = []; 
  int _currentCheckingPlayer = 0; 
  bool _isRoleRevealed = false; 
  String _currentThemeWord = ''; 
  String _gmPlayerName = ''; 

  // タイマー用
  Timer? _timer;
  int _secondsRemaining = 300;
  bool _isTimeUp = false; 

  // 💡 お題データベース（辛口は前半の250問がここに並びます！）
  static const Map<String, List<String>> _wordDatabase = {
    '甘口': [
      'りんご', '学校', 'いぬ', 'YouTube', 'くるま', 'カレーライス', 'スマートフォン',
      'えんぴつ', 'ねこ', 'テレビ', '自転車', 'ハンバーグ', 'お風呂', '公園',
      'ハサミ', 'バナナ', '時計', 'メガネ', 'コンビニ', 'おにぎり', '傘',
      '冷蔵庫', 'すべり台', '教科書', 'ラーメン', '帽子', '靴下', '新幹線',
      'ドラえもん', 'トイレ', 'ぬいぐるみ', 'ピアノ', 'チョコレート', '水族館', '消しゴム'
    ],
    '辛口': [
      // 1. 生き物
      'ライオン', 'クジラ', 'ペンギン', 'カメレオン', 'カブトムシ', 'キリン', 'フラミンゴ', 'タコ', 'カンガルー', 'チーター',
      // 2. 職業
      '警察官', '裁判官', '美容師', '宇宙飛行士', '探偵', '総理大臣', '弁護士', '料理人', '学校の先生', '消防士',
      // 3. 電化製品
      '電子レンジ', 'お掃除ロボット', '空気清浄機', '加湿器', '食器洗い機', 'ドライヤー', '懐中電灯', '掃除機', 'トースター', '電気ケトル',
      // 4. 年中行事
      'クリスマス', 'お正月', 'ハロウィン', '初詣', '成人式', 'お中元', 'バレンタイン', '大掃除', '模様替え', '結婚式',
      // 5. スポーツ
      '野球', 'サッカー', 'ボウリング', 'ゴルフ', 'カバディ', 'スキー', '縄跳び', '剣道', '卓球', 'バドミントン',
      // 6. 乗り物
      '飛行機', '潜水艦', '満員電車', 'パトカー', '救急車', 'タクシー', '一輪車', 'ヘリコプター', 'キャンピングカー', '人力車',
      // 7. 場所・施設
      'サービスエリア', '映画館', '美術館', '博物館', '動物園', '植物園', '遊園地', 'ライブハウス', 'スタジアム', 'ゲームセンター',
      // 8. 暮らしの道具
      'ガムテープ', 'クリップ', 'クリアファイル', 'ホッチキス', 'カッターナイフ', '付箋', '蛍光ペン', 'シャープペンシル', 'ボールペン', '接着剤',
      // 9. デジタル・IT
      'プログラミング', 'クラウド', 'キャッシュレス', 'Wi-Fiルーター', 'スマートウォッチ', 'フリマアプリ', '電子マネー', 'セルフレジ', '通信制限', 'モバイルバッテリー',
      // 10. ビジネス・仕事
      '確定申告', '履歴書', '自己紹介', '給料明細', 'ボーナス', 'アルバイト', '時給', '定休日', '領収書', '取扱説明書',
      // 11. 学校生活
      '修学旅行', '文化祭', '健康診断', '忘れ物', '落とし物', '遠足', '居眠り', '遅刻', '言い訳', '体育祭',
      // 12. 人間の感情・関係
      '初恋', '友情', 'ジェラシー', '反省', '裏切り', '一目惚れ', '緊張', '反抗期', '勘違い', '片思い',
      // 13. 日常のトラブル
      '渋滞', 'ネット炎上', 'ドッキリ', 'ハプニング', 'ブラックリスト', 'リバウンド', 'スランプ', '口コミ', '迷子', '肌荒れ',
      // 14. 抽象的な概念
      '空気', '影', '誕生日', '時差', '重力', 'うわさ', '睡眠', 'ダイエット', '嘘', '秘密',
      // 15. 住まい・暮らし
      'カプセルホテル', '駐輪場', '宅配ボックス', 'インターホン', '換気扇', '給湯器', '床暖房', 'ソファーベッド', 'ハンガーラック', '物干し竿',
      // 16. キッチン・食生活
      'マヨネーズ', 'インスタントラーメン', 'タピオカ', '保冷剤', '輪ゴム', 'アルミホイル', 'キッチンペーパー', 'ラップ', 'ジップロック', 'ミトン',
      // 17. 遊び・娯楽
      'じゃんけん', 'お年玉', '宿題', '留守番', '一人暮らし', 'リフォーム', '引っ越し', '模様替え', '回覧板', 'お土産',
      // 18. メディア・流行
      'テレビ番組', 'ニュース番組', 'アニメ映画', '週刊誌', 'ベストセラー', 'テレビCM', 'ラジオ放送', '新聞勧誘', '電子書籍', '動画配信',
      // 19. 街・インフラ
      '歩行者天国', 'コインパーキング', 'ドライブスルー', '地下鉄', '交番', '郵便ポスト', '改札口', '歩道橋', '踏切', '信号機',
      // 20. 医療・健康
      '診療所', '保健室', '診察券', '保険証', '体温計', 'コンタクトレンズ', '歯ブラシ', 'マウスウォッシュ', 'カミソリ', '爪切り',
      // 21. 文房具・オフィス
      '修正テープ', '画用紙', 'セロハンテープ', '電卓', '定規', 'コンパス', '虫眼鏡', '地球儀', 'ハンコ', '名刺入れ',
      // 22. ファッション・美容
      '試着室', '美容院', '床屋', 'コインランドリー', 'サングラス', 'マスク', '手帳型スマホケース', 'ハンドクリーム', 'リップクリーム', '香水',
      // 23. 衣類・身の回り
      'レインコート', '日傘', 'キーケース', '小銭入れ', 'エコバッグ', 'キャリーケース', 'リュックサック', 'ビジネスバッグ', '折りたたみ傘', 'サポーター',
      // 24. 救急・防災
      '非常口', '火災報知器', 'ドライブレコーダー', '防犯カメラ', '避難訓練', '消火器', '非常食', '防犯ブザー', '救命胴衣', '防災頭巾',
      // 25. 趣味・アウトドア
      'バーベキューコンロ', 'クーラーボックス', 'タンブラー', 'コーヒーミル', 'キャンプ飯', '天体観測', 'フィッシング', '登山届', 'ハンモック', '寝袋'
      // 💡 26〜50テーマ目は次の出力で完全に合流させます！
    // 26. ネット・SNS（オリジナル）
      'インフルエンサー', 'タイムライン', 'アカウント', 'ハッシュタグ', 'バズ', 'ミュート', 'ブロック', 'ダイレクトメッセージ', 'トレンド動画', 'ライブ配信',
      // 27. 時間・タイミング（オリジナル）
      '時間', 'うるう年', '午前零時', '一等賞', '五分前行動', '門限', 'タイムマシン', '三日坊主', '遅刻', 'フライング',
      // 28. お金・経済（オリジナル）
      'お小遣い', '貯金箱', 'お年玉', 'キャッシュレス', '一万円札', '割り勘', '家賃', '手数料', 'ポイント還元', 'お会計',
      // 29. 学校生活・行事（オリジナル）
      '給食', '校庭', '保健室', '職員室', '塾', '居眠り', 'サボり', '追試', '席替え', '通知表',
      // 30. 人間の感情・関係（オリジナル）
      'ジェラシー', '一目惚れ', '幼馴染', '片思い', '内緒話', '大喧嘩', '仲直り', '裏切り', '親友', '初対面',
      // 31. エンタメ・遊び（オリジナル）
      '罰ゲーム', '一発芸', 'ドッキリ', '都市伝説', 'じゃんけん', 'トランプ', 'オセロ', '将棋', '囲碁', 'パズル',
      // 32. 日常のトラブル（オリジナル）
      'ネット炎上', 'スランプ', 'リバウンド', 'ハプニング', 'ブラックリスト', '口コミ', '迷子', '肌荒れ', '寝坊', '二日酔い',
      // 33. ちょっと怪しい概念（オリジナル）
      '既視感', 'うわさ', '嘘', '秘密', '迷信', '偶然', '奇跡', '予言', '言い訳', '勘違い',
      // 34. 天体・自然
      '流れ星', '満月', '三日月', '日食', 'オーロラ', '星座', '彗星', '天の川', '火山', '砂漠',
      // 35. 衣服・ファッション
      'スニーカー', 'ジーンズ', 'スーツ', 'パジャマ', 'ネクタイ', 'ドレス', 'ユニフォーム', 'レインコート', '水着', 'エプロン',
      // 36. 建造物・モニュメント
      'スカイツリー', '東京タワー', 'ピラミッド', '凱旋門', '大仏', '自由の女神', 'お城', '灯台', 'タワーマンション', '五重塔',
      // 37. 体・健康
      '筋肉', '骨折', '虫歯', '腹痛', '筋肉痛', '視力', '睡眠不足', '肌荒れ', '肩こり', '疲労',
      // 38. メディア・出版
      '週刊誌', '新聞', '教科書', '辞書', '漫画', 'ベストセラー', '図鑑', 'パンフレット', 'カタログ', '論文',
      // 39. 街・交通インフラ
      '交番', '郵便ポスト', '歩道橋', '踏切', '信号機', '電光掲示板', 'コインロッカー', '公衆電話', 'バス停', '空港',
      // 40. 音楽・芸能
      'カラオケ', 'ライブハウス', 'コンサート', 'ミュージシャン', 'アイドル', 'バンド', 'クラシック', 'ロック', 'マイク', 'スピーカー',
      // 41. ゲーム・玩具
      'ルービックキューブ', 'トランプ', '将棋', '麻雀', 'オセロ', 'ぬいぐるみ', 'フィギュア', 'ラジコン', 'ボードゲーム', '水鉄砲',
      // 42. アート・エンタメ
      '映画館', '美術館', '博物館', '遊園地', '動物園', '水族館', 'ボウリング場', 'ライブハウス', 'スタジアム', 'ゲームセンター',
      // 43. 組織・コミュニティ
      '株式会社', 'サークル', '労働組合', 'ファンクラブ', 'ボランティア', '委員会', '市役所', '消防団', 'PTA', '警察署',
      // 44. 国際・時事
      'オリンピック', '万博', '世界遺産', 'ノーベル賞', 'アカデミー賞', 'SDGs', '国連', 'EU', 'NATO', 'WHO（世界保健機関）',
      // 45. 文学・作品
      '源氏物語（紫式部）', '吾輩は猫である（夏目漱石）', '人間失格（太宰治）', '羅生門（芥川龍之介）', '銀河鉄道の夜（宮沢賢治）', '坊っちゃん', '走れメロス', '蜘蛛の糸', '学問のすすめ', '一握の砂',
      // 46. 科学・テクノロジー
      '人工知能', 'ロボット', 'ドローン', '3Dプリンター', '自動運転', 'VR（バーチャルリアリティ）', 'ブロックチェーン', '量子コンピュータ', '宇宙ロケット', '人工衛星',
      // 47. 暮らしのサービス
      'コインランドリー', '自動販売機', '観覧車', 'キャンプ場', '非常口', 'カプセルホテル', '駐輪場', '宅配ボックス', 'セルフレジ', 'Wi-Fiルーター',
      // 48. キッチン・調理器具
      'フライパン', '圧力鍋', 'まな板', '包丁', 'ピーラー', 'おろし金', 'キッチンバサミ', '泡立て器', 'フライ返し', 'おたま',
      // 49. 防災・安全
      '火災報知器', 'ドライブレコーダー', '防犯カメラ', '消火器', '非常食', '防犯ブザー', '救命胴衣', '防災頭巾', '避難はしご', '懐中電灯',
      // 50. 学問・教科
      '歴史', '地理', '数学', '物理', '化学', '生物', '英語', '国語', '哲学', '経済学'
    ],
    '激辛': [
      '資本主義', '帰納法', 'リヴァイアサン', '万人の万人に対する闘争', 'シュレーディンガーの猫', 'パンゲア大陸', 'バタフライエフェクト', 'インフレーション', '相対性理論', '著作権法',
      'パラレルワールド', 'マズローの欲求段階', 'ブロックチェーン', 'プラシーボ効果', 'ベーシックインカム', 'シンギュラリティ', 'フェルマの最終定理', 'アポロ計画', 'フードロス', 'サステナブル',
      'エルニーニョ現象', 'メタバース', 'ビッグデータ', 'クラウドファンディング', '産業革命', 'パレートの法則', '宇宙エレベーター', 'テセウスの船', '囚 prisonersのジレンマ', 'ドップラー効果',
      'マキアヴェリズム', 'パンドラの箱', 'トロッコ問題', 'アキレスと亀', '暗黒物質', '永久機関', 'エントロピー', 'コペルニクス的転回', 'ゲーム理論', 'パレート最適',
      'コモンズの悲劇', '機会費用', '比較優位', 'モラルハザード', '認知バイアス', '同調圧力', 'ハロー効果', 'サンクコスト', 'アンカリング効果', 'プロスペクト理論',
      'コンコルド効果', 'ピグマリオ効果', '弁証法', 'アウフヘーベン', '唯物論', '実存主義', 'パラダイムシフト', '演繹法', '三段論法', 'ア・プリオリ',
      '我思う、ゆえに我あり', '二元論', '功利主義', '最大多数の最大幸福', '社会契約説', '三権分立', 'フランス革命', '人権宣言', 'マグナ・カルタ', '国富論',
      '資本論', '共産党宣言', '冷戦', '鉄のカーテン', 'キューバ危機',
      'ルーブル美術館', 'スーパーカミオカンデ', '田山花袋', 'サグラダ・ファミリア', 'バミューダトライアングル', 'ピカソ', 'レオナルド・ダ・ヴィンチ', 'シェイクスピア', 'マチュピチュ', 'ギザの大ピラミッド',
      'モナ・リザ', 'アンネの日記', 'ロゼッタ・ストーン', 'タージ・マハル', 'ヴェルサイユ宮殿', '万里の長城', 'モアイ像', 'パルテノン神殿', '自由の女神', 'コロッセオ',
      'ストーンヘンジ', 'ナスカの地上絵', 'グランドキャニオン', 'サハラ砂漠', 'アマゾン川', 'マリアナ海溝', 'エベレスト', 'ガラパゴス諸島', 'グレートバリアリーフ', '死海',
      'バチカン市国', 'シリコンバレー', 'ノーベル賞', 'アカデミー賞', 'グラミー賞', 'カンヌ国際映画祭', 'ギネス世界記録', 'ツタンカーメン', 'チンギス・ハン', 'ナポレオン',
      'ジャンヌ・ダルク', 'クレオパトラ', 'アリストテレス', 'ソクラテス', 'ニュートン', 'アインシュタイン', 'エジソン', 'ダーウィン', 'ガリレオ・ガリレイ', 'マリー・キュリー',
      'コロンブス', 'マゼラン', 'マルコ・ポーロ', '坂本龍馬', '織田信長', '徳川家康', '豊臣秀吉', '源氏物語（紫式部）', '松尾芭蕉', '吾輩は猫である（夏目漱石）',
      '人間失格（太宰治）', '羅生門（芥川龍之介）', '銀河鉄道の夜（宮沢賢治）', '手塚治虫', 'ベートーヴェン', 'モーツァルト', 'バッハ', 'ヴィヴァルディ', 'ひまわり（ゴッホ）', 'ミケランジェロ',
      '考える人（ロダン）', 'アンディ・ウォーホル', 'ロミオとジュリエット', 'ハムレット', 'オデッセイ',
      'SDGs', '国際連合', '安全保障理事会', '常任理事国', '拒否権', 'ユネスコ', 'ユニセフ', 'WHO（世界保健機関）', 'IMF（国際通貨基金）', '世界銀行',
      'EU（欧州連合）', 'NATO（北大西洋条約機構）', 'カーボンニュートラル', '排出権取引', '生物多様性', 'ワシントン条約', 'ラムサール条約', '世界遺産条約', '南北問題', '新興国',
      'FTA（自由貿易協定）', 'TPP（環太平洋パートナーシップ協定）', '有価証券報告書', '内部統制', 'コーポレートガバナンス', 'M&A（企業の合併・買収）', 'インサイダー取引', 'ベンチャーキャピタル', '暗号資産', '電子政府',
      'スマートシティ', '地方創生', 'ふるさと納税', '限界集落', 'シャッター街', 'ジェントリフィケーション', 'ドーナツ化現象', 'サマータイム', 'ワークライフバランス', 'プレミアムフライデー',
      'ブラック企業', '終身雇用', '年功序列', '最低賃金', '有効求人倍率', '失業率', 'ベースアップ', '春闘', '労働組合', '派遣社員',
      'テレワーク', 'インフルエンサー', 'バズワード', 'キュレーション', 'フェイクニュース', 'フィルターバブル', 'エコーチェンバー', 'デジタルタトゥー', 'サイバー攻撃', 'フィッシング詐欺',
      'ダークウェブ', '二段階認証', '生体認証', '顔認証', 'ファクトチェック', 'パブリックドメイン', 'オープンソース', 'クリエイティブ・コモンズ', 'インフラストラクチャー',
      'ライフライン', 'ハブ空港', 'LCC（格安航空会社）', 'リニア中央新幹線', '自動運転',
      'オゾン層', '温室効果ガス', '酸性雨', 'マイクロプラスチック', 'ラニーニャ現象', 'ヒートアイランド現象', 'ゲリラ豪雨', '線状降水帯', '異常気象',
      '火山灰', '火砕流', '震度', 'マグニチュード', '津波注意報', '液状化現象', '地盤沈下', 'ISS（国際宇宙ステーション）', 'スペースシャトル',
      'ハッブル宇宙望遠鏡', 'ブラックホール', '事象の地平線', 'ワームホール', 'ビッグバン', 'ダークエネルギー', '超新星爆発', '小惑星', '彗星', '流星群',
      'オーロラ', '太陽フレア', '光年', '天文単位', '天の川銀河', 'アンドロメダ銀河', '人工衛星', 'GPS（全地球測位システム）', '気象衛星', '探査機はやぶさ',
      'DNA（デオキシリボ核酸）', 'ゲノム', '遺伝子組み換え', 'クローン', 'iPS細胞', 'ES細胞', '再生医療', '免疫', 'ワクチン', '抗生物質',
      'ウイルス', '細菌', 'ゲノム編集', 'サプリメント', 'オーガニック', '食物連鎖', '生態系', '外来種', '絶滅危惧種', 'レッドリスト',
      '光合成', '呼吸', '酵素', 'コラーゲン', 'ヒアルロン酸', 'カフェイン', 'ポリフェノール', 'アルコール', '発酵', '酵母',
      '乳酸菌', 'キシリトール', 'カプサイシン', 'タウリン', 'ビタミンC', 'DHA（ドコサヘキサエン酸）', 'サステナブルフード', '培養肉', '昆虫食', '遺伝子検査'
    ],
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
      _isTimeUp = false; 
    });
  }

  void _startTimer() {
    _secondsRemaining = 300;
    _isTimeUp = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() { _secondsRemaining--; });
      } else {
        _timer?.cancel();
        setState(() {
          _isTimeUp = true;
        });
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
                content: const Text('みんなでGMに質問して、お題を当てましょう。クイズ正解者の中に紛れ込んだ「インサイダー」を当てれば庶民の勝ちです。隠れ切れたら「インサイダー」の勝ち!\nスマホ1台をみんなで回して遊びます。'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる'))],
              ),
            );
          },
          child: const Text('ルール確認する', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

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

          if (_useCustomNames) ...[
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 200), 
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
                }, 
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

  Widget _buildDiscussionScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text('GM（親）は $_gmPlayerName です', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 10),
          const Text('GMに「はい／いいえ」で答えられる質問をしてください', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 40),
          
          if (_isTimeUp)
            const Text('⚠️ TIME UP! ⚠️', style: TextStyle(fontSize: 24, color: Colors.redAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            _formatTimeString(_secondsRemaining),
            style: TextStyle(
              fontSize: 80, 
              fontWeight: FontWeight.bold, 
              fontFamily: 'Courier',
              color: _isTimeUp ? Colors.redAccent : Colors.white, 
            ),
          ),
          
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTimeUp ? Colors.orange[800] : Colors.red[700], 
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: _endGame, 
            child: Text(
              _isTimeUp ? '議論終了（結果発表へ）' : 'お題が解けた・議論終了', 
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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