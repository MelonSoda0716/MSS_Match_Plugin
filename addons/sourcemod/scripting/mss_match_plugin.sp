#include<sourcemod>
#include<cstrike>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo =
{
	name = "MSS Match Plugin",
	author = "MelonSoda",
	description = "MelonSoda CS:GO Server Match Plugin",
	version = "1.2.0",
	url = "https://www.melonsoda.tokyo/"
};

/**********************************
* グローバル関数
**********************************/

/* original handle */
Handle cvar_sv_coaching_enabled;
Handle cvar_mp_maxmoney;
Handle cvar_mp_team_timeout_time;
Handle cvar_mp_round_restart_delay;
Handle cvar_mp_teamname_1;
Handle cvar_mp_teamname_2;
Handle cvar_mp_backup_round_file_last;
Handle cvar_tv_enable;
Handle cvar_tv_autorecord;

/* offset */
new money_offset;

/* ConVar handle */
Handle cvar_mss_printchat_name;
new String:printchat_name[16];
Handle cvar_mss_match_config;
Handle cvar_mss_fullround_config;
Handle cvar_mss_kniferound_enable;
Handle cvar_mss_timeout_enable;
Handle cvar_mss_backupround_enable;
Handle cvar_mss_bot_enable;
Handle cvar_mss_gotvkick_enable;
Handle cvar_mss_nade_enable;
Handle cvar_mss_warmup_infinite_money;
Handle cvar_mss_mapchanger_enable;
Handle cvar_mss_demo_enable;
Handle cvar_mss_demo_name;
Handle cvar_mss_damo_directory;
Handle cvar_mss_demo_record_start;

/* trigger */
int knife_winner;					// ナイフラウンドの勝利チーム
bool in_game              = false;	// 試合中か否か
bool pausable             = false;	// ポーズが有効か否か
bool now_pause            = false;	// ポーズ中か否か
bool now_timeout          = false;	// タイムアウト中か否か
bool knife                = false;	// ナイフラウンド中か否か
bool knife_end_choose     = false;	// ナイフラウンド中か否か
bool end_game             = false;	// 試合が終了したか否か
bool now_vote_backupround = false;	// バックアップラウンド投票中か否か
bool nade_mode            = false;  // 練習モード中か否か
new String:loadcfg[64];				// 試合開始前に読み込むconfig

/* team name */
char ct_team_name[32];
char t_team_name[32];

/* backup round */
int all_player_count = 0;
int vote_end_count = 0;
int vote_backupround_count = 0;
new String:backup_round_file_name[32];

/* demo record */
new String:demo_name_formated[256];
new String:demo_directory_formated[256];
new String:full_path[512];

/* include other file */
#include "demo_record.sp"
#include "map_changer.sp"
// #include "grenade_trajectory.sp"

/**********************************
* プラグインが読み込まれたときに実行
**********************************/
public OnPluginStart(){
	
	LoadTranslations("mss_match_plugin.phrases");	// このプラグインは多言語表示対応しているため必ずphrasesを読み込み
	
	RegConsoleCmd("say"             , Command_Say);
	RegConsoleCmd("admin_backup"    , Command_Adminbackup);
	
	cvar_sv_coaching_enabled       = FindConVar("sv_coaching_enabled");
	cvar_mp_maxmoney               = FindConVar("mp_maxmoney");
	cvar_mp_team_timeout_time      = FindConVar("mp_team_timeout_time");
	cvar_mp_round_restart_delay    = FindConVar("mp_round_restart_delay");
	cvar_mp_teamname_1             = FindConVar("mp_teamname_1");
	cvar_mp_teamname_2             = FindConVar("mp_teamname_2");
	cvar_mp_backup_round_file_last = FindConVar("mp_backup_round_file_last");
	cvar_tv_enable                 = FindConVar("tv_enable");
	cvar_tv_autorecord             = FindConVar("tv_autorecord");

	money_offset                   = FindSendPropInfo("CCSPlayer" , "m_iAccount");
	
	cvar_mss_printchat_name        = CreateConVar("mss_printchat_name"          ,            "MSS"          , "Print to chat name.");
	cvar_mss_match_config          = CreateConVar("mss_match_config"            ,        "esl5on5.cfg"      , "Execute configs on live.");
	cvar_mss_fullround_config      = CreateConVar("mss_fullround_config"        ,  "esl5on5_fullround.cfg"  , "Execute configs on full round.");
	cvar_mss_kniferound_enable     = CreateConVar("mss_kniferound_enable"       ,            "1"            , "0=disable 1=enable");
	cvar_mss_timeout_enable        = CreateConVar("mss_timeout_enable"          ,            "1"            , "0=disable 1=enable");
	cvar_mss_backupround_enable    = CreateConVar("mss_backupround_enable"      ,            "1"            , "0=disable 1=voting 2=forcing(admin only)");
	cvar_mss_bot_enable            = CreateConVar("mss_bot_enable"              ,            "0"            , "0=disable 1=enable");
	cvar_mss_gotvkick_enable       = CreateConVar("mss_gotvkick_enable"         ,            "1"            , "0=disable 1=enable");
	cvar_mss_nade_enable           = CreateConVar("mss_nade_enable"             ,            "1"            , "0=disable 1=enable");
	cvar_mss_warmup_infinite_money = CreateConVar("mss_warmup_infinite_money"   ,            "1"            , "0=disable 1=enable");
	cvar_mss_mapchanger_enable     = CreateConVar("mss_mapchanger_enable"       ,            "1"            , "0=disable 1=enable");
	cvar_mss_demo_enable           = CreateConVar("mss_demo_enable"             ,            "1"            , "0=disable 1=enable");
	cvar_mss_demo_name             = CreateConVar("mss_demo_name"               , "auto-%Y%m%d-%H%M-<*MAPNAME*>" , "Demo name format (FormatTime).");
	cvar_mss_damo_directory        = CreateConVar("mss_damo_directory"          , "demo_record/%Y-%m/%Y-%m-%d"   , "Demo directory format (FormatTime).");
	cvar_mss_demo_record_start     = CreateConVar("mss_demo_record_start_time"  ,            "5.0"               , "Record start time.");

	// BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	HookEvent("round_freeze_end"    , ev_round_freeze_end);
	HookEvent("round_end"           , ev_round_end);
	HookEvent("cs_win_panel_match"  , ev_match_end);
	HookEvent("player_death"        , ev_player_death);

	HookConVarChange(cvar_tv_enable     , ForceCvarChange_cvar_tv_enable);
	HookConVarChange(cvar_tv_autorecord , ForceCvarChange_cvar_tv_autorecord);

}

/**********************************
* Exception reported 回避用
**********************************/
stock bool IsValidClient(int client){
  return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

/**********************************
* JOINプレイヤーの確認
**********************************/
public OnClientPutInServer(int client){
	
	if (IsValidClient(client) && !IsFakeClient(client)){
		
		return;
		
	}
	else if( GetConVarInt(cvar_mss_bot_enable) == 0 ){
		
		ServerCommand("bot_kick");
		
	}
	
}

/**********************************
* マップが読み込まれたときに実行
**********************************/
public OnMapStart(){
	
	ServerCommand("exec mss_match_plugin.cfg");
	
	GetConVarString(cvar_mss_printchat_name, printchat_name, sizeof(printchat_name));
	GetConVarString(cvar_mss_match_config, loadcfg, sizeof(loadcfg));
	
	in_game           = false;
	pausable          = false;
	knife             = false;
	knife_end_choose  = false;
	now_pause         = false;
	now_timeout       = false;
	end_game          = false;
	nade_mode         = false;

	ServerCommand("exec nade_off");	// 強制的に練習モードを無効にする

	if( GetConVarInt(cvar_mss_demo_enable) == 1 ) {
		
		CreateTimer(GetConVarFloat(cvar_mss_demo_record_start), DemoRecordStart);	// DEMO録画開始

	}

}

/**********************************
* !lo3等マッチ開始前に実行
**********************************/
public ExecLo3(){
	
	pausable = true;	// ポーズの有効化
	knife = false;	// ナイフラウンドの無効化
	
	ServerCommand("mp_default_team_winner_no_objective -1");
	ServerCommand("mp_t_default_secondary weapon_glock");
	ServerCommand("mp_ct_default_secondary weapon_hkp2000");
	ServerCommand("exec %s", loadcfg);
	ServerCommand("mp_warmup_end");
	
	PrintToChatAll("[%s] Live on restart.", printchat_name);
	ServerCommand("mp_restartgame 1");
	CreateTimer(2.0, live);	
	
}

public Action:live(Handle:timer){

	for(new i = 0; i <= 6; i++){
		PrintToChatAll("[%s] -=!Live!=-", printchat_name);
	}
	
	PrintToChatAll("[%s] Match is now LIVE! \04[G]\01ood \04[L]\01uck \04[H]\01ave \04[F]\01un!", printchat_name);
	
}

/**********************************
* フリーズタイム終了後に実行
**********************************/
public ev_round_freeze_end(Handle:event, const String:name[], bool:dontBroadcast){

	pausable = false;	// ポーズを無効化
	
}

/**********************************
* ラウンド終了後に実行
**********************************/
public ev_round_end(Handle:event, const String:name[], bool:dontBroadcast){

	pausable = true;	// ポーズの有効化
	
	/* ナイフラウンド実行時に読み込み */
	if(knife){
		
		knife_winner = GetEventInt(event, "winner");	// ナイフランドの勝利チームをフック

		/* テロリストが勝利 */
		if(knife_winner == 2){
			
			KnifeRound_WinT();
			CreateTimer(GetConVarFloat(cvar_mp_round_restart_delay) - 1.0, choose_team);
			CreateTimer(GetConVarFloat(cvar_mp_round_restart_delay) - 0.5, kniferound_command_hint);
			
		}
		/* カウンターテロリストが勝利 */
		else if(knife_winner == 3){
		
			KnifeRound_WinCT();
			CreateTimer(GetConVarFloat(cvar_mp_round_restart_delay) - 1.0, choose_team);
			CreateTimer(GetConVarFloat(cvar_mp_round_restart_delay) - 0.5, kniferound_command_hint);

		}
		/* ナイフラウンドが引き分け */
		else{
			
			KnifeRound_Draw();
			
		}
	}
}

/**********************************
* ナイフラウンド時に実行
**********************************/
public KnifeRound(){
	
	/* 以下のコマンドの場合cs_マップで不具合が生じるが無視 */
	ServerCommand("exec kniferound_start");
	ServerCommand("mp_default_team_winner_no_objective 0");
	ServerCommand("mp_warmup_end");
	
	pausable = true;	// ポーズの有効化
	knife = true;	// ナイフラウンドの有効化
	
	CreateTimer(1.5, knife_live);
	
}

public Action:knife_live(Handle:timer){
	
	for(new i = 0; i <= 2; i++){
		PrintToChatAll("[%s] KNIFE!", printchat_name);
	}
	
}

stock KnifeRound_WinT(){

	GetConVarString(cvar_mp_teamname_2, t_team_name, sizeof(t_team_name));	// テロリストのチーム名を取得

	/* チームネームが設定されている場合は表示 */
	if(t_team_name[0] == '\0'){
		PrintToChatAll("[%s] %t",printchat_name,"KNIFE_ROUND_WIN_T_MESSAGE");
	}
	else{
		PrintToChatAll("[%s] %t",printchat_name,"KNIFE_ROUND_WIN_TEAM_NAME_MESSAGE",t_team_name,t_team_name);
	}

}

stock KnifeRound_WinCT(){
	
	GetConVarString(cvar_mp_teamname_1, ct_team_name, sizeof(ct_team_name));	// カウンターテロリストのチーム名を取得
	
	/* チームネームが設定されている場合は表示 */
	if(ct_team_name[0] == '\0'){
		PrintToChatAll("[%s] %t",printchat_name,"KNIFE_ROUND_WIN_CT_MESSAGE");
	}
	else{
		PrintToChatAll("[%s] %t",printchat_name,"KNIFE_ROUND_WIN_TEAM_NAME_MESSAGE",ct_team_name,ct_team_name);
	}

}

stock KnifeRound_Draw(){
	
	/* 引き分けなら*/
	PrintToChatAll("[%s] %t",printchat_name,"KNIFE_ROUND_DRAW_MESSAGE");
	ServerCommand("exec kniferound_end");
	Restart();	// ウォームアップに戻る
	
}

public Action:choose_team(Handle:timer){
	
	knife_end_choose = true;	// チーム選択のコマンドの有効化
	
	/* !knifeで読み込んだCvarを元に戻す */
	ServerCommand("exec kniferound_end");
	ServerCommand("exec gamemode_competitive_server.cfg");
	ServerCommand("mp_warmup_pausetimer 1");
	ServerCommand("mp_warmup_start");
	
}

public Action:kniferound_command_hint(Handle:timer){

	/* 勝利チームのプレイヤーのみに表示 */
	if(knife_end_choose == true){

		for(new i=1; i<=MaxClients; i++){

			/* ナイフラウンド勝利チームならば */
			if(IsValidClient(i) && GetClientTeam(i) == knife_winner){
				PrintHintText(i,"%t","KNIFE_ROUND_WIN_TEAM_HINT_MESSAGE");
			}
		}
		
		CreateTimer(1.2, kniferound_command_hint);	// チームが選択されるまで再帰

	}
	
}

/**********************************
* プレイヤーが死亡したときに実行
**********************************/
public ev_player_death(Event event, const char[] name, bool dontBroadcast){

	/* ゲーム中でなくかつcvar_mss_warmup_infinite_moneyが有効ならば */
	if( in_game == false && GetConVarInt(cvar_mss_warmup_infinite_money) == 1){
	
		int victim = GetClientOfUserId(event.GetInt("userid"));
		SetEntData(victim, money_offset, GetConVarInt(cvar_mp_maxmoney));

	}
	
}

/**********************************
* 試合が終了したときに実行
**********************************/
public ev_match_end(Event event, const char[] name, bool dontBroadcast){
	
	end_game = true;	// 試合が終了したら全コマンドをマップが変更されるまで使用不可にする

}

/**********************************
* テキストチャットのコマンド
**********************************/
public Action:Command_Say(client, args){
	
	/* 試合が終了したら全コマンドをマップが変更されるまで使用不可にする */
	if(end_game == false){
	
		new String:text[64];	//発言内容保存
		GetCmdArg(1, text, sizeof(text));	//発言内容取得
	
		if( (StrEqual(text, "!live", true)) || (StrEqual(text, "!lo3", true))){
			
			if(in_game == false){
		
				in_game = true;
				GetConVarString(cvar_mss_match_config, loadcfg, sizeof(loadcfg));
				ExecLo3();
				
			}
			else{
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
			}
		
		}
		else if( (StrEqual(text, "!30r", true)) ){
			
			if(in_game == false){
				
				in_game = true;
				GetConVarString(cvar_mss_fullround_config, loadcfg, sizeof(loadcfg));
				ExecLo3();
				
			}
			else{
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
			}
			
		}
		else if(StrEqual(text, "!knife", true)){
			
			/* ナイフランドが有効化されているか確認 */
			if( GetConVarInt(cvar_mss_kniferound_enable) != 1 ) {
				return;
			}
			if(in_game == false){
			
				in_game = true;
				KnifeRound();
				
			}
			else{
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
			}
		
		}
		else if( StrEqual(text, "!restart", true) ){
			
			Restart();
			
		}
		else if(StrEqual(text, "!switch", true)){
			
			/* ナイフラウンド終了後のみ使用可能 */
			if(knife_end_choose){
				SwitchTeams(client);
			}
		
		}
		else if(StrEqual(text, "!stay", true)){
			
			/* ナイフラウンド終了後のみ使用可能 */
			if(knife_end_choose){
				StayTeams(client);
			}
		
		}
		else if(StrEqual(text, "!scramble", true)){
			
			if(in_game == false){
				ScrambleTeams();
			}
			else{
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
			}
			
		}
		else if(StrEqual(text, "!swap", true)){
			
			if(in_game == false){
				SwapTeams();
			}
			else{
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
			}
		}
		else if(StrEqual(text, "!pause", true)){
		
			pause(client);
		
		}
		else if(StrEqual(text, "!unpause")){
		
			unpause(client);
		
		}
		else if(StrEqual(text, "!timeout")){
			
			/* タイムアウトが有効化されているか確認 */
			if( GetConVarInt(cvar_mss_timeout_enable) != 1 ) {
				return;
			}
			
			timeout(client);
			
		}
		else if(StrEqual(text, "!coach t")){
			
			/* コーチモードが有効化されているか確認 */
			if( GetConVarInt(cvar_sv_coaching_enabled) != 1 ) {
			
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
				return;
			
			}
			
			ClientCommand(client, "coach t");
			
		}
		else if(StrEqual(text, "!coach ct")){
			
			/* コーチモードが有効化されているか確認 */
			if( GetConVarInt(cvar_sv_coaching_enabled) != 1 ) {
			
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
				return;
			
			}
			
			ClientCommand(client, "coach ct");
			
		}
		else if(StrEqual(text, "!backup", true)){
			
			/* バックアップラウンドが有効化されているか確認 */
			if( GetConVarInt(cvar_mss_backupround_enable) == 0 ) {
				return;
			}
			
			/* 試合中かつ現在バックアップラウンド投票中でないか確認 */
			if( now_vote_backupround == false && in_game == true){
				AutoRollback(client);
			}
			else{
				PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
			}
			
		}
		else if(StrEqual(text, "!nogotv", true)){
			
			/* GOTVキックが有効化されているか確認 */
			if( GetConVarInt(cvar_mss_gotvkick_enable) != 1 ) {
				return;
			}
			
			NoGotv();

		}
		/* 練習モードは独立した機能であるため!restartや!lo3のコマンドの影響を受けない */
		else if(StrEqual(text, "!nade", true)){
			
			/* 練習モードが有効化されているか確認 */
			if(GetConVarInt(cvar_mss_nade_enable) != 1 ) {
				return;
			}
			/* 練習モードをオフからオン */
			if(nade_mode == false){
				
				nade_mode = true;
				PrintToChatAll("[%s] %t",printchat_name,"NADE_MODE_ON_MESSAGE");
				ServerCommand("exec nade_on");
			
			}
			/* 練習モードをオンからオフ */
			else{
				
				nade_mode = false;
				PrintToChatAll("[%s] %t",printchat_name,"NADE_MODE_OFF_MESSAGE");
				ServerCommand("exec nade_off");
				
			}
		}
		else if((StrEqual(text, "!map", true))){

			/* マップチェンジャーが有効化されているか確認 */
			if( GetConVarInt(cvar_mss_mapchanger_enable) != 1 ) {
				return;
			}
			ChooseMapMenu(client);
		}

	}
}

/**********************************
* ポーズとタイムアウト
**********************************/
stock pause(client){

	new String:name[128];
	GetClientName(client, name, sizeof(name));

	/* ポーズが有効でかつ現在ポーズがされおらずかつタイムアウトもされていない場合 */
	if(pausable==true && now_pause==false && now_timeout==false){
	
		PrintToChatAll("[%s] %t",printchat_name,"PASSED_PAUSE_MESSAGE",name);
		ServerCommand("mp_pause_match");
		now_pause = true;
	}
	else{
		PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
	}
	
}

stock unpause(client){

	new String:name[128];
	GetClientName(client, name, sizeof(name));
	
	/* ポーズが有効で現在ポーズされておりかつタイムアウトがされていない場合 */
	if(pausable==true && now_pause==true && now_timeout==false){
	
		PrintToChatAll("[%s] %t",printchat_name,"RESUMED_PAUSE_MESSAGE",name);
		ServerCommand("mp_unpause_match");
		now_pause = false;
	}
	else{
		PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
	}
}

stock timeout(client){

	new String:name[128];
	GetClientName(client, name, sizeof(name));

	/* ポーズが有効で現在ポーズがされておらずかつタイムアウトもされていない場合 */
	if(pausable==true && now_pause==false && now_timeout==false){
		
		/* テロリストのタイムアウト(試合を開始したときの初期のチーム) */
		if(GetClientTeam(client) == 2){
			
			PrintToChatAll("[%s] %t",printchat_name,"PASSED_TIMEOUT_MESSAGE",name);
			ServerCommand("timeout_terrorist_start");
			now_timeout = true;
			CreateTimer(GetConVarFloat(cvar_mp_team_timeout_time) + 1.0, timeout_end);	// mp_team_timeout_time+1.0秒間は他のチームがポーズとタイムアウトできないように設定
		}

		/* カウンターテロリストのタイムアウト(試合を開始したときの初期のチーム) */
		else if(GetClientTeam(client) == 3){
			
			PrintToChatAll("[%s] %t",printchat_name,"PASSED_TIMEOUT_MESSAGE",name);
			ServerCommand("timeout_ct_start");
			now_timeout = true;
			CreateTimer(GetConVarFloat(cvar_mp_team_timeout_time) + 1.0, timeout_end);	// mp_team_timeout_time+1.0秒間は他のチームがポーズとタイムアウトできないように設定
		}
		else{
			PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
		}
		
	}
	else{
		PrintToChatAll("[%s] %t",printchat_name,"FAILED_MESSAGE");
	}
	
}

public Action:timeout_end(Handle:timer){

	now_timeout = false;	// タイムアウト無効化解除
	
}

/**********************************
* ナイフラウンド終了後の選択
**********************************/
stock SwitchTeams(client){

	int trigger_team = GetClientTeam(client);

	/* ナイフランド勝利チーム以外がチームを選択できないようにチームを確認 */	
	if(knife_winner == trigger_team){
		knife_end_choose  = false;
		PrintToChatAll("[%s] %t",printchat_name,"SWITCH_TEAM_MESSAGE");
		ServerCommand("mp_swapteams");
		CreateTimer(3.0, EX_lo3);
	}

}

stock StayTeams(client){

	int trigger_team = GetClientTeam(client);
	
	/* ナイフランド勝利チーム以外がチームを選択できないようにチームを確認 */
	if(knife_winner == trigger_team){
		knife_end_choose  = false;
		PrintToChatAll("[%s] %t",printchat_name,"STAY_TEAM_MESSAGE");
		CreateTimer(3.0, EX_lo3);
	}
	
}

public Action:EX_lo3(Handle:timer){
	
	GetConVarString(cvar_mss_match_config, loadcfg, sizeof(loadcfg));
	ExecLo3();
	
}

/**********************************
* その他のコマンド
**********************************/
stock ScrambleTeams(){

	PrintToChatAll("[%s] %t",printchat_name,"SCRAMBLE_TEAM_MESSAGE");
	ServerCommand("mp_scrambleteams");
	
}

stock SwapTeams(){

	PrintToChatAll("[%s] %t",printchat_name,"SWAPPING_TEAM_MESSAGE");
	ServerCommand("mp_swapteams");
	
}

stock NoGotv(){

	PrintToChatAll("[%s] %t",printchat_name,"STOP_DEMO_MESSAGE");
	
	/* GOTVが2つある場合も考慮 */
	for (new i = 1; i <= MaxClients; i++){
		
		/* GOTVならキック */
		if(IsValidClient(i) && GetClientTeam(i) == 0){
			KickClient(i,"KICK GOTV");
		}
	}
}

/**********************************
* リスタート(ウォームアップ開始と同義)
**********************************/
stock Restart(){
	
	GetConVarString(cvar_mss_match_config, loadcfg, sizeof(loadcfg));
	
	/* 以下のtriggerをすべてリセット */
	in_game              = false;
	pausable             = false;
	knife                = false;
	knife_end_choose     = false;
	now_pause            = false;
	now_timeout          = false;
	now_vote_backupround = false;
	
	ServerCommand("mp_t_default_secondary weapon_glock");
	ServerCommand("mp_ct_default_secondary weapon_hkp2000");
	ServerCommand("mp_default_team_winner_no_objective -1");
	
	/* リセット用にconfigを読み込み直す */
	ServerCommand("exec gamemode_competitive_server.cfg");
	ServerCommand("exec kniferound_end.cfg");
	
	/* ウォームアップ開始 */
	ServerCommand("mp_unpause_match");
	ServerCommand("mp_warmup_pausetimer 1");
	ServerCommand("mp_warmup_start");

}

/**********************************
* バックアップラウンド(!backup)
**********************************/
stock AutoRollback(client){

	/* 同じラウンドをロールバックしようとするとCvarからファイル名を取得できないためtmpに保存 */
	char tmp_brfn[32];
	GetConVarString(cvar_mp_backup_round_file_last, tmp_brfn, sizeof(tmp_brfn));

	/* 同じラウンドでなければifに入る */
	if(tmp_brfn[0] != '\0'){
		backup_round_file_name = tmp_brfn;
	}
	
	BackupRoundVoteStart(client);

}

stock BackupRoundVoteStart(int client){
	
	PrintToChatAll("[%s] %t",printchat_name,"VOTE_BACKUP_ROUND_MESSAGE");
	
	now_vote_backupround = true;	// 投票開始
	
	all_player_count = 0;	// プレイヤーの数
	vote_backupround_count = 0;	// 投票対象プレイヤー数のリセット
	vote_end_count = 0;	// 投票済プレイヤーのリセット
	
	/* サーバ内のプレイヤーだけ回す */
	for(new i=1; i<=MaxClients; i++){
		if(IsValidClient(i) && !IsFakeClient(i)){	// BOTを除く
			if(GetClientTeam(i) != 1){	// 観戦者を除く
				all_player_count++;	// 投票対象プレイヤー数をカウント
				BackupRoundVoteMenu(i);	// 対象者に対してメニュー表示
			}
		}
	}
	
	CreateTimer(0.0, BackupRoundVoteEndTimer);
	
}

public Action:BackupRoundVoteEndTimer(Handle:timer){

	static int endtimer_cnt = 20;
	
	endtimer_cnt--;

	/* 既に投票が終わっている場合はカウンタを戻して終了 */
	if(now_vote_backupround == false){
		endtimer_cnt = 20;
	}
	/* 投票時間の20秒間の超えた場合強制的に実行 */
	else if(endtimer_cnt <= 0){
		endtimer_cnt = 20;
		ResultBackupRound();
	}
	else{
		CreateTimer(1.0, BackupRoundVoteEndTimer);
	}

}

public BackupRoundVoteMenu(int client){

	Menu menu = new Menu(BackupRoundVoteMenuHandler);
	
	menu.SetTitle("%t","VOTE_BACKUP_ROUND_MENU_MESSAGE", backup_round_file_name);
	menu.AddItem("BACKUP_YES", "YES");
	menu.AddItem("BACKUP_NO", "NO");
	menu.ExitButton = false;
	menu.Display(client, 20);	// 20秒以内に投票
	
}

public BackupRoundVoteMenuHandler(Menu menu, MenuAction action, int client, int param){

	if (action == MenuAction_Select){
		
		char info[32];
		GetMenuItem(menu, param, info, sizeof(info));
		
		if (StrEqual(info, "BACKUP_YES")){
		 	
		 	vote_backupround_count++;	// YESの人のみカウント
		 	vote_end_count++;	// 投票終了者のカウント
		 	
			 /* 投票終了者と対象者が等しい場合 */
		 	if(vote_end_count == all_player_count){
		 		ResultBackupRound();
		 	}
		}
		else if (StrEqual(info, "BACKUP_NO")){
			
			vote_end_count++;	// 投票終了者のカウント
			
			 /* 投票終了者と対象者が等しい場合 */
			if(vote_end_count == all_player_count){
		 		ResultBackupRound();
		 	}
		}
	}
}

public ResultBackupRound(){

	/* すべてのプレイヤーがYESであった場合 */
	if(vote_backupround_count != 0 && vote_backupround_count == all_player_count){
		PrintToChatAll("[%s] \04Yes\01: %d \07No\01: %d", printchat_name, vote_backupround_count, all_player_count - vote_backupround_count);
		PrintToChatAll("[%s] %t",printchat_name,"VOTE_PASSED_MESSAGE");
		CreateTimer(1.8, backup_round);
	}
	else{
		PrintToChatAll("[%s] \04Yes\01: %d \07No\01: %d", printchat_name, vote_backupround_count, all_player_count - vote_backupround_count);
		PrintToChatAll("[%s] %t",printchat_name,"VOTE_REJECTED_MESSAGE");
	}

	now_vote_backupround = false;
	
}

public Action:backup_round(Handle:timer){
	
	/* ロールバックの実行 */
	ServerCommand("mp_backup_restore_load_file %s", backup_round_file_name);
	ServerCommand("mp_backup_restore_load_autopause 1");
	
	/* 以下のtriggerを有効化 */
	in_game = true;
	pausable = true;
	now_pause = true;
	
}

/**********************************
* バックアップラウンド(Console)
**********************************/
public Action Command_Adminbackup(int client, int args){

	/* 引数がない場合はHelpを表示 */
	if(args < 1){

		ReplyToCommand(client,"\"admin_backup\" = \"the number of rounds\"");
		return Plugin_Handled;

	}
	
	/* ラウンド数を取得 */
	int round;
	char buffer[4];
	GetCmdArg(1, buffer, sizeof(buffer));
	round = StringToInt(buffer);

	/* 0以下は存在しないためエラーを返す */
	if(round < 0){
		ReplyToCommand(client,"Greater than or equal to 0.");
		return Plugin_Handled;
	}
	/* 0から9までは0X形式にする */
	else if(round <= 9){
		/* argから取得した値をFormat */
		Format(backup_round_file_name, sizeof(backup_round_file_name), "backup_round0%d.txt", round);
	}
	else{
		/* argから取得した値をFormat */
		Format(backup_round_file_name, sizeof(backup_round_file_name), "backup_round%d.txt", round);
	}

	/* ゲームを開始してから実行するメッセージを表示 */
	if(in_game == false){

		ReplyToCommand(client,"Execute the command after starting the match.");
		ReplyToCommand(client,"Step1: !live");
		ReplyToCommand(client,"Step2: !pause");
		ReplyToCommand(client,"Step3: This commands");
		return Plugin_Handled;
		
	}

	/* 投票(Voting)にした場合 */
	if( GetConVarInt(cvar_mss_backupround_enable) == 1 ) {
		BackupRoundVoteStart(client);
	}
	/* 強制(forceing)にした場合 */
	else{
		CreateTimer(1.5, backup_round);
	}
	return Plugin_Handled;
	
}