# MSS_Match_Plugin
[MelonSoda Server](https://www.melonsoda.tokyo/)で導入しているCS:GO Match Pluginです。  
このプラグイン1つでナイフラウンド、ポーズ、タイムアウト、バックアップラウンド、コーチモード、GOTV無効化、BOT無効化、練習モードの設定が可能です。   
日本語、英語対応  
ご満足いただけた方は[寄付(Donation)](https://www.melonsoda.tokyo/donations.php)のご協力をお願いいたします。

# How to setup
プラグインを利用するには`Metamod:Source`と`SourceMod`を導入する必要があります。  
Clone or DownloadからDownload ZIPをクリックしダウンロードします。   
ダウンロードしたファイルを解凍します。  
`addons/sourcemod`と`cfg`をサーバに保存します。  
以上でセットアップは完了です。  
※ファイルをいじらずにそのままサーバに保存することでMelonSoda Serverと同じ環境にすることができます。

# How to use
チャットから利用できるコマンド一覧（SayCommand）
- `!live`
- - `試合開始`
- `!scrim`
- - `フル30ラウンド`
- `!knife`
- - `ナイフラウンド`
- `!scramble`
- - `スクランブル`
- `!swap`
- - `陣営交換`
- `!pause`
- - `試合一時停止`
- `!unpause`
- - `試合再開`
- `!timeout`
- - `タイムアウト（4times 30sec）`
- `!restart`
- - `ウォームアップ開始`
- `!coach ct`
- - `カウンターテロリストコーチ`
- `!coach t`
- - `テロリストコーチ`
- `!nogotv`
- - `GOTV・DEMO録画停止`
- `!backup`
- - `バックアップラウンド（直前のラウンドのみ）`
- `!nade`
- - `練習モードのオン・オフ`
  
コンソールから利用できるコマンド一覧（ConsoleCommand）
- `admin_backup "任意のラウンド数"`
- - `直前ラウンド以外のロールックが必要な際に利用（サーバクラッシュや直前ラウンドが過ぎてしまった場合など）`

# Convars
Convarを変更してコマンドの制限をすることができます。  
変更する場合には`cfg`にある`mss_match_plugin.cfg`を編集します。  
- `mss_printchat_name`
- - Default: `MSS`
- - Description: `プラグイン表示名の変更`
- `mss_match_config`
- - Default: `esl5on5.cfg`
- - Description: `マッチコンフィグの指定`
- `mss_kniferound_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `ナイフラウンドの有効化`
- `mss_kniferound_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `ナイフラウンドの有効化`
- `mss_timeout_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `タイムアウトの有効化`
- `mss_backupround_enable`
- - Enable(Voting): `1`
- - Enable(forceing): `2`
- - Disable: `0`
- - Description: `バックアップラウンドの有効化`
- `mss_bot_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `ボットの無効化`
- `mss_gotvkick_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `GOTVの無効化`
- `mss_nade_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `練習モードの有効化`
