# MSS_Match_Plugin
[MelonSoda Server](https://www.melonsoda.tokyo/)で導入しているCS:GO Match Pluginです。  

バージョン1.2.0より[MSS_Demo_Record_Plugin](https://github.com/MelonSoda0716/MSS_Demo_Record_Plugin)と[MSS_Map_Changer_Plugin](https://github.com/MelonSoda0716/MSS_Map_Changer_Plugin)の機能を包括しています。  

このプラグイン1つでナイフラウンド、ポーズ、タイムアウト、バックアップラウンド、コーチモード、DEMO録画、マップチェンジャー、GOTV無効化、BOT無効化、簡易的な練習モードの設定が可能です。   
現在、日本語、英語に対応しています。  

[寄付(Donation)](https://www.melonsoda.tokyo/donation.php)のご協力をお願いいたします。

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
- `!30r`
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
- `mss_warmup_infinite_money`
- - Enable: `1`
- - Disable: `0`
- - Description: `ウォームアップ時のマネー無限`
- `mss_mapchanger_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `マップチェンジャーの有効化`
- `mss_demo_enable`
- - Enable: `1`
- - Disable: `0`
- - Description: `DEMOの有効化`
- `mss_demo_name`
- - Default: `auto-%Y%m%d-%H%M-<*MAPNAME*>`
- - Description:
- - `DEMOファイルの名前`
- - `DateTime形式`
- - `表示例: auto-20190315-1200-de_mirage`
- - `注意: .demはつけないこと`
- `mss_damo_directory`
- - Default: `demo_record/%Y-%m/%Y-%m-%d`
- - Description:
- - `DEMOファイルの名前`
- - `DateTime形式`
- - `保存先例: csgo/demo_record/2019_03/2019-03-15/`
- - `注意: csgoディレクトリ以下にのみ指定可能`
- `mss_demo_record_start_time`
- - Default: `5.0`
- - Description:
- - `DEMO録画が開始される時間`
- - `mss_demo_native_plugin "0"のときのみ有効`
- - `プレイヤーがサーバに接続したX秒後にDEMO録画開始`
- - `tv_delayの影響を受けるため低遅延を推奨`