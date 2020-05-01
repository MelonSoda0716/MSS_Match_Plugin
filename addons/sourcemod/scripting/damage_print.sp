/* プレイヤーがダメージを受けたとき */
public Action ev_pd_damage_dealt(Event event, const char[] name, bool dontBroadcast){
	
	// victim は ダメージを受けたプレイヤー
	// attacker は ダメージを与えたプレイヤー
	
	int attacker = GetClientOfUserId( GetEventInt(event, "attacker") );
	int victim   = GetClientOfUserId( GetEventInt(event, "userid") );

	/*Exception reported 回避用 */
  	bool validAttacker = IsValidClient(attacker);
	bool validVictim = IsValidClient(victim);
	
	if(validAttacker && validVictim){
		
		int PreDamageHealth = GetClientHealth(victim);
		int P_Damage = GetEventInt(event, "dmg_health");
		int PostDamageHealth = GetEventInt(event, "health");
		
		if(PostDamageHealth == 0){
			P_Damage = P_Damage + PreDamageHealth;
		}
		
		PlayerTotalDamage[attacker][victim] += P_Damage;
		PlayerHitCount[attacker][victim]++;
		
	}

}

/* プレイヤーが死亡したとき */
public Action ev_pd_player_death(Event event, const char[] name, bool dontBroadcast){
	
	// victim は ダメージを受けたプレイヤー
	// attacker は ダメージを与えたプレイヤー

	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));

	/*Exception reported 回避用 */
  	bool validAttacker = IsValidClient(attacker);
	bool validVictim = IsValidClient(victim);

	if(validAttacker && validVictim){
		PlayerRoundDead[attacker][victim] = true;
	}

}

/* フォーマットに合わせて各種データを置き換える関数(PugSetUp) */
stock void ReplaceStringWithInt(char[] buffer, int len, const char[] replace, int value, bool caseSensitive = false){

	char intString[16];
	IntToString(value, intString, sizeof(intString));
	ReplaceString(buffer, len, replace, intString, caseSensitive);

}

/* ダメージプリント */
public PrintDamageInfo(int client){

	/* 有効なプレイヤーでない場合はリターン */
	if(!IsValidClient(client)){
		return;
	}

	/* テロリストまたはカウンターテロリストでなければリターン */
	int team = GetClientTeam(client);
	if(team <= 1){
		return;
	}

	/* ダメージプリント用の配列を作成 */
	char message[256];

	/* 自分のチーム以外のデータを取得するために確認する */
	int otherteam;
	if(team == 2){
		otherteam = 3;
	}
	else{
		otherteam = 2;
	}
	
	for (int i = 1; i <= MaxClients; i++) {

		if (IsValidClient(i) && GetClientTeam(i) == otherteam) {
			
			/* プレイヤーのHPを取得 */
			int health;
			if(IsPlayerAlive(i) == true){
				/* 生きていれば */
				health = GetClientHealth(i);
			}
			else{
				health = 0;
			}

			/* プレイヤー名の取得 */
			char name[64];
			GetClientName(i, name, sizeof(name));

			/* Cvarで設定したフォーマットをメッセージにコピー */
			GetConVarString(cvar_mss_print_damage_message_format, message, sizeof(message));

			ReplaceStringWithInt(message, sizeof(message), "{DMG_TO}", PlayerTotalDamage[client][i]);
			ReplaceStringWithInt(message, sizeof(message), "{HITS_TO}", PlayerHitCount[client][i]);
			ReplaceStringWithInt(message, sizeof(message), "{DMG_FROM}", PlayerTotalDamage[i][client]);
			ReplaceStringWithInt(message, sizeof(message), "{HITS_FROM}", PlayerHitCount[i][client]);
			ReplaceString(message, sizeof(message), "{NAME}", name);
			ReplaceStringWithInt(message, sizeof(message), "{HEALTH}", health);
			
			/* フォーマットの形式でクライアントに表示 */
			PrintToChat(client, message);

		}
	}
	
}