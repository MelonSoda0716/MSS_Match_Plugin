# MSS_Match_Plugin
[MelonSoda Server](https://www.melonsoda.tokyo/)で導入しているCS:GO Match Pluginです。  
このプラグイン1つでナイフラウンド、ポーズ、タイムアウト、バックアップラウンド、コーチモード、GOTV無効化、BOT無効化の設定が可能です。   
日本語、英語対応  
  
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/webapps/shoppingcart?flowlogging_id=556959261620c&mfid=1540396755611_556959261620c#/checkout/openButton)

# How to setup
Download ZIPをクリックしダウンロードします。  
![hts1](https://user-images.githubusercontent.com/39918986/47443203-cc9f9980-d7ee-11e8-9229-7d59df1e4c79.png)  
ダウンロードしたファイルを解凍します。  
`addons/sourcemod`と`cfg`をそのまま下の画像の位置に保存します。  
![hts2](https://steamuserimages-a.akamaihd.net/ugc/1613797962872828183/6C073845A10EEB6E8FDABA42540CB894576859CB/)  
以上でセットアップは完了です。

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

チャットから利用できるコマンド一覧（ConsoleCommand）
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
- - Enable: `1`
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
